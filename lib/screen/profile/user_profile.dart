import 'package:belanjain/components/button.dart';
import 'package:belanjain/models/user_model.dart';
import 'package:belanjain/screen/auth/auth.dart';
import 'package:belanjain/services/auth_service.dart';
import 'package:belanjain/widgets/header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserProfile extends StatefulWidget {
  final String userId;
  const UserProfile({ super.key, required this.userId });

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final _storage = const FlutterSecureStorage();
  final AuthService _auth = AuthService();
  late double _deviceHeight;
  late double _deviceWidth;

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth  = MediaQuery.of(context).size.width;

    return Scaffold(
      body: _buildProfileUi(),
    );
  }

  Widget _buildProfileUi() {
    return FutureBuilder<String?>(
      future: _storage.read(key: 'uid'),
      builder: (context, uidSnap) {
        if (uidSnap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (uidSnap.hasError) {
          return Center(
            child: Text(
              'Gagal membaca user ID:\n${uidSnap.error}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        final currUser = uidSnap.data?.trim() ?? '';

        return FutureBuilder<UserModel>(
          future: _auth.getUserById(widget.userId),
          builder: (context, profSnap) {
            if (profSnap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (profSnap.hasError || !profSnap.hasData) {
              return const Center(
                child: Text(
                  "Unable to load user profile",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }

            final user   = profSnap.data!;
            final imgUrl = user.imageUrl;

            return Scaffold(
              body: SafeArea(
                child: Column(
                  children: [
                    if (currUser != user.userId.trim())
                      MyHeader(
                        title: user.name,
                        onTapLeft: () => Navigator.pop(context),
                      ),

                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 24.0
                      ),
                      child: Column(
                        children: [
                          CircleAvatar(
                            backgroundImage: imgUrl.isNotEmpty
                                ? NetworkImage(imgUrl)
                                : const AssetImage("assets/images/profile.png")
                            as ImageProvider,
                            radius: 70,
                          ),
                          const SizedBox(height: 24),

                          // Nama
                          Row(
                            children: [
                              const Icon(Icons.person, color: Colors.grey),
                              const SizedBox(width: 8),
                              Text(
                                "Name",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              const Spacer(),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            user.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          const Divider(height: 32, thickness: 1),

                          // Email
                          Row(
                            children: [
                              const Icon(Icons.email, color: Colors.grey),
                              const SizedBox(width: 8),
                              Text(
                                "Email",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              const Spacer(),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            user.email,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          const SizedBox(height: 30),

                          if (currUser == user.userId.trim())
                            MyButton(
                              text: "Logout",
                              onPressed: () async {
                                await _auth.signOut();
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const AuthScreen(),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
