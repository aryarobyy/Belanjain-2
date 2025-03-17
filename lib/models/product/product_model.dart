import 'package:belanjain/models/product/category.dart';

class ProductModel {
  final String productId;
  final String title;
  final String imageUrl;
  final String desc;
  final ProductCategory category;
  final String status;
  final double rating;
  final double price;

  ProductModel({
    required this.productId,
    required this.title,
    required this.imageUrl,
    required this.desc,
    required this.category,
    required this.status,
    required this.rating,
    required this.price,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      productId: map['id']?.toString() ?? "",
      title: map['title'] ?? "",
      imageUrl: map['image'] ?? "",
      desc: map['desc'] ?? "",
      category: ProductCategoryExtension.fromString(map['category'] ?? ""),
      status: map['status'] ?? "",
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': productId,
      'title': title,
      'image': imageUrl,
      'desc': desc,
      'category': category.value,
      'status': status,
      'rating': rating,
      'price': price,
    };
  }

  ProductModel copyWith({
    String? productId,
    String? title,
    String? imageUrl,
    String? desc,
    ProductCategory? category,
    String? status,
    double? rating,
    double? price,
  }) {
    return ProductModel(
      productId: productId ?? this.productId,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      desc: desc ?? this.desc,
      category: category ?? this.category,
      status: status ?? this.status,
      rating: rating ?? this.rating,
      price: price ?? this.price,
    );
  }
}
