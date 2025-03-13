import 'package:flutter/material.dart';
import 'package:belanjain/screen/auth/auth.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Login"),
        ),
        body: LayoutBuilder(builder: (context, constraints) {
          return const Center(
            child: AuthScreen(),
          );
        }));
  }
}
