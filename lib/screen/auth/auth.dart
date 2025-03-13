import 'package:belanjain/components/text_field.dart';
import 'package:belanjain/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:belanjain/screen/main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

part 'register.dart';
part 'login.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoggedIn) {
      return const Login();
    } else {
      return const MainScreen(inputCategory: "All");
    }
  }
}
