import 'package:belanjain/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

final USER_COLLECTION = 'users';

class AuthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _storage = FlutterSecureStorage();

  bool isValidEmail(String email) {
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(email);
  }


  Future<UserModel?> registerUser({
    required String email,
    required String name,
    required String password,
    String? role,
    String? imageUrl,
    String? username,
  }) async {
    if(email.isEmpty || password.isEmpty){
      throw Exception("Email dan password tidak boleh kosong");
    }
    if(isValidEmail(email.trim())){
      throw Exception( "Format email salah");
    }
    try{
      final isRegister = await _firestore
          .collection(USER_COLLECTION)
          .where('email', isEqualTo: email)
          .get();
      if(isRegister.docs.isNotEmpty){
        throw Exception("Email sudah terdaftar");
      }

      final String uuid = Uuid().v4();

      final data = {
        'user_id': uuid,
        'name' : name,
        'email' : email,
        'image_url' : "",
        'role' : "customer",
        'created_at' : DateTime.now().toUtc().toIso8601String(),
      };

      await _auth.signInWithEmailAndPassword(email: email, password: password);
      await _firestore.collection(USER_COLLECTION).doc(uuid).set(data);
     final storaedData = await _firestore
        .collection(USER_COLLECTION)
        .doc(uuid)
        .get();
      if(storaedData.exists){
        throw Exception("Register success");
      }
    } catch (e){
      throw Exception("Gagal login");
    }
  }

}