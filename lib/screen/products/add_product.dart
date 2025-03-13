import 'package:belanjain/components/button.dart';
import 'package:belanjain/components/text_field.dart';
import 'package:belanjain/models/product/category.dart';
import 'package:belanjain/screen/main_screen.dart';
import 'package:belanjain/services/product_service.dart';
import 'package:belanjain/widgets/header.dart';
import 'package:flutter/material.dart';

class AddProduct extends StatefulWidget {
  const AddProduct({Key? key}) : super(key: key);

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  ProductCategory _selectedCategory = ProductCategory.electronics;

  void _handlePostProduct() async {
    await ProductService().postProduct(
      title: _titleController.text.trim(),
      category: _selectedCategory,
      price: double.parse(_priceController.text.trim()),
      stock: double.parse(_stockController.text.trim()),
      desc: _descController.text.trim(),
    );
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (builder) => MainScreen()));
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
                      items: ProductCategory.values.map((ProductCategory category) {
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