import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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

  factory UserModel.fromMap(Map<String, dynamic> data, documentId) {
    if (!data.containsKey('email')) {
      throw ArgumentError('Email is required');
    }

    return UserModel(
      userId: data['user_id'] ?? documentId,
      email: data['email'] ?? "",
      imageUrl: data['image_url'] ?? "",
      name: data['name'] ?? "",
      username: data['username'] ?? "",
      role: data['role'] ?? '',
      createdAt: data['created_at'] is Timestamp
          ? (data['created_at'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'email': email,
      'image_url': imageUrl,
      'name': name,
      'username': username,
      'role': role,
      'created_at': createdAt,
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