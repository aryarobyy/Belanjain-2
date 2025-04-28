import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String commentId;
  final String buyerId;
  final DateTime createdAt;
  final double rating;

  CommentModel({
    required this.commentId,
    required this.buyerId,
    required this.createdAt,
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
      'rating': rating,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  CommentModel copyWith({
    String? commentId,
    String? buyerId,
    double? rating,
    DateTime? createdAt,
  }) {
    double newRating = rating ?? this.rating;
    if (newRating > 5.0) {
      newRating = 5.0;
    }

    return CommentModel(
      commentId: commentId ?? this.commentId,
      buyerId: buyerId ?? this.buyerId,
      rating: newRating,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}