import 'package:cloud_firestore/cloud_firestore.dart';

class RepliesModel {
  final String replyId;
  final String authorId;
  final String content;
  final DateTime createdAt;

  RepliesModel({
    required this.replyId,
    required this.authorId,
    required this.content,
    required this.createdAt,
  });

  factory RepliesModel.fromMap(Map<String, dynamic> map) {
    return RepliesModel(
      replyId: map['id'] ?? "",
      authorId: map['authorId'] ?? "",
      content: map['content'] ?? "",
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': replyId,
      'authorId': authorId,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  RepliesModel copyWith({
    String? replyId,
    String? authorId,
    String? content,
    DateTime? createdAt,
  }) {
    return RepliesModel(
      replyId: replyId ?? this.replyId,
      authorId: authorId ?? this.authorId,
      content: authorId ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}