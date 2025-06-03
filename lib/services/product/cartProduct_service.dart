import 'package:belanjain/models/cartProduct_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class CartProductService {
  final FirebaseFirestore _firestore;

  final String CART_COLLECTION = "carts";
  final String PRODUCT_LIST_COLLECTION = "products";

  CartProductService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<CartProductModel> insertProduct(
      Map<String, dynamic> data,
      String cartId,
      String productId,
      ) async {
    try {
      if (cartId.isEmpty) {
        throw ArgumentError('Cart ID cannot be empty');
      }
      if (productId.isEmpty) {
        throw ArgumentError('Product ID cannot be empty');
      }
      if (data.isEmpty) {
        throw ArgumentError('Product data cannot be empty');
      }

      // Get document reference
      DocumentReference newProductRef = _firestore
          .collection(CART_COLLECTION)
          .doc(cartId)
          .collection(PRODUCT_LIST_COLLECTION)
          .doc(productId);

      await newProductRef.set(data);

      DocumentSnapshot newProductDoc = await newProductRef.get();

      if (newProductDoc.exists && newProductDoc.data() != null) {
        Map<String, dynamic> docData = newProductDoc.data() as Map<String, dynamic>;
        return CartProductModel.fromMap(docData);
      } else {
        throw Exception("Failed to retrieve the inserted product data");
      }
    } on ArgumentError {
      rethrow;
    } on FirebaseException catch (e) {
      throw Exception("Firestore error: ${e.message}");
    } catch (e) {
      throw Exception("Unexpected error occurred: ${e.toString()}");
    }
  }

  Future<void> deleteProduct(String cartId, String productId) async {
    try {
      if (cartId.isEmpty || productId.isEmpty) {
        throw ArgumentError('Cart ID and Product ID cannot be empty');
      }

      await _firestore
          .collection(CART_COLLECTION)
          .doc(cartId)
          .collection(PRODUCT_LIST_COLLECTION)
          .doc(productId)
          .delete();
    } on ArgumentError {
      rethrow;
    } catch (e) {
      throw Exception("Failed to delete product: ${e.toString()}");
    }
  }

  Future<List<CartProductModel>> getCartProducts(String cartId) async {
    try {
      if (cartId.isEmpty) {
        throw ArgumentError('Cart ID cannot be empty');
      }

      QuerySnapshot querySnapshot = await _firestore
          .collection(CART_COLLECTION)
          .doc(cartId)
          .collection(PRODUCT_LIST_COLLECTION)
          .get();

      return querySnapshot.docs
          .map((doc) => CartProductModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception("Failed to get cart products: ${e.toString()}");
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

   Stream<List<CartProductModel>> streamCartProducts(String cartId) async* {
      try {
        final querySnapshot = await _firestore
            .collection(CART_COLLECTION)
            .doc(cartId)
            .collection(PRODUCT_LIST_COLLECTION)
            .get();

        if (querySnapshot.docs.isEmpty) {
          yield [];
        }

        final products = querySnapshot.docs.map((doc) {
          return CartProductModel.fromMap(doc.data());
        }).toList();

        yield products;
      } catch (e) {
        throw Exception(e);
      }
    }

  Future<void> deleteProducts(String cartId, List<String> productIds) async {
    try {
      final batch = _firestore.batch();

      for (var productId in productIds) {
        final docRef = _firestore
            .collection(CART_COLLECTION)
            .doc(cartId)
            .collection(PRODUCT_LIST_COLLECTION)
            .doc(productId);
        batch.delete(docRef);
      }

      await batch.commit();
    } catch (e) {
      throw Exception(e);
    }
  }

}
