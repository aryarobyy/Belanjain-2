import 'dart:convert';
import 'package:flutter/services.dart';

class ProductProvider {
  List _products = [];

  List get products => _products;

  Future<void> loadProducts() async {
    final String response = await rootBundle.loadString('assets/data/products.json');
    final data = json.decode(response);
    _products = data['products'];
  }
}
