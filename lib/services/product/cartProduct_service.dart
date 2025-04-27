import 'package:belanjain/models/cartProduct_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class CartProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final String CART_COLLECTION = "carts";
  final String PRODUCT_LIST_COLLECTION = "products";

  Future<CartProductModel> insertProduct(
      Map<String, dynamic> data,
      String cartId,
      String productId,
      ) async {
    try {
      DocumentReference newProductRef = _firestore
          .collection(CART_COLLECTION)
          .doc(cartId)
          .collection(PRODUCT_LIST_COLLECTION)
          .doc(productId);

      await newProductRef.set(data);

      DocumentSnapshot newProductDoc = await newProductRef.get();

      if (newProductDoc.exists) {
        return CartProductModel.fromMap(
            newProductDoc.data() as Map<String, dynamic>
        );
      }
      else {
        print("Product document not found after insertion.");
        throw Exception("Failed to retrieve the inserted product data");
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<CartProductModel> getCartProduct(String cartId, productId) async {
    try {
      final querySnapshot = await _firestore
        .collection(CART_COLLECTION)
        .doc(cartId)
        .collection(PRODUCT_LIST_COLLECTION)
        .doc(productId)
        .get();

      if (querySnapshot.exists) {
        final data = querySnapshot.data();
        if (data != null) {
          return CartProductModel.fromMap(data);
        }
      }
      throw Exception("Data kosong");
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<List<CartProductModel>> getAllCartProducts(String cartId) async {
    try {
      final querySnapshot = await _firestore
          .collection(CART_COLLECTION)
          .doc(cartId)
          .collection(PRODUCT_LIST_COLLECTION)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return [];
      }

      final products = querySnapshot.docs.map((doc) {
        return CartProductModel.fromMap(doc.data());
      }).toList();

      return products;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> deleteProduct(String cartId ,String productId) async {
    try{
      await _firestore
          .collection(CART_COLLECTION)
          .doc(cartId)
          .collection(PRODUCT_LIST_COLLECTION)
          .doc(productId)
          .delete();
    } catch (e) {
      throw Exception(e);
    }
  }
}
