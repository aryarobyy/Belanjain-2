import 'package:belanjain/models/comment/comment_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

class CommentService{

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  final PRODUCT_COLLECTION = "products";
  final COMMENT_COLLECTION = "comments";

  Future<CommentModel> postComment({
    required String productId,
    required String content,
    required double rating
  }) async {
    try {
      final String uuid = Uuid().v4();
      final userId = await _storage.read(key: 'uid');

      final existingCart = await _firestore
        .collection(PRODUCT_COLLECTION)
        .doc(productId)
        .collection(COMMENT_COLLECTION)
        .where('buyerId', isEqualTo: userId)
        .get();

      if (existingCart.docs.isNotEmpty) {
        final existingCartData = existingCart.docs.first.data();
        return CommentModel.fromMap(existingCartData);
      }

      final data = {
        'id': uuid,
        'buyerId': userId,
        'content': content,
        'rating': rating,
        'createdAt': Timestamp.fromDate(DateTime.now()),
        'rating': 0,
      };

      await _firestore.collection(COMMENT_COLLECTION).doc(uuid).set(data);

      final newCart =
      await _firestore.collection(COMMENT_COLLECTION).doc(uuid).get();

      if (!newCart.exists) {
        throw Exception("Gagal menyimpan cart baru.");
      }

      return CommentModel.fromMap(newCart.data()!);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<List<CommentModel>> getCommentsByProduct(String productId) async {
    try {
      final querySnapshot = await _firestore
          .collection(PRODUCT_COLLECTION)
          .doc(productId)
          .collection(COMMENT_COLLECTION)
          .orderBy('createdAt', descending: false)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return [];
      }

      final comments = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return CommentModel.fromMap({
          ...data,
          'id': doc.id,
          'productId': productId,
        });
      }).toList();

      return comments;
    } catch (e) {
      throw Exception('Gagal mengambil comment di produk ini: $productId: $e');
    }
  }


  Future<CommentModel> getSpecificReply(String commentId,String replyId) async {
    final replyData =
    await _firestore
        .collection(COMMENT_COLLECTION)
        .doc(commentId)
        .get();

    if (replyData.exists) {
      final data = replyData.data();
      if (data != null) {
        return CommentModel.fromMap(data);
      }
    }
    throw Exception('Reply not found');
  }
}