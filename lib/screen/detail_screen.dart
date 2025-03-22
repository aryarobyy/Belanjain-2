import 'package:belanjain/components/snackbar.dart';
import 'package:belanjain/models/product/product_model.dart';
import 'package:belanjain/services/product/cartProduct_service.dart';
import 'package:belanjain/services/product/cart_service.dart';
import 'package:flutter/material.dart';

class DetailScreen extends StatefulWidget {
  final ProductModel product;
  final String userId;

  const DetailScreen({
    super.key,
    required this.product,
    required this.userId
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {

  bool _isAdd = false;
  int _amount = 0;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _addProductToCart () async {
    setState(() {
      _isAdd = true;
      _amount = 1;
    });
  }

  Future<void> _insertToCart () async {
    await CartService().postCart();
    final cart = await CartService().getCartByUserId(widget.userId);

    if(cart.cartId.isEmpty) {
      MySnackbar(context, "Terjadi kesalahan saat mengambil data keranjang");
      return;
    }

    try{
      Map<String, dynamic> data = {
        "productId": widget.product.productId,
        "amount": _amount,
        "totalPrice": widget.product.price * _amount,
      };

      await CartProductService().insertProduct(data, cart.cartId, widget.product.productId);
      MySnackbar(context, "Berhasil Menambahkan ke Keranjang");
      setState(() {
        _isAdd = false;
      });
    } catch (e) {
      print("Error to insert products: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    bool isDesktop = screenWidth > 800;
    String _category = widget.product.category.toString().split('.').last.toLowerCase();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isDesktop || isLandscape
            ? Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.product.imageUrl.isNotEmpty)
              Flexible(
                flex: 2,
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: Image.network(
                    widget.product.imageUrl,
                    height: 400,
                    errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.broken_image, size: 100),
                  ),
                ),
              ),
            const SizedBox(width: 32),
            Flexible(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "ID: ${widget.product.productId}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Title: ${widget.product.title}",
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (widget.product.desc.isNotEmpty)
                  Text(
                    "Description: ${widget.product.desc}",
                    style: const TextStyle(
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Category: ${_category}",
                    style: const TextStyle(
                      fontSize: 22,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Price: Rp ${widget.product.price.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 22,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ],
        )
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.product.imageUrl.isNotEmpty)
              Center(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: Image.network(
                    widget.product.imageUrl,
                    height: 300,
                    errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.broken_image, size: 200),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Text(
              "Title: ${widget.product.title}",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Description: ${widget.product.desc}",
              style: const TextStyle(
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Category: ${_category}",
              style: const TextStyle(
                fontSize: 18,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Price: Rp ${widget.product.price.toStringAsFixed(2)}",
              style: const TextStyle(
                fontSize: 18,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16,),
            _isAdd == false ? IconButton(
              onPressed: _addProductToCart,
              icon: const Icon(Icons.add)
            ) : Column(
              children: [
                Row(
                  children: [
                    IconButton(onPressed: () {
                      if (_amount > 1) {
                        setState(() {
                          _amount--;
                        });
                      } else {
                        return;
                      }
                      }, icon: const Icon(Icons.remove)
                    ),
                    Text('$_amount'),
                    IconButton(
                      onPressed: () {
                        if (_amount < widget.product.stock) {
                          setState(() {
                            _amount++;
                          });
                        } else {
                          return;
                        }
                      },
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    _insertToCart();
                  },
                  child: const Text("Tambah Keranjang")
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
