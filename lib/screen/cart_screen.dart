import 'package:belanjain/components/snackbar.dart';
import 'package:belanjain/models/cartProduct_model.dart';
import 'package:belanjain/models/cart_model.dart';
import 'package:belanjain/models/product/product_model.dart';
import 'package:belanjain/screen/main_screen.dart';
import 'package:belanjain/services/product/cartProduct_service.dart';
import 'package:belanjain/services/product/cart_service.dart';
import 'package:belanjain/services/product/product_service.dart';
import 'package:belanjain/widgets/header.dart';
import 'package:belanjain/widgets/quantity_button.dart';
import 'package:flutter/material.dart';

class CartScreen extends StatefulWidget {
  final String userId;
  const CartScreen({super.key, required this.userId});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  CartModel? _cart;
  CartProductModel? _products;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _cartLoader();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _cartLoader() async {
    try {
      final cartData = await CartService().getCartByUserId(widget.userId);
      if (cartData == null) {
        print("Cart tidak ditemukan untuk user: ${widget.userId}");
      } else {
        print("Cartss: ${cartData.cartId}");
      }
      final productData = await CartProductService().getCartProduct(cartData.cartId);
      if (productData == null) {
        print("Product tidak ditemukan di cart: ${cartData.cartId}");
      } else {
        print("Total: ${productData.amount}");
      }
      setState(() {
        _cart = cartData;
        _products = productData;
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  void _updateCart(double price, int newAmount) async {
    if (_cart == null || _products == null) return;
    try {
      Map<String, dynamic> updatedData = {
        "id": _cart!.cartId,
        "productId": _products!.productId,
        "amount": newAmount,
        "totalPrice": newAmount * price,
      };

      await CartProductService().insertProduct(updatedData, _cart!.cartId, _products!.productId);

      setState(() {
        _products = _products!.copyWith(
          amount: newAmount,
          totalPrice: newAmount * price,
        );
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> _confirmDelete() async {
    if (_cart == null || _products == null) return;

    final bool? isConfirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: const Text('Apakah Anda yakin ingin menghapus produk ini dari keranjang?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (isConfirmed == true) {
      try {
        await CartProductService().deleteProduct(_cart!.cartId, _products!.productId);
        setState(() {
          _products = null;
        });
        MySnackbar(context, "Produk berhasil dihapus dari keranjang");
      } catch (e) {
        print("Error deleting product: $e");
        MySnackbar(context, "Terjadi kesalahan saat menghapus produk");
      }
    }
  }

  Future<void> _confirmPayment() async {
    if (_cart == null || _products == null) return;

    final bool? isConfirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Konfirmasi Pembayaran'),
          content: const Text('Apakah Anda yakin ingin membayar?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Bayar'),
            ),
          ],
        );
      },
    );

    if (isConfirmed == true) {
      try {
        await CartService().deleteCart(_cart!.cartId);
        setState(() {
          _products = null;
        });
        MySnackbar(context, "Produk berhasil dibayar");
      } catch (e) {
        print("Error deleting product: $e");
        MySnackbar(context, "Terjadi kesalahan saat membayar");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Column(
          children: [
            MyHeader(
              title: "Keranjang",
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const MainScreen()),
                );
              },
            ),
            Expanded(
              child: _products == null  || _cart == null
                ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.shopping_cart, size: 100, color: Colors.grey),
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
                  ),
                )
                : FutureBuilder<ProductModel>(
                future: ProductService().getProductsById(_products!.productId),
                builder: (context, productSnapshot) {
                  if (productSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (productSnapshot.hasError) {
                    print("Error ${productSnapshot.error}");
                    return const Center(child: Text("Terjadi kesalahan"));
                  }
                  // if (!productSnapshot.hasData) {
                  //
                  // }

                  final product = productSnapshot.data!;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    product.imageUrl,
                                    height: 100,
                                    width: 100,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.broken_image, size: 100),
                                  ),
                                ),

                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.title,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "Harga: Rp ${product.price}",
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),

                                      const SizedBox(height: 8),
                                      QuantityButton(
                                        initialAmount: _products!.amount,
                                        price: product.price,
                                        stock: product.stock,
                                        onChanged: (newAmount) {
                                          _updateCart(product.price, newAmount);
                                        },
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "Total Harga: Rp. ${_products!.totalPrice}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _confirmDelete,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.delete),
                                  SizedBox(width: 8),
                                  Text("Hapus Produk"),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      //beta
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed:_confirmPayment,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text(
            "Lanjutkan ke Pembayaran",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
