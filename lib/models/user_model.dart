import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { admin, customer, seller }

class UserModel {
  final String userId;
  final String name;
  final String email;
  final String imageUrl;
  final String username;
  final String role;
  final DateTime createdAt;

  UserModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.imageUrl,
    required this.username,
    required this.role,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    if (!data.containsKey('email')) {
      throw ArgumentError('Email is required');
    }

    return UserModel(
      userId: data['id'] ?? "",
      email: data['email'] ?? "",
      imageUrl: data['imageUrl'] ?? "",
      name: data['name'] ?? "",
      username: data['username'] ?? "",
      role: data['role'] ?? '',
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': userId,
      'email': email,
      'imageUrl': imageUrl,
      'name': name,
      'username': username,
      'role': role,
      'createdAt': createdAt,
    };
  }

  UserModel copyWith({
    String? userId,
    String? email,
    String? imageUrl,
    String? name,
    String? role,
    String? username,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      imageUrl: imageUrl ?? this.imageUrl,
      name: name ?? this.name,
      role: role ?? this.role,
      username: username ?? this.username,
      createdAt: createdAt,
    );
  }
}
