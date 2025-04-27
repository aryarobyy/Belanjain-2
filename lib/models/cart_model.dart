import 'package:cloud_firestore/cloud_firestore.dart';

class CartModel {
  final String cartId;
  final String buyerId;
  final DateTime createdAt;
  final double totalPrice;

  CartModel({
    required this.cartId,
    required this.buyerId,
    required this.createdAt,
    required this.totalPrice,
  });

  factory CartModel.fromMap(Map<String, dynamic> map) {
    return CartModel(
      cartId: map['id'] ?? "",
      buyerId: map['buyerId'] ?? "",
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      totalPrice: (map['totalPrice'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': cartId,
      'buyerId': buyerId,
      'totalPrice': totalPrice,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  CartModel copyWith({
    String? cartId,
    String? buyerId,
    double? totalPrice,
    DateTime? createdAt,
  }) {
    return CartModel(
      cartId: cartId ?? this.cartId,
      buyerId: buyerId ?? this.buyerId,
      totalPrice: totalPrice ?? this.totalPrice,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}