import 'package:belanjain/screen/auth/auth.dart';
import 'package:belanjain/screen/dashboard_screen.dart';
import 'package:belanjain/screen/main_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'firebase_options.dart';

final String geminiApi = dotenv.env['GEMINI_API'] ?? " ";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  Gemini.init(apiKey: geminiApi);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}


class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
        title: "Belanjain",
        theme: ThemeData(),
        // home: const DashboardScreen());
        // home: const AuthScreen());
        home: const MainScreen());
  }
}
