import 'package:cloud_firestore/cloud_firestore.dart';

class CartModel {
  final String cartId;
  final String buyerId;
  final DateTime createdAt;

  CartModel({
    required this.cartId,
    required this.buyerId,
    required this.createdAt,
  });

  factory CartModel.fromMap(Map<String, dynamic> map) {
    return CartModel(
      cartId: map['id'] ?? "",
      buyerId: map['buyerId'] ?? "",
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': cartId,
      'buyerId': buyerId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  CartModel copyWith({
    String? cartId,
    String? buyerId,
    DateTime? createdAt,
  }) {
    return CartModel(
      cartId: cartId ?? this.cartId,
      buyerId: buyerId ?? this.buyerId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}