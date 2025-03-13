import 'dart:convert';

import 'package:belanjain/models/product_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;


final String productUrl = dotenv.env['PRODUCT_API_2'] ?? " ";

class ProductService {
  Future<List<ProductModel>> getProducts() async {
    final res = await http.get(Uri.parse(productUrl));

    if (res.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(res.body);
      if (jsonResponse.containsKey('products') && jsonResponse['products'] is List) {
        final List<dynamic> productList = jsonResponse['products'];
        return productList.map((item) => ProductModel.fromJson(item)).toList();
      } else {
        throw Exception("Expected a list in the 'data' field but got: ${jsonResponse['products']}");
      }
    } else {
      throw Exception("Failed to fetch products: ${res.statusCode}");
    }
  }

}