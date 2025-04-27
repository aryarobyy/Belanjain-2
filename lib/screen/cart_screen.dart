import 'package:belanjain/components/colors.dart';
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
import 'package:intl/intl.dart';

class CartScreen extends StatefulWidget {
  final String userId;
  const CartScreen({super.key, required this.userId});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  CartModel? _cart;
  List<CartProductModel> _cartProducts = [];
  final formatCurrency = NumberFormat.decimalPattern('id');

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
        return;
      }
      final cartProductList = await CartProductService().getAllCartProducts(cartData.cartId);
      if (cartProductList.isEmpty) {
        print("Tidak ada produk di cart: ${cartData.cartId}");
        return;
      }
      setState(() {
        _cart = cartData;
        _cartProducts = cartProductList;
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<ProductModel?> _getProductDetail(String productId) async {
    try {
      return await ProductService().getProductsById(productId);
    } catch (e) {
      print("Error loading product detail: $e");
      return null;
    }
  }

  Future<void> _updateCart({
    required CartProductModel cartProduct,
    int? newAmount,
    bool? newIsChecked,
  }) async {
    if (_cart == null) return;
    try {
      final productDetail = await _getProductDetail(cartProduct.productId);
      if (productDetail == null) return;

      final updatedAmount = newAmount ?? cartProduct.amount;
      final updatedIsChecked = newIsChecked ?? cartProduct.isChecked;
      final newTotalPrice = updatedAmount * productDetail.price;

      await CartProductService().insertProduct(
        {
          "id": _cart!.cartId,
          "productId": cartProduct.productId,
          "amount": updatedAmount,
          "totalPrice": newTotalPrice,
          "isChecked": updatedIsChecked,
        },
        _cart!.cartId,
        cartProduct.productId,
      );

      setState(() {
        _cartProducts = _cartProducts.map((p) {
          if (p.productId == cartProduct.productId) {
            return p.copyWith(
              amount: updatedAmount,
              totalPrice: newTotalPrice,
              isChecked: updatedIsChecked,
            );
          }
          return p;
        }).toList();
      });
    } catch (e) {
      print("Error update cart: $e");
    }
  }

  Future<void> _confirmDelete(CartProductModel cartProduct) async {
    if (_cart == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Apakah Anda yakin ingin menghapus produk ini dari keranjang?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus')),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await CartProductService().deleteProduct(_cart!.cartId, cartProduct.productId);
        setState(() {
          _cartProducts.removeWhere((p) => p.productId == cartProduct.productId);
        });
        MySnackbar(context, "Produk berhasil dihapus dari keranjang");
      } catch (e) {
        print("Error deleting product: $e");
        MySnackbar(context, "Terjadi kesalahan saat menghapus produk");
      }
    }
  }

  void _confirmPayment() {
    if (_cart == null) return;

    final selected = _cartProducts.where((p) => p.isChecked).toList();
    if (selected.isEmpty) {
      MySnackbar(context, "Pilih produk yang ingin dibayar terlebih dahulu.");
      return;
    }

    double totalPayment = selected.fold(0.0, (sum, item) => sum + item.totalPrice);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Konfirmasi Pembayaran'),
        content: Text(
          'Total pembayaran Anda adalah: Rp ${formatCurrency.format(totalPayment)}',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: tambahkan logika pembayaran di sini
            },
            child: const Text('Bayar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final _screen = MediaQuery.of(context).size;

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
                  MaterialPageRoute(builder: (_) => const MainScreen()),
                );
              },
            ),
            Expanded(
              child: _cartProducts.isEmpty
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
                            MaterialPageRoute(builder: (_) => const MainScreen()),
                          );
                        },
                        child: const Text("Belanja Sekarang"),
                      ),
                    ],
                  ),
                ),
              )
                  : ListView.builder(
                itemCount: _cartProducts.length,
                itemBuilder: (context, index) {
                  final cartProduct = _cartProducts[index];
                  return FutureBuilder<ProductModel?>(
                    future: _getProductDetail(cartProduct.productId),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const SizedBox.shrink();
                      final product = snapshot.data!;
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: _screen.width * 0.2,
                              child: Checkbox(
                                value: cartProduct.isChecked,
                                onChanged: (v) => _updateCart(
                                  cartProduct: cartProduct,
                                  newIsChecked: v,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: _screen.width * 0.75,
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 4,
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
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
                                              fit: BoxFit.contain,
                                              errorBuilder: (_, __, ___) =>
                                              const Icon(Icons.broken_image, size: 100),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
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
                                                  "Harga: Rp. ${formatCurrency.format(product.price)}",
                                                  style: const TextStyle(
                                                      fontSize: 14, color: Colors.grey),
                                                ),
                                                const SizedBox(height: 8),
                                                QuantityButton(
                                                  initialAmount: cartProduct.amount,
                                                  price: product.price,
                                                  stock: product.stock,
                                                  onChanged: (newAmt) => _updateCart(
                                                    cartProduct: cartProduct,
                                                    newAmount: newAmt,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  "Total Harga: Rp. ${formatCurrency.format(cartProduct.totalPrice)}",
                                                  style:
                                                  const TextStyle(fontWeight: FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed: () => _confirmDelete(cartProduct),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.redAccent,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.delete, color: Colors.white),
                                              SizedBox(width: 8),
                                              Text("Hapus Produk",
                                                  style: TextStyle(color: Colors.white)),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _cartProducts.isEmpty
          ? const SizedBox.shrink()
          : Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _confirmPayment,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text(
            "Lanjutkan ke Pembayaran",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
