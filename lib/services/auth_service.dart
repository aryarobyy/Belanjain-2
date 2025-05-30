import 'package:belanjain/models/user_model.dart';
import 'package:belanjain/services/image_service.dart';
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
    if (email.isEmpty || password.isEmpty) {
      throw Exception("Email dan password tidak boleh kosong");
    }
    if (!isValidEmail(email.trim())) {
      throw Exception("Format email salah");
    }
    try {
      final isRegister = await _firestore
          .collection(USER_COLLECTION)
          .where('email', isEqualTo: email)
          .get();
      if (isRegister.docs.isNotEmpty) {
        throw Exception("Email sudah terdaftar");
      }

      final String uuid = Uuid().v4();

      final data = {
        'id': uuid,
        'name': name,
        'email': email,
        'imageUrl': imageUrl ?? "",
        'role': role ?? "customer",
        'createdAt': DateTime.now().toUtc().toIso8601String(),
      };

      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection(USER_COLLECTION).doc(uuid).set(data);

      final storedData =
          await _firestore.collection(USER_COLLECTION).doc(uuid).get();
      if (!storedData.exists) {
        throw Exception("Gagal menyimpan data pengguna");
      }
      return UserModel.fromMap(storedData.data()!);
    } catch (e) {
      throw Exception("Gagal register: $e");
    }
  }

  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      throw Exception("Email atau password tidak boleh kosong");
    }

    if (!isValidEmail(email.trim())) {
      throw Exception("Format email tidak valid");
    }

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw Exception("Autentikasi berhasil, tapi data pengguna tidak ditemukan.");
      }

      final querySnapshot = await _firestore
          .collection(USER_COLLECTION)
          .where('email', isEqualTo: email.trim())
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final userDoc = querySnapshot.docs.first;
        final userId = userDoc.data()['uid'] ?? userDoc.id;

        await _storage.write(key: 'uid', value: userId);
        await _storage.write(key: 'role', value: userDoc.data()['role']);
        await _firestore.collection(USER_COLLECTION).doc(userDoc.id).update({
          'lastLogin': DateTime.now().toIso8601String(),
          'isActive': true,
        });
        final refreshed = await _firestore.collection(USER_COLLECTION).doc(userDoc.id).get();
        print("SSSS ${refreshed.data()}");

        return "success";
      } else {
        throw Exception(
            "Profil pengguna tidak ditemukan; silakan registrasi terlebih dahulu.");
      }
    }  catch (e) {
      print("Error saat login: $e");
      throw Exception("Gagal login. Silakan coba lagi nanti.");
    }
  }

  Future<UserModel> updateUser(
      Map<String, dynamic> updatedData,
      String userId) async {
    try {
      await _firestore.collection(USER_COLLECTION).doc(userId).set(updatedData, SetOptions(merge: true));

      final DocumentSnapshot userDoc =
          await _firestore.collection(USER_COLLECTION).doc(userId).get();

      if (userDoc.exists) {
        print("Fetched updated user data: ${userDoc.data()}");
        return UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
      } else {
        print("User document not found after update.");
        throw Exception("Failed to retrieve updated user data");
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<String> getCurrentUserId() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception("No user is currently logged in");
      }
      return user.uid;
    } catch (e) {
      throw Exception();
    }
  }

  Future<UserModel> getUserById(String userId) async {
    final userData =
        await _firestore.collection(USER_COLLECTION).doc(userId).get();

    if (userData.exists) {
      final data = userData.data();
      if (data != null) {
        return UserModel.fromMap(data);
      }
    }
    throw Exception('User not found');
  }

  Stream<List<UserModel>> getUsers() {
    return _firestore
        .collection(USER_COLLECTION)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data()))
          .toList();
    });
  }


  Future<bool> isUserExist(String currentUserId) async {
    print('🔍 isUserExist called with id="$currentUserId"');
    if (currentUserId.isEmpty) {
      print('⚠️ userId kosong, langsung return false');
      return false;
    }
    try {
      print('📡 calling getUserById…');
      final user = await getUserById(currentUserId);
      print('✅ getUserById returned: $user');
      return user != null;
    } catch (e, st) {
      print('🚨 Exception in isUserExist: $e');
      print(st);
      return false;
    }
  }

  Future<void> signOut(String userId) async {
    await _storage.delete(key: 'uid');
    await _firestore.collection(USER_COLLECTION).doc(userId).update({
      'lastLogin': DateTime.now().toIso8601String(),
      'isActive': false,
    });
  }

  Future<void> deleteUser(String userId, String imageUrl) async {
    await _firestore.collection(USER_COLLECTION)
        .doc(userId)
        .delete();
    await ImagesService().deleteImage(imageUrl);
  }
}
