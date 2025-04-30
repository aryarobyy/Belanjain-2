import 'package:belanjain/models/comment/comment_model.dart';
import 'package:belanjain/models/comment/reply_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

class CommentService{

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  final COMMENT_COLLECTION = "comments";
  final REPLY_COLLECTION = "replies";

  Future<RepliesModel> postReply(
      String commentId,
      String replyId,
      String authorId,
      String content,
      String sellerId
      ) async {
    try {
      final String uuid = Uuid().v4();

      final existingReply = await  _firestore
        .collection(COMMENT_COLLECTION)
        .doc(commentId)
        .collection(REPLY_COLLECTION)
        .where('authorId', isEqualTo: sellerId)
        .get();

      if (existingReply.docs.isNotEmpty) {
        final existingReplyData = existingReply.docs.first.data();
        return RepliesModel.fromMap(existingReplyData);
      }

      final data = {
        'id': uuid,
        'content': content,
        'authorId': authorId
      };

      await _firestore
        .collection(COMMENT_COLLECTION)
        .doc(commentId)
        .collection(REPLY_COLLECTION)
        .doc(uuid)
        .set(data);

      final newReply = await _firestore
        .collection(COMMENT_COLLECTION)
        .doc(commentId)
        .collection(REPLY_COLLECTION)
        .doc(uuid)
        .get();
      if(!newReply.exists){
        throw Exception("Gagal Menyimpan balasan komen");
      }
      return RepliesModel.fromMap(newReply.data()!);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<List<RepliesModel>> getRepliesComment(String commentId) async {
    try{
      final querySnapshot = await _firestore
          .collection(COMMENT_COLLECTION)
          .doc(commentId)
          .collection(REPLY_COLLECTION)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return [];
      }

      final replies = querySnapshot.docs.map((doc) {
        return RepliesModel.fromMap(doc.data());
      }).toList();

      return replies;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<RepliesModel> getSpecificReply(String commentId,String replyId) async {
    final replyData =
    await _firestore
      .collection(COMMENT_COLLECTION)
      .doc(commentId)
      .collection(REPLY_COLLECTION)
      .doc(replyId)
      .get();

    if (replyData.exists) {
      final data = replyData.data();
      if (data != null) {
        return RepliesModel.fromMap(data);
      }
    }
    throw Exception('Reply not found');
  }
}