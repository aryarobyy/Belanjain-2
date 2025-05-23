import 'package:belanjain/components/colors.dart';
import 'package:belanjain/components/snackbar.dart';
import 'package:belanjain/models/product/product_model.dart';
import 'package:belanjain/models/user_model.dart';
import 'package:belanjain/screen/cart_screen.dart';
import 'package:belanjain/screen/index.dart';
import 'package:belanjain/screen/comment/comment_section.dart';
import 'package:belanjain/services/product/cartProduct_service.dart';
import 'package:belanjain/services/product/cart_service.dart';
import 'package:belanjain/widgets/header.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DetailScreen extends StatefulWidget {
  final ProductModel product;
  UserModel? userData;

  DetailScreen({
    super.key,
    required this.product,
    required this.userData
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final formatCurrency = NumberFormat.decimalPattern('id');
  bool _isAdd = false;
  int _amount = 0;
  final ScrollController _scrollController = ScrollController();

  String get _title => widget.product.title;
  String get _description => widget.product.desc;
  double get _price => widget.product.price;
  int get _stock => widget.product.stock;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _addProductToCart() async {
    setState(() {
      _isAdd = true;
      _amount = 1;
    });
  }

  Future<void> _insertToCart() async {
    await CartService().postCart();
    final cart = await CartService().getCartByUserId(widget.userData!.userId);

    if(cart.cartId.isEmpty) {
      MySnackbar(context, "Terjadi kesalahan saat mengambil data keranjang");
      return;
    }

    try{
      final tp = widget.product.price * _amount;
      Map<String, dynamic> data = {
        "productId": widget.product.productId,
        "amount": _amount,
        "totalPrice":  tp,
        "isChecked": false,
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

  String getCategoryName(String category) {
    String formattedCategory = category.toString().split('.').last.toLowerCase();
    return formattedCategory[0].toUpperCase() + formattedCategory.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    String category = getCategoryName(widget.product.category.toString());
    Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Column(
            children: [
                MyHeader(
                    title: widget.product.title,
                    onTapLeft: (){
                       Navigator.push(context, MaterialPageRoute(builder: (_) => const IndexScreen(initialTab: 0,)));
                    }
                ),
              Expanded(
                child: ListView(
                controller: _scrollController,
                children: [
                  if (widget.product.imageUrl.isNotEmpty)
                    const SizedBox(height: 14,),
                    Container(
                      width: double.infinity,
                      height: 300,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                      ),
                      child: widget.product.imageUrl.isNotEmpty
                          ? Image.network(
                        widget.product.imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                        const Center(child: Icon(Icons.image_not_supported, size: 80, color: Colors.grey)),
                      )
                          : const Center(child: Icon(Icons.image_not_supported, size: 80, color: Colors.grey)),
                    ),

                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),

                        Text(
                          "Rp ${formatCurrency.format(_price)}",
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 16),

                        Wrap(
                          children: [
                            Chip(
                              label: Text(
                                category,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                              backgroundColor: primaryColor,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                            ),
                            const SizedBox(width: 8),
                            Chip(
                              label: Text(
                                "Stock: $_stock",
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 12,
                                ),
                              ),
                              backgroundColor: Colors.grey[200],
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Description",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Divider(),
                        const SizedBox(height: 8),
                        Text(
                          _description,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    color: Colors.white,
                    child: SizedBox(
                      height: 200,
                      child: CommentSection(
                        userData: widget.userData!,
                        product: widget.product,
                      ),
                    ),
                  ),

                  const SizedBox(height: 80),
                  ],
           ),
         ),
        ],
      ),
    ),

      bottomSheet: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, -1),
              ),
            ],
          ),
          child: _isAdd
              ? Row(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: primaryColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {
                          if(_amount < 1){
                            _isAdd = false;
                          }
                          if (_amount > 1) {
                            setState(() => _amount--);
                          }
                        },
                        icon: const Icon(Icons.remove_circle, color: Colors.red),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      Text(
                        '$_amount',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        onPressed: () {
                          if (_amount < _stock) {
                            setState(() => _amount++);
                          }
                        },
                        icon: const Icon(Icons.add_circle, color: secondaryColor),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 3,
                child: ElevatedButton(
                  onPressed: _insertToCart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Tambah ke Keranjang",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          )
              : Row(
            children: [
              // Expanded(
              //   flex: 1,
              //   child: OutlinedButton.icon(
              //     onPressed: () {
              //       // Add to wishlist functionality
              //     },
              //     icon: const Icon(Icons.favorite_border),
              //     label: const Text("Wishlist"),
              //     style: OutlinedButton.styleFrom(
              //       foregroundColor: AppColors.primaryColor,
              //       side: const BorderSide(color: AppColors.primaryColor),
              //       padding: const EdgeInsets.symmetric(vertical: 12),
              //     ),
              //   ),
              // ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: _addProductToCart,
                  icon: const Icon(Icons.shopping_cart_outlined),
                  label: const Text("Beli Sekarang"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}