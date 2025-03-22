class CartProductModel {
  final String CartProductId;
  final String productId;
  final int amount;
  final double totalPrice;

  CartProductModel({
    required this.productId,
    required this.CartProductId,
    required this.totalPrice,
    required this.amount,
  });

  factory CartProductModel.fromMap(Map<String, dynamic> map) {
    return CartProductModel(
      CartProductId: map['id'] != null ? map['id'] as String : '',
      productId: map['productId'] != null ? map['productId'] as String : '',
      totalPrice: (map['totalPrice'] as num?)?.toDouble() ?? 0.0,
      amount: (map['amount'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': CartProductId,
      'productId': productId,
      'totalPrice': totalPrice,
      'amount': amount,
    };
  }

  CartProductModel copyWith({
    String? CartProductId,
    String? productId,
    double? totalPrice,
    int? amount,
  }) {
    return CartProductModel(
      CartProductId: CartProductId ?? this.CartProductId,
      productId: productId ?? this.productId,
      totalPrice: totalPrice ?? this.totalPrice,
      amount: amount ?? this.amount,
    );
  }
}