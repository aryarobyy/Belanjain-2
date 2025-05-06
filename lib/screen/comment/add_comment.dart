import 'package:belanjain/components/button.dart';
import 'package:belanjain/components/colors.dart';
import 'package:belanjain/components/snackbar.dart';
import 'package:belanjain/models/product/product_model.dart';
import 'package:belanjain/models/user_model.dart';
import 'package:belanjain/screen/product/detail_screen.dart';
import 'package:belanjain/services/comment/comment_service.dart';
import 'package:belanjain/widgets/header.dart';
import 'package:belanjain/widgets/volume_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddComment extends StatefulWidget {
  final ProductModel product;
  final UserModel userData;
  const AddComment({
    super.key,
    required this.product,
    required this.userData
  });

  @override
  State<AddComment> createState() => _AddCommentState();
}

class _AddCommentState extends State<AddComment> with WidgetsBindingObserver {
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _ratingController = TextEditingController();
  double _selectedValue = 0.0;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _contentController.dispose();
    _ratingController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _handlePostComment() async {
    if (_contentController.text.isEmpty) {
      MySnackbar(context, "Komentar tidak boleh kosong");
      return;
    }

    if (_selectedValue == 0.0) {
      MySnackbar(context, "Silakan berikan rating terlebih dahulu");
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await CommentService().postComment(
        productId: widget.product.productId,
        content: _contentController.text,
        rating: _selectedValue,
      );

      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (builder) => DetailScreen(
                  product: widget.product,
                  userData: widget.userData
              )
          )
      );
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      MySnackbar(context, "Gagal mengirim komentar. Silakan coba lagi.");
      print("Error posting comment: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            MyHeader(
              title: "Tambah Ulasan",
              onTapLeft: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (builder) => DetailScreen(
                        product: widget.product,
                        userData: widget.userData
                    ),
                  ),
                );
              },
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product info card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              widget.product.imageUrl,
                              width: 70,
                              height: 70,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 70,
                                  height: 70,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.image_not_supported, color: Colors.grey),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.product.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Rp${widget.product.price.toStringAsFixed(0)}",
                                  style: const TextStyle(
                                    color: primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "Beri Rating",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          VolumeSelector(
                            onChanged: (value) {
                              setState(() {
                                _selectedValue = value;
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _getRatingText(_selectedValue),
                            style: TextStyle(
                              color: _getRatingColor(_selectedValue),
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    const Text(
                      "Tulis Ulasan",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _contentController,
                        decoration: InputDecoration(
                          hintText: "Bagikan pengalaman Anda dengan produk ini...",
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Theme.of(context).primaryColor),
                          ),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                        maxLines: 5,
                        textInputAction: TextInputAction.done,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: MyButton(
                onPressed: _isSubmitting ? null : _handlePostComment,
                text: _isSubmitting ? "Mengirim..." : "Kirim Ulasan",
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getRatingText(double rating) {
    if (rating == 0) return "Belum diberi rating";
    if (rating <= 1) return "Sangat Buruk";
    if (rating <= 2) return "Buruk";
    if (rating <= 3) return "Cukup";
    if (rating <= 4) return "Bagus";
    return "Sangat Bagus";
  }

  Color _getRatingColor(double rating) {
    if (rating == 0) return Colors.grey;
    if (rating <= 1) return Colors.red;
    if (rating <= 2) return Colors.orange;
    if (rating <= 3) return Colors.amber;
    if (rating <= 4) return Colors.lime;
    return Colors.green;
  }
}