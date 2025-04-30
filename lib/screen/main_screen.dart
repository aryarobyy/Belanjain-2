/// File: lib/screen/main_screen.dart

import 'package:belanjain/components/colors.dart';
import 'package:belanjain/models/product/category.dart';
import 'package:belanjain/models/product/product_model.dart';
import 'package:belanjain/services/auth_service.dart';
import 'package:belanjain/services/product/cart_service.dart';
import 'package:belanjain/services/product/product_service.dart';
import 'package:belanjain/screen/product/detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';

class MainScreen extends StatefulWidget {
  final String inputCategory;
  final String searchQuery;
  final bool isSearching;

  const MainScreen({
    Key? key,
    this.inputCategory = 'all',
    this.searchQuery = '',
    this.isSearching = false,
  }) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String _currentCategory = 'all';
  String? _currentUserId;
  String? _userRole;
  List<ProductModel>? _cachedProducts;
  final formatCurrency = NumberFormat.decimalPattern('id');

  List<String> categories = ProductCategory.values.map((e) => e.value).toList();

  @override
  void initState() {
    super.initState();
    _fetchCurrentUser();
    _currentCategory = widget.inputCategory;
    _fetchProducts();
  }

  Future<void> _fetchCurrentUser() async {
    const storage = FlutterSecureStorage();
    String? userId = await storage.read(key: 'uid');
    if (userId == null || userId.isEmpty) return;
    setState(() => _currentUserId = userId);
    final role = await AuthService().getUserById(userId);
    setState(() => _userRole = role.role);
  }

  Future<void> _fetchProducts() async {
    try {
      final products = await ProductService().getProducts();
      setState(() => _cachedProducts = products);
    } catch (e) {
      debugPrint('Error fetching products: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final isSelected = _currentCategory == category;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: ChoiceChip(
                        checkmarkColor: Colors.white,
                        label: Text(category.toUpperCase()),
                        selected: isSelected ,
                        selectedColor: primaryColor,
                        backgroundColor: Colors.grey[200],
                        onSelected: (_) => setState(() => _currentCategory = category),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              // Product list
              Expanded(
                child: _cachedProducts == null
                    ? const Center(child: CircularProgressIndicator())
                    : _buildProductList(widget.searchQuery),
              ),
            ],
          ),
          if (_userRole == 'admin')
            Positioned(
              bottom: 20,
              right: 20,
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/addProduct').then((_) => _fetchProducts());
                },
                child: const Icon(Icons.add),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductList(String searchQuery) {
    final filtered = _cachedProducts!.where((p) {
      final matchesSearch = p.title.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesCategory = widget.inputCategory == 'all' ||
          p.category.toString().split('.').last.toLowerCase() == _currentCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    if (filtered.isEmpty) return const Center(child: Text('Produk masih kosong'));

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.7,
      ),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final product = filtered[index];
        return GestureDetector(
          onTap: () {
            if (_currentUserId != null) {
              Navigator.of(context)
                  .push(MaterialPageRoute(
                builder: (_) => DetailScreen(
                  product: product,
                  userId: _currentUserId!,
                ),
              ))
                  .then((_) => _fetchProducts());
            }
          },
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Image.network(
                      product.imageUrl,
                      height: 100,
                      fit: BoxFit.contain,
                      errorBuilder: (_,__,___) => const Icon(Icons.broken_image),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Icons.star, size: 16, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text('${product.rating}', style: const TextStyle(fontSize: 16)),
                  ]),
                  const SizedBox(height: 4),
                  Text('Price: Rp.${formatCurrency.format(product.price)}'),
                  const SizedBox(height: 4),
                  Text('Status: ${product.status}'),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
