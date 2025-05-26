import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String commentId;
  final String buyerId;
  final String content;
  final DateTime createdAt;
  final double rating;
  final bool hide;

  CommentModel({
    required this.commentId,
    required this.buyerId,
    required this.createdAt,
    required this.content,
    required this.hide,
    required double rating,
  }) : rating = rating > 5.0 ? 5.0 : rating;

  factory CommentModel.fromMap(Map<String, dynamic> map) {
    double parsedRating = (map['rating'] as num?)?.toDouble() ?? 0.0;
    if (parsedRating > 5.0) {
      parsedRating = 5.0;
    }

    return CommentModel(
      commentId: map['id'] ?? "",
      buyerId: map['buyerId'] ?? "",
      content: map['content'] ?? "",
      hide: map['hide'] ?? false,
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      rating: parsedRating,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': commentId,
      'buyerId': buyerId,
      'content': content,
      'rating': rating,
      'hide': hide,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  CommentModel copyWith({
    String? commentId,
    String? buyerId,
    String? content,
    double? rating,
    bool? hide,
    DateTime? createdAt,
  }) {
    double newRating = rating ?? this.rating;
    if (newRating > 5.0) {
      newRating = 5.0;
    }

    return CommentModel(
      commentId: commentId ?? this.commentId,
      buyerId: buyerId ?? this.buyerId,
      content: content ?? this.content,
      rating: newRating,
      hide: hide ?? this.hide,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}