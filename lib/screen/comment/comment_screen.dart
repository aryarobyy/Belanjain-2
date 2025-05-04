import 'package:belanjain/models/comment/comment_model.dart';
import 'package:belanjain/models/product/product_model.dart';
import 'package:belanjain/models/user_model.dart';
import 'package:belanjain/screen/product/detail_screen.dart';
import 'package:belanjain/services/auth_service.dart';
import 'package:belanjain/services/comment/comment_service.dart';
import 'package:belanjain/widgets/header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CommentScreen extends StatefulWidget {
  UserModel? userData;
  ProductModel? product;

  CommentScreen({
    super.key,
    this.product,
    required this.userData
  });

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  String role = '';
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getRole();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            MyHeader(
              title: "Comment",
              onTapLeft: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailScreen(
                      product: widget.product!,
                      userData: widget.userData
                    )
                  )
                );
              }
            ),

            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: FutureBuilder<List<CommentModel>>(
                      future: CommentService().getCommentsByProduct(widget.product!.productId),
                      builder: (context, snapshot){
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        }
                        final comments = snapshot.data!;
                        if (comments.isEmpty) {
                          return const Center(child: Text('Belum ada komentar'));
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.all(8.0),
                          itemCount: comments.length,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemBuilder: (BuildContext context, int index) {
                            final comment = comments[index];
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
                                  final user = userSnap.data!;
                                  return CircleAvatar(
                                    backgroundImage: NetworkImage(user.imageUrl),
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
                                  return Text(
                                    userSnap.data!.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
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
                                    TextButton(onPressed: () {/* reply */}, child: const Text('Reply')),
                                ],
                              ),
                            );

                          },
                        );
                      }
                    ),
                  ),
                ],
              ),
            ),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, -1),
                  )
                ],
              ),
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: 'Add a comment...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      if (_commentController.text.isNotEmpty) {
                        _commentController.clear();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingStars(double rating) {
    const maxStars = 5;
    final fullStars = rating.floor();
    final hasHalfStar = (rating - fullStars) >= 0.5;
    final emptyStars = maxStars - fullStars - (hasHalfStar ? 1 : 0);

    List<Widget> stars = [];

    for (var i = 0; i < fullStars; i++) {
      stars.add(const Icon(Icons.star, size: 16));
    }
    if (hasHalfStar) {
      stars.add(const Icon(Icons.star_half, size: 16));
    }
    for (var i = 0; i < emptyStars; i++) {
      stars.add(const Icon(Icons.star_border, size: 16));
    }

    return Row(children: stars);
  }

}