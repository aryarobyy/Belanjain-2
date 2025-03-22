import 'package:belanjain/models/product/category.dart';

class ProductModel {
  final String productId;
  final String userId;
  final String title;
  final String imageUrl;
  final String desc;
  final ProductCategory category;
  final String status;
  final double rating;
  final double price;
  final int stock;

  ProductModel({
    required this.productId,
    required this.userId,
    required this.title,
    required this.imageUrl,
    required this.desc,
    required this.category,
    required this.status,
    required this.rating,
    required this.price,
    required this.stock,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      productId: map['id'] ?? "",
      userId: map['userId'] ?? "",
      title: map['title'] ?? "",
      imageUrl: map['image'] ?? "",
      desc: map['desc'] ?? "",
      category: ProductCategoryExtension.fromString(map['category'] ?? ""),
      status: map['status'] ?? "",
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      stock: (map['stock'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': productId,
      'userId': userId,
      'title': title,
      'image': imageUrl,
      'desc': desc,
      'category': category.value,
      'status': status,
      'rating': rating,
      'price': price,
      'stock': stock,
    };
  }

  ProductModel copyWith({
    String? productId,
    String? userId,
    String? title,
    String? imageUrl,
    String? desc,
    ProductCategory? category,
    String? status,
    double? rating,
    double? price,
    int? stock,
  }) {
    return ProductModel(
      productId: productId ?? this.productId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      desc: desc ?? this.desc,
      category: category ?? this.category,
      status: status ?? this.status,
      rating: rating ?? this.rating,
      price: price ?? this.price,
      stock: stock ?? this.stock,
    );
  }
}
