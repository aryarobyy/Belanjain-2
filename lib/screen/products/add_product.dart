import 'package:belanjain/components/text_field.dart';
import 'package:flutter/material.dart';

class AddProduct extends StatefulWidget {
  const AddProduct({super.key});

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _categoryController = TextEditingController();
  TextEditingController _priceController = TextEditingController();
  TextEditingController _stockController = TextEditingController();
  TextEditingController _descController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Products"),
      ),
      body: SafeArea(
        child: Column(
          children: [
            MyTextField(
              controller: _categoryController,
              name: "Name",
              inputType: TextInputType.text
            ),
            MyTextField(
              controller: _priceController,
              name: "Name",
              inputType: TextInputType.text
            ),
            MyTextField(
              controller: _stockController,
              name: "Name",
              inputType: TextInputType.text
            ),
            MyTextField(
              controller: _descController,
              name: "Name",
              inputType: TextInputType.text
            ),
          ],
        )
      ),
    );
  }
}
