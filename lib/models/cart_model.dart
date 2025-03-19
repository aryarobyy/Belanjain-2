import 'package:cloud_firestore/cloud_firestore.dart';

class CartModel {
    final String cartId;
    final List<String> productId;
    final String sellerId;
    final double amount;
    final double totalPrice;
    final DateTime createdAt;

  CartModel({
    required this.cartId,
    required this.productId,
    required this.sellerId,
    required this.totalPrice,
    required this.amount,
    required this.createdAt,
  });

  factory CartModel.fromMap(Map<String, dynamic> map) {
    return CartModel(
      cartId: map['id'] ?? "",
      productId: List<String>.from(map['product_id'] ?? []),
      sellerId: map['seller_id'] ?? "",
      totalPrice: map['total_price'] ?? "",
      amount: map['amount'] ?? "",
      createdAt: map['created_at'] is Timestamp
          ? (map['created_at'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': cartId,
      'product_id': productId,
      'seller_id': sellerId,
      'total_price': totalPrice,
      'amount': amount,
      'created_at': createdAt,
    };
  }

  CartModel copyWith({
    String? cartId,
    List<String>? productId,
    String? sellerId,
    double? totalPrice,
    double? amount,
  }) {
    return CartModel(
      productId: productId ?? this.productId,
      cartId: cartId ?? this.cartId,
      sellerId: sellerId ?? this.sellerId,
      totalPrice: totalPrice ?? this.totalPrice,
      amount: amount ?? this.amount,
      createdAt: createdAt,
    );
  }
}