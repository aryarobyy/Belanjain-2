import 'dart:io';

import 'package:belanjain/components/button.dart';
import 'package:belanjain/components/snackbar.dart';
import 'package:belanjain/components/text_field.dart';
import 'package:belanjain/models/product/category.dart';
import 'package:belanjain/screen/main_screen.dart';
import 'package:belanjain/services/image_service.dart';
import 'package:belanjain/services/product_service.dart';
import 'package:belanjain/widgets/header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddProduct extends StatefulWidget {
  const AddProduct({Key? key}) : super(key: key);

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
    try {
      if (_titleController.text.isEmpty ||
          _priceController.text.isEmpty ||
          _imgUrl == null ||
          _stockController.text.isEmpty ||
          _descController.text.isEmpty) {
        MySnackbar(context, "Tidak boleh ada yang kosong");
        return;
      }

      await ProductService().postProduct(
        title: _titleController.text.trim(),
        category: _selectedCategory,
        price: double.parse(_priceController.text.trim()),
        stock: double.parse(_stockController.text.trim()),
        desc: _descController.text.trim(),
        imageUrl: _imgUrl!,
      );

      _isSubmitted = true; // Tandai bahwa produk telah dikirim

      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (builder) => MainScreen()));
    } catch (e) {
      print("Tidak bisa posting produk");
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
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (builder) => const MainScreen(),
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
