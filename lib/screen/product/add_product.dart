import 'dart:io';

import 'package:belanjain/components/button.dart';
import 'package:belanjain/components/snackbar.dart';
import 'package:belanjain/components/text_field.dart';
import 'package:belanjain/models/product/category.dart';
import 'package:belanjain/models/user_model.dart';
import 'package:belanjain/screen/index.dart';
import 'package:belanjain/screen/main_screen.dart';
import 'package:belanjain/services/auth_service.dart';
import 'package:belanjain/services/image_service.dart';
import 'package:belanjain/services/product/product_service.dart';
import 'package:belanjain/widgets/header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddProduct extends StatefulWidget {
  final UserModel sellerData;

  const AddProduct({Key? key, required this.sellerData}) : super(key: key);

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> with WidgetsBindingObserver {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  ProductCategory _selectedCategory = ProductCategory.electronics;
  String? _imgUrl;
  bool _isSubmitted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    if (!_isSubmitted && _imgUrl != null) {
      ImagesService().deleteImage(_imgUrl!);
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached || state == AppLifecycleState.paused) {
      if (!_isSubmitted && _imgUrl != null) {
        ImagesService().deleteImage(_imgUrl!);
      }
    }
  }

  void _handlePostProduct() async {
    UserModel _sellerData = widget.sellerData;
    try {
      if (_titleController.text.isEmpty ||
          _priceController.text.isEmpty ||
          _imgUrl == null ||
          _stockController.text.isEmpty ||
          _descController.text.isEmpty) {
        MySnackbar(context, "Tidak boleh ada yang kosong");
        return;
      }

      setState(() => _isSubmitted = true);

      final stock = double.parse(_stockController.text.trim());
      final status = stock > 1 ? 'ready' : 'Out of Stock';

      final productPosted = await ProductService().postProduct(
        sellerId: _sellerData.userId,
        title: _titleController.text.trim(),
        category: _selectedCategory,
        price: double.parse(_priceController.text.trim()),
        stock: stock,
        desc: _descController.text.trim(),
        imageUrl: _imgUrl!,
        status: status,
      );

      await AuthService().updateUser({
        "productStored": productPosted.productId},
        _sellerData.userId
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainScreen()),
      );
    } catch (e) {
      MySnackbar(context, "Gagal posting: ${e.toString()}");
    } finally {
      setState(() => _isSubmitted = false);
    }
  }


  void _handleUploadImage() async {
    try {
      final res = await ImagesService().uploadImage();
      setState(() {
        _imgUrl = res;
      });
    } catch (e) {
      throw Exception(e);
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
                    ElevatedButton(
                        onPressed: _handleUploadImage, child: Text("Upload")),
                    MyTextField(
                      controller: _titleController,
                      name: "Nama Produk",
                      inputType: TextInputType.text,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<ProductCategory>(
                      decoration: const InputDecoration(
                        labelText: "Kategori",
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedCategory,
                      items:
                      ProductCategory.values.map((ProductCategory category) {
                        return DropdownMenuItem<ProductCategory>(
                          value: category,
                          child: Text(category.value),
                        );
                      }).toList(),
                      onChanged: (ProductCategory? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedCategory = newValue;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    MyTextField(
                      controller: _priceController,
                      name: "Harga",
                      inputType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    MyTextField(
                      controller: _stockController,
                      name: "Stok",
                      inputType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    MyTextField(
                      controller: _descController,
                      name: "Deskripsi",
                      inputType: TextInputType.multiline,
                    ),
                    const SizedBox(height: 16),
                    MyButton(
                      onPressed: _handlePostProduct,
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
