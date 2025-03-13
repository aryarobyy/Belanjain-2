import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; //buat kIsWeb, buat cek itu web atau bukan
import 'package:belanjain/model/user_model.dart';

const String baseUrl = 'http://10.0.2.2:5000';
const String localUrl = 'http://localhost:5000';
const String url = kIsWeb ? localUrl : baseUrl;

Future<User> fetchUser() async {
  final response = await http.get(Uri.parse('$url/auth'));

  if (response.statusCode == 200) {
    return User.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  } else {
    throw Exception('Failed to load user: ${response.statusCode}');
  }
}

Future<void> postUser(
    String name, String username, String email, String password) async {
  final response = await http.post(
    Uri.parse('$url/auth/register'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'name': name,
      'username': username,
      'email': email,
      'password': password,
    }),
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    print('User registered successfully');
  } else {
    throw Exception('Failed to register user: ${response.statusCode}');
  }
}

Future<Map<String, dynamic>> loginUser(String username, String password) async {
  if (username.isEmpty || password.isEmpty) {
    throw Exception('Username or Password cannot be empty');
  }

  try {
    final response = await http.post(
      Uri.parse('$url/auth/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('User logged in successfully: $username');
      return data;
    } else {
      throw Exception('Failed to log in: ${response.body}');
    }
  } catch (e) {
    throw Exception('Error: $e');
  }
}
