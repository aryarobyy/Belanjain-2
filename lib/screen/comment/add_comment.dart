import 'dart:io';

import 'package:belanjain/components/button.dart';
import 'package:belanjain/components/snackbar.dart';
import 'package:belanjain/components/text_field.dart';
import 'package:belanjain/models/product/category.dart';
import 'package:belanjain/screen/index.dart';
import 'package:belanjain/screen/main_screen.dart';
import 'package:belanjain/services/comment/comment_service.dart';
import 'package:belanjain/services/comment/reply_service.dart';
import 'package:belanjain/services/image_service.dart';
import 'package:belanjain/services/product/product_service.dart';
import 'package:belanjain/widgets/header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddComment extends StatefulWidget {
  final String productId;
  const AddComment({
    super.key,
    required this.productId
  });

  @override
  State<AddComment> createState() => _AddCommentState();
}

class _AddCommentState extends State<AddComment> with WidgetsBindingObserver {
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _ratingController = TextEditingController();

  ProductCategory _selectedCategory = ProductCategory.electronics;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _handlePostComment() async {
    try {
      if (_contentController.text.isEmpty ||
          _ratingController.text.isEmpty) {
        MySnackbar(context, "Tidak boleh ada yang kosong");
        return;
      }

      await CommentService().postComment(
        productId: widget.productId,
        content: _contentController.text,
        rating:  double.parse(_ratingController.text.trim()),
      );

      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (builder) => MainScreen()));
    } catch (e) {
      print("Tidak bisa posting produk");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            MyHeader(
              title: "Tambah Produk",
              onTapLeft: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (builder) => const IndexScreen(),
                  ),
                );
              },
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    MyTextField(
                      controller: _contentController,
                      name: "Nama Produk",
                      inputType: TextInputType.text,
                    ),
                    const SizedBox(height: 16),
                    MyTextField(
                      controller: _ratingController,
                      name: "Harga",
                      inputType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    MyButton(
                      onPressed: _handlePostComment,
                      text: "Add",
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
