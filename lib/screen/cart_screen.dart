import 'package:belanjain/models/cart_model.dart';
import 'package:belanjain/models/product/product_model.dart';
import 'package:belanjain/screen/main_screen.dart';
import 'package:belanjain/services/cart_service.dart';
import 'package:belanjain/services/product_service.dart';
import 'package:belanjain/widgets/header.dart';
import 'package:flutter/material.dart';

class CartScreen extends StatefulWidget {
  final String userId;
  const CartScreen({super.key, required this.userId});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
          MyHeader(
          title: "Keranjang",
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (builder) => const MainScreen(),
                ),
              );
            },
          ),
            FutureBuilder<CartModel>(
              future: CartService().getCartByUserId(widget.userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                      child: Text("Error loading cart: ${snapshot.error}")
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(child: Text("Tidak Ada keranjang"));
                }
                final cart = snapshot.data!;
                print("Cart: ${cart.productId}");
                return FutureBuilder<List<ProductModel>>(
                  future: ProductService().getProductsByIds(cart.productId),
                  builder: (context, productSnapshot) {
                    if (productSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (productSnapshot.hasError) {
                      print("Error ${productSnapshot.error}");
                    }
                    if (!productSnapshot.hasData || productSnapshot.data!.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shopping_cart, size: 100, color: Colors.grey),
                            const SizedBox(height: 20),
                            const Text(
                              "Keranjang kamu masih kosong",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "Temukan produk menarik untuk ditambahkan ke keranjang kamu!",
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => const MainScreen()),
                                );
                              },
                              child: const Text("Belanja Sekarang"),
                            ),
                          ],
                        ),
                      );
                    }
                    final products = productSnapshot.data!;
                    return ListView.builder(
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return ListTile(
                          title: Text(product.title),
                          subtitle: Text('\$${product.price.toString()}'),
                        );
                      },
                    );
                    // Tambahkan return default untuk memastikan semua jalur return widget
                    // return Container();
                  },
                );

              }
            )
          ],
        ),
      ),
    );
  }
}
