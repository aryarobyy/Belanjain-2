import 'package:belanjain/components/button.dart';
import 'package:belanjain/components/colors.dart';
import 'package:belanjain/components/popup.dart';
import 'package:belanjain/components/snackbar.dart';
import 'package:belanjain/models/comment/comment_model.dart';
import 'package:belanjain/models/product/product_model.dart';
import 'package:belanjain/models/user_model.dart';
import 'package:belanjain/screen/comment/add_comment.dart';
import 'package:belanjain/screen/comment/comment_screen.dart';
import 'package:belanjain/services/auth_service.dart';
import 'package:belanjain/services/comment/comment_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CommentSection extends StatefulWidget {
  final UserModel? userData;
  final ProductModel product;

  const CommentSection({
    super.key,
    required this.userData,
    required this.product,
  });

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  bool showAllComments = false;
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  String role = '';
  bool hasBoughtProduct = false;
  String _buyerId = '';

  Widget _buildRatingStars(double rating) {
    const maxStars = 5;
    final fullStars = rating.floor();
    final hasHalfStar = (rating - fullStars) >= 0.5;
    final emptyStars = maxStars - fullStars - (hasHalfStar ? 1 : 0);

    List<Widget> stars = [];

    for (var i = 0; i < fullStars; i++) {
      stars.add(const Icon(
        Icons.star, size: 16,
        color: goldColor,
      ));
    }
    if (hasHalfStar) {
      stars.add(const Icon(
        Icons.star_half,
        size: 16,
        color: goldColor,
      ));
    }
    for (var i = 0; i < emptyStars; i++) {
      stars.add(const Icon(
        Icons.star_border,
        size: 16,
        color: goldColor,
      ));
    }

    return Row(children: stars);
  }

  void _getRole() async {
    final userRole = await _storage.read(key: 'role');
    if (userRole != null) {
      setState(() {
        role = userRole;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getRole();
    _checkIfProductIsBought();
  }

  void _checkIfProductIsBought() {
    if (widget.userData != null) {
      final boughtList = widget.userData!.itemBought ?? [];
      final productId = widget.product.productId;
      final isBought = boughtList.contains(productId);

      setState(() {
        hasBoughtProduct = isBought;
      });

    } else {
      print("USER DATA IS NULL");
    }
  }

  @override
  void didUpdateWidget(CommentSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.userData != oldWidget.userData) {
      _checkIfProductIsBought();
    }
  }

  void _handleDeleteComment(BuildContext context, String productId, String commentId) async {
    final result = await MyPopup(
      context: context,
      title: "Hapus Komentar",
      content: "Anda yakin ingin menghapus komentar ini?",
    );

    if (result == true) {
      Map<String, dynamic> updatedData = {
        "hide": true,
      };
      await CommentService().deleteComment(productId, commentId, updatedData);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Column(
            children: [
              Expanded(
                child: FutureBuilder<List<CommentModel>>(
                  future: CommentService().getCommentsByProduct(widget.product.productId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    final comments = snapshot.data!;
                    final visibleComments = comments.where((c) => c.hide == false).toList();

                    if (visibleComments.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Belum ada komentar'),
                            if (hasBoughtProduct)
                              Padding(
                                padding: const EdgeInsets.only(top: 16.0),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 3,
                                    textStyle: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => AddComment(
                                          product: widget.product,
                                          userData: widget.userData!,
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Text("Tambahkan Komentar"),
                                ),
                              ),
                          ],
                        ),
                      );
                    }
                    return Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(8.0),
                            itemCount: comments.length,
                            itemBuilder: (context, index) {
                              final comment = comments[index];
                              _buyerId = comment.buyerId;
                              if (comment.hide == false) {
                                return ListTile(
                                leading: FutureBuilder<UserModel>(
                                  future: AuthService().getUserById(comment.buyerId!),
                                  builder: (ctx, userSnap) {
                                    if (userSnap.connectionState == ConnectionState.waiting) {
                                      return const CircleAvatar(child: CircularProgressIndicator());
                                    }
                                    if (userSnap.hasError || userSnap.data == null) {
                                      return const CircleAvatar(child: Icon(Icons.error));
                                    }
                                    return CircleAvatar(
                                      backgroundImage: NetworkImage(userSnap.data!.imageUrl),
                                    );
                                  },
                                ),

                                title: FutureBuilder<UserModel>(
                                  future: AuthService().getUserById(comment.buyerId!),
                                  builder: (ctx, userSnap) {
                                    if (userSnap.connectionState == ConnectionState.waiting) {
                                      return const Text('Loading...');
                                    }
                                    if (userSnap.hasError || userSnap.data == null) {
                                      return const Text('Unknown User');
                                    }
                                    return Row(
                                      children: [
                                        Text(
                                          userSnap.data!.name,
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        const Spacer(),
                                        if(widget.userData!.role == 'admin')
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete_forever_outlined,
                                              color: Colors.red,
                                            ),
                                            onPressed: () => _handleDeleteComment( context, widget.product.productId, comment.commentId),
                                          )
                                      ],
                                    );
                                  },
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildRatingStars(comment.rating),
                                    const SizedBox(height: 4),
                                    Text(comment.content ?? ''),
                                    if (role == 'seller')
                                      TextButton(
                                        onPressed: () {},
                                        child: const Text('Reply'),
                                      ),
                                  ],
                                ),
                              );
                              }
                            },
                          ),
                        ),

                        if(comments.contains(_buyerId))
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child:
                          Center(
                            child: Column(
                              children: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 3,
                                    textStyle: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => AddComment(
                                            product: widget.product,
                                            userData: widget.userData!,
                                          )
                                      ),
                                    );
                                  },
                                  child: const Text("Tambahkan Komentar"),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (comments.length > 2 && !showAllComments)
                          InkWell(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CommentScreen(
                                    product: widget.product,
                                    userData: widget.userData,
                                  ),
                                ),
                              );
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.arrow_drop_down),
                                  Text("Selengkapnya"),
                                ],
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}