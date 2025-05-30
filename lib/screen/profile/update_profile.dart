import 'package:belanjain/components/button.dart';
import 'package:belanjain/components/text_field.dart';
import 'package:belanjain/models/user_model.dart';
import 'package:belanjain/screen/index.dart';
import 'package:belanjain/screen/profile/user_profile.dart';
import 'package:belanjain/services/auth_service.dart';
import 'package:belanjain/services/image_service.dart';
import 'package:belanjain/widgets/header.dart';
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

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void handleUploadImage() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final res = await _imagesService.uploadImage();

      if (res == null || res.isEmpty) {
        setState(() {
          _errorMessage = "Image upload failed or returned an empty response.";
        });
        return;
      }

      final uploadRes = await _auth.updateUser({"imageUrl": res}, widget.userData.userId);

      if (uploadRes != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Profile image updated successfully!")),
          );
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error uploading image: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void handleSubmit() async {
    if (_nameController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = "Name is required";
      });
      return;
    }

    if (_emailController.text.trim().isNotEmpty &&
        !isValidEmail(_emailController.text.trim())) {
      setState(() {
        _errorMessage = "Please enter a valid email address";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final _currUserId = await _auth.getCurrentUserId();

      final uploadData = <String, dynamic>{
        'name': _nameController.text.trim(),
        'email': _emailController.text.isNotEmpty ?
          _emailController.text.trim().toLowerCase() :
          widget.userData.email,
      };

      if (_bioController.text.trim().isNotEmpty) {
        uploadData['bio'] = _bioController.text.trim();
      }

      await _auth.updateUser(uploadData, widget.userData.userId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully!")),
        );

        await Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const IndexScreen(initialTab: 1,),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error updating profile: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
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
      body: SafeArea(
        child: Column(
          children: [
            MyHeader(
              title: "Update your profile",
              onTapLeft: () => {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const IndexScreen(initialTab: 1,)
                  )
                )
              }
            ),
            Expanded(child: _buildProfileUi()),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileUi() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: _deviceWidth * 0.05,
          vertical: _deviceHeight * 0.03,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Error message display
            if (_errorMessage != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  border: Border.all(color: Colors.red.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red.shade700),
                ),
              ),

            Stack(
              children: [
                CircleAvatar(
                  backgroundImage: widget.userData.imageUrl.isNotEmpty
                      ? NetworkImage(widget.userData.imageUrl)
                      : const AssetImage("assets/images/profile.png")
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
                      onPressed: _isLoading ? null : handleUploadImage,
                      icon: _isLoading
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                          : const Icon(
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
              name: "Full Name",
              prefixIcon: Icons.person,
              inputType: TextInputType.name,
            ),
            const SizedBox(height: 20),
            MyTextField(
              controller: _emailController,
              name: "Email Address",
              prefixIcon: Icons.email,
              inputType: TextInputType.emailAddress,
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
              onPressed: _isLoading ? null : handleSubmit,
              text: _isLoading ? "Updating..." : "Update Profile",
            ),
          ],
        ),
      ),
    );
  }
}