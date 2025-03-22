import 'package:belanjain/screen/auth/auth.dart';
import 'package:belanjain/screen/main_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'firebase_options.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  String? _userId;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    final userId = await _storage.read(key: 'uid');
    setState(() {
      _userId = userId;
    });
  }

  @override
  Widget build(BuildContext context) {
    print("UserId: $_userId");
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Belanjain",
        theme: ThemeData(),
        home: _userId == null ? AuthScreen() : MainScreen(),
      );
  }
}
