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
  final List<String> itemBought;

  UserModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.imageUrl,
    required this.username,
    required this.role,
    required this.createdAt,
    required this.itemBought,
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    if (!data.containsKey('email')) {
      throw ArgumentError('Email is required');
    }

    final rawList = data['itemBought'];
    final List<String> items = rawList is List
        ? rawList.map((e) => e.toString()).toList()
        : <String>[];

    return UserModel(
      userId: data['id'] as String? ?? '',
      email: data['email'] as String? ?? '',
      imageUrl: data['imageUrl'] as String? ?? '',
      name: data['name'] as String? ?? '',
      username: data['username'] as String? ?? '',
      role: data['role'] as String? ?? '',
      itemBought: items,
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
      'itemBought': itemBought,
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
    List<String>? itemBought,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      imageUrl: imageUrl ?? this.imageUrl,
      name: name ?? this.name,
      role: role ?? this.role,
      username: username ?? this.username,
      itemBought: itemBought ?? this.itemBought,
      createdAt: createdAt,
    );
  }
}
