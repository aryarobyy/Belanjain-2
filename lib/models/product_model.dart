class ProductModel {
  final String productId;
  final String title;
  final String imageUrl;
  final String desc;
  final String category;
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

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      productId: json['id']?.toString() ?? "",
      title: json['title'] ?? "",
      imageUrl: json['thumbnail'] ?? "",
      desc: json['description'] ?? "",
      category: json['category'] ?? "",
      status: json['availabilityStatus'] ?? "",
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': productId,
      'title': title,
      'thumbnail': imageUrl,
      'description': desc,
      'category': category,
      'availabilityStatus': status,
      'rating': rating,
      'price': price,
    };
  }

  ProductModel copyWith({
    String? productId,
    String? title,
    String? imageUrl,
    String? desc,
    String? category,
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
