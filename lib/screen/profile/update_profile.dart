import 'package:belanjain/components/button.dart';
import 'package:belanjain/components/text_field.dart';
import 'package:belanjain/models/user_model.dart';
import 'package:belanjain/screen/profile/seller_profile.dart';
import 'package:belanjain/screen/profile/user_profile.dart';
import 'package:belanjain/services/auth_service.dart';
import 'package:belanjain/services/image_service.dart';
import 'package:flutter/material.dart';

class UpdateProfile extends StatefulWidget {
  final UserModel userData;

  const UpdateProfile({
    required this.userData,
    super.key
  });

  @override
  State<UpdateProfile> createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {
  late double _deviceHeight;
  late double _deviceWidth;
  final ImagesService _imagesService = ImagesService();
  final AuthService _auth = AuthService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  void handleUploadImage() async {
    try {
      final res = await _imagesService.uploadImage();

      if (res == null || res.isEmpty) {
        print("Image upload failed or returned an empty response.");
        return;
      }

      final uploaded = {'image': res};

      final uploadRes = await _auth.updateUser({"imageUrl":uploaded}, widget.userData.userId);
      if (uploadRes.imageUrl != null) {
        final deleteImage =
        await _imagesService.deleteImage(uploadRes.imageUrl);
        print("Image deleted: $deleteImage");
        return;
      }
      print("Success: $uploadRes");
    } catch (e) {
      print("Error uploading image: $e");
    }
  }

  void handleSubmit() async {
    final _currUserId = await _auth.getCurrentUserId();

    if (_emailController.text.isEmpty ||
        _bioController.text.isEmpty ||
        _nameController.text.isEmpty) {
      if(widget.userData.role == 'seller'){
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SellerProfile(userId: _currUserId),
          ),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserProfile(userId: _currUserId),
          ),
        );
      }
    }
    try {
      if (!isValidEmail(_emailController.text.trim()) &&
          _emailController.text.trim().isNotEmpty) {
        return;
      }

      final currentUser = await _auth.getUserById(_currUserId);
      final currentName = currentUser.name ?? '';
      final currentEmail = currentUser.email ?? '';

      final uploadData = {
        'name': _nameController.text.trim().isEmpty
            ? currentName
            : _nameController.text.trim(),
        'email': _emailController.text.trim().isEmpty
            ? currentEmail
            : _emailController.text.toLowerCase(),
      };

      await _auth.updateUser(uploadData, widget.userData.userId);
      if(widget.userData.role == 'seller'){
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SellerProfile(userId: _currUserId),
          ),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserProfile(userId: _currUserId),
          ),
        );
      }
    } catch (e) {
      print("Error update user $e");
    }
  }

  bool isValidEmail(String email) {
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Update Your profile"),
      ),
      body: _buildProfileUi(),
    );
  }

  Widget _buildProfileUi() {
    return FutureBuilder<UserModel>(
      future: _auth.getUserById(widget.userData.userId!),
      builder: (context, profileSnapshot) {
        if (profileSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (profileSnapshot.hasError || !profileSnapshot.hasData) {
          return const Center(
            child: Text("Error fetching user profile"),
          );
        }
        final user = profileSnapshot.data!;
        final imgUrl = user.imageUrl;

        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: _deviceWidth * 0.05,
              vertical: _deviceHeight * 0.03,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      backgroundImage: imgUrl.isNotEmpty
                          ? NetworkImage(imgUrl)
                          : AssetImage("assets/images/profile.png")
                      as ImageProvider,
                      radius: 70,
                    ),
                    Positioned(
                      bottom: 3,
                      right: 2,
                      child: Container(
                        width: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey[500],
                          shape: BoxShape.circle,
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: handleUploadImage,
                          icon: const Icon(
                            Icons.camera_alt_outlined,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                MyTextField(
                  controller: _nameController,
                  name: user.name,
                  prefixIcon: Icons.person,
                  inputType: TextInputType.name,
                ),
                const SizedBox(height: 20),
                MyTextField(
                  controller: _bioController,
                  name: "Enter your bio",
                  prefixIcon: Icons.speaker_notes_outlined,
                  inputType: TextInputType.text,
                  minLine: 2,
                  maxLine: 5,
                ),
                const SizedBox(height: 30),
                MyButton(
                  onPressed: handleSubmit,
                  text: "Submit",
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}