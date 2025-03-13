import 'package:flutter/foundation.dart';

class Image {
  final String productId;
  final String name;
  final String image;
  final String desc;

  const Image({
    required this.productId,
    required this. name,
    required this.image,
    required this.desc
  });

  factory Image.fromJson(Map<String, dynamic> json){
    return Image(
        productId: json['productId'] as String,
        name: json['name'] as String,
        image: json['image'] as String,
        desc: json['desc'] as String
    );
  }
}