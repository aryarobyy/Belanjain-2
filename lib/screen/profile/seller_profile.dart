import 'package:belanjain/components/button.dart';
import 'package:belanjain/models/product/product_model.dart';
import 'package:belanjain/models/user_model.dart';
import 'package:belanjain/screen/auth/auth.dart';
import 'package:belanjain/services/auth_service.dart';
import 'package:belanjain/services/product/product_service.dart';
import 'package:flutter/material.dart';

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
              body: Padding(
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
                    SizedBox(height: 24),
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
                        Icon(Icons.email, color: Colors.grey),
                        SizedBox(width: 8),
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
                    Text("Produk"),
                    Expanded(
                      child: FutureBuilder<List<ProductModel>>(
                        future: ProductService().getProductBySellerId(widget.userId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          if (snapshot.hasError) {
                            return Center(
                              child: Text(
                                'Terjadi kesalahan:\n${snapshot.error}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.red),
                              ),
                            );
                          }

                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Center(
                              child: Text(
                                'Belum ada produk.',
                                style: TextStyle(fontSize: 16),
                              ),
                            );
                          }

                          final products = snapshot.data!;
                          return GridView.builder(
                            padding: const EdgeInsets.all(8),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisExtent: 140,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 1,
                            ),
                            itemCount: products.length,
                            itemBuilder: (context, index) {
                              final product = products[index];
                              return Column(
                                children: [
                                  Image.network(
                                    product.imageUrl,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    product.title,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    )
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