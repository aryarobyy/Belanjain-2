import 'package:belanjain/components/button.dart';
import 'package:belanjain/models/user_model.dart';
import 'package:belanjain/screen/auth/auth.dart';
import 'package:belanjain/services/auth_service.dart';
import 'package:flutter/material.dart';

class UserProfile extends StatefulWidget {
  final String userId;

  const UserProfile({
    super.key,
    required this.userId
  });

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  late double _deviceHeight;
  late double _deviceWidth;
  final AuthService _auth = AuthService();
  String? _currUser;

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: _buildProfileUi(),
    );
  }

  Widget _buildProfileUi() {
    return FutureBuilder<String>(
      future: _auth.getCurrentUserId(),
      builder: (context, snapshots) {
        if (snapshots.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshots.hasError || !snapshots.hasData) {
          return const Center(
            child: Column(
              children: [
                Text(
                  "User Tidak terdeteksi",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        }
        final currUser = snapshots.data;
        return FutureBuilder<UserModel>(
          future: _auth.getUserById(widget.userId),
          builder: (context, profileSnapshot) {
            if (profileSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (profileSnapshot.hasError || !profileSnapshot.hasData) {
              return const Center(
                child: Text(
                  "Unable to load user profile",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }
            final user = profileSnapshot.data!;
            final imgUrl = user.imageUrl;

            return Scaffold(
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 24.0),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            backgroundImage: imgUrl.isNotEmpty
                                ? NetworkImage(imgUrl)
                                : const AssetImage("assets/images/profile.png")
                            as ImageProvider,
                            radius: 70,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
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
                      SizedBox(height: 8),
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Divider(height: 32, thickness: 1),
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
                          Spacer(),
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
                      const SizedBox(height: 8),
                      // Text(
                      //   user.bio,
                      //   style: TextStyle(
                      //     fontSize: 20,
                      //     fontWeight: FontWeight.w500,
                      //   ),
                      // ),
                      const SizedBox(
                        height: 30,
                      ),
                      // currUser == widget.userId ?
                      // SizedBox(
                      //   width: 150,
                      //   child: MyButton(
                      //       text: "Edit Your Profile",
                      //       onPressed: () {
                      //         Navigator.push(
                      //             context,
                      //             MaterialPageRoute(
                      //                 builder: (context) => UpdateProfile()));
                      //       }),
                      // ) : SizedBox(height: 10,)
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}