class CartProductModel {
  final String CartProductId;
  final String productId;
  final int amount;
  final double totalPrice;
  final bool isChecked;

  CartProductModel({
    required this.productId,
    required this.CartProductId,
    required this.totalPrice,
    required this.amount,
    required this.isChecked,
  });

  factory CartProductModel.fromMap(Map<String, dynamic> map) {
    return CartProductModel(
      CartProductId: map['id'] != null ? map['id'] as String : '',
      productId: map['productId'] != null ? map['productId'] as String : '',
      isChecked: map['isChecked'] != null ? map['isChecked'] as bool : false,
      totalPrice: _safeToDouble(map['totalPrice']),
      amount: _safeToInt(map['amount']),
    );
  }

  static double _safeToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      return parsed ?? 0.0;
    }
    return 0.0;
  }

  static int _safeToInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value);
      return parsed ?? 0;
    }
    return 0;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': CartProductId,
      'productId': productId,
      'totalPrice': totalPrice,
      'amount': amount,
      'isChecked': isChecked,
    };
  }

  CartProductModel copyWith({
    String? CartProductId,
    String? productId,
    double? totalPrice,
    int? amount,
    bool? isChecked,
  }) {
    return CartProductModel(
      CartProductId: CartProductId ?? this.CartProductId,
      productId: productId ?? this.productId,
      totalPrice: totalPrice ?? this.totalPrice,
      amount: amount ?? this.amount,
      isChecked: isChecked ?? this.isChecked,
    );
  }
}