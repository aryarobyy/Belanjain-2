import 'package:belanjain/components/button.dart';
import 'package:belanjain/models/product/product_model.dart';
import 'package:belanjain/models/user_model.dart';
import 'package:belanjain/screen/profile/update_profile.dart';
import 'package:belanjain/services/auth_service.dart';
import 'package:belanjain/services/product/product_service.dart';
import 'package:belanjain/widgets/header.dart';
import 'package:belanjain/widgets/product_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SellerProfile extends StatefulWidget {
  final String userId;

  const SellerProfile({
    super.key,
    required this.userId
  });

  @override
  State<SellerProfile> createState() => _SellerProfileState();
}

class _SellerProfileState extends State<SellerProfile> {
  final _storage = const FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildProfileUi(),
    );
  }

  Widget _buildProfileUi() {
    return FutureBuilder<String?>(
      future: _storage.read(key: 'uid'),
      builder: (context, uidSnapshot) {
        if (uidSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (uidSnapshot.hasError) {
          return Center(
            child: Text(
              'Gagal membaca user ID:\n${uidSnapshot.error}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        final currUser = uidSnapshot.data?.trim() ?? '';

        return FutureBuilder<UserModel>(
          future: AuthService().getUserById(widget.userId),
          builder: (context, profileSnapshot) {
            if (profileSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
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
              body: SafeArea(
                child: Column(
                  children: [
                    if (currUser != user.userId.trim())
                      MyHeader(
                        title: user.name,
                        onTapLeft: () => Navigator.pop(context),
                      ),

                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 24.0,
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

                            const Divider(height: 32, thickness: 1),
                            const SizedBox(height: 8),

                            if (currUser == user.userId.trim())
                              MyButton(
                                text: "Edit Profile",
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          UpdateProfile(userData: user),
                                    ),
                                  );
                                },
                              ),

                            const SizedBox(height: 16),
                            const Text("Produk"),
                            const SizedBox(height: 8),

                            Expanded(
                              child: FutureBuilder<List<ProductModel>>(
                                future: ProductService()
                                    .getProductBySellerId(widget.userId),
                                builder: (context, prodSnap) {
                                  if (prodSnap.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  }
                                  if (prodSnap.hasError) {
                                    return Center(
                                      child: Text(
                                        'Terjadi kesalahan:\n${prodSnap.error}',
                                        textAlign: TextAlign.center,
                                        style:
                                        const TextStyle(color: Colors.red),
                                      ),
                                    );
                                  }
                                  final products = prodSnap.data;
                                  if (products == null || products.isEmpty) {
                                    return const Center(
                                      child: Text(
                                        'Belum ada produk.',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    );
                                  }
                                  return ProductTile(products: products);
                                },
                              ),
                            ),
                          ],
                        ),
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