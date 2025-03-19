import 'package:belanjain/models/cart_model.dart';
import 'package:belanjain/models/product/product_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

class CartService {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FlutterSecureStorage _storage = FlutterSecureStorage();

  final CART_COLLECTION = "cart";

  Future<CartModel> postCart() async {
    try {
      final String uuid = Uuid().v4();
      final userId = await _storage.read(key: 'uid');

      final data = {
        'id': uuid,
        'seller_id': userId,
        'product_id': <String>[],
        'amount': 0.0,
        'total_price': 0.0,
        'created_at': DateTime.now().toIso8601String(),
      };

      final existingCart = await _firestore
          .collection(CART_COLLECTION)
          .where('seller_id', isEqualTo: userId)
          .get();

      if (existingCart.docs.isNotEmpty) {
        final existingCartData = existingCart.docs.first.data();
        return CartModel.fromMap(existingCartData);
      }

      await _firestore.collection(CART_COLLECTION).doc(uuid).set(data);

      final newCart = await _firestore.collection(CART_COLLECTION).doc(uuid).get();

      if (!newCart.exists) {
        throw Exception("Gagal menyimpan cart baru.");
      }

      return CartModel.fromMap(newCart.data()!);
    } catch (e) {
      throw Exception(e.toString());
    }
  }


  Future<CartModel> insertProduct(Map<String, dynamic> products, String cartId) async {
    try{
      await _firestore
          .collection(CART_COLLECTION)
          .doc(cartId)
          .set(products);

      final DocumentSnapshot cartDoc = await _firestore.collection(CART_COLLECTION).doc(cartId).get();

      if(cartDoc.exists){
        return CartModel.fromMap(cartDoc.data() as Map<String, dynamic>);
      }
      else {
        print("User document not found after update.");
        throw Exception("Failed to retrieve updated user data");
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<CartModel> getCartByUserId(String userId) async {
    try{
      final cartData = await _firestore
          .collection(CART_COLLECTION)
          .where('seller_id', isEqualTo: userId)
          .get();

      if(cartData.docs.isEmpty){
        throw Exception("Data kosong");
      }

      final data = cartData.docs.first.data();
      return CartModel.fromMap(data);
    } catch (e){
      throw Exception(e);
    }
  }

  Future<CartModel> getCartByCartId(String cartId) async{
    final cartData = await _firestore
        .collection(CART_COLLECTION)
        .doc(cartId)
        .get();
    if (cartData.exists) {
      final data = cartData.data();
      if(data != null){
        return CartModel.fromMap(data);
      }
    }
    throw Exception("Data kosong");
  }
}