import 'package:belanjain/components/colors.dart';
import 'package:belanjain/models/product/category.dart';
import 'package:belanjain/models/product/product_model.dart';
import 'package:belanjain/models/user_model.dart';
import 'package:belanjain/services/auth_service.dart';
import 'package:belanjain/services/product/product_service.dart';
import 'package:belanjain/screen/product/detail_screen.dart';
import 'package:belanjain/widgets/product_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';

class MainScreen extends StatefulWidget {
  final String inputCategory;
  final String searchQuery;
  final bool isSearching;

  const MainScreen({
    super.key,
    this.inputCategory = 'all',
    this.searchQuery = '',
    this.isSearching = false,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String _currentCategory = 'all';
  UserModel? _currentUser;
  List<ProductModel>? _cachedProducts;
  bool _isLoading = true;

  List<String> categories =
  ProductCategory.values.map((e) => e.value).toList();

  @override
  void initState() {
    super.initState();
    _fetchCurrentUser();
    _currentCategory = widget.inputCategory;
    _fetchProducts();
  }

  Future<void> _fetchCurrentUser() async {
    try {
      const storage = FlutterSecureStorage();
      String? userId = await storage.read(key: 'uid');
      if (userId == null) {
        setState(() => _isLoading = false);
        return;
      }
      final user = await AuthService().getUserById(userId);
      setState(() {
        _currentUser = user;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching user: $e');
      setState(() => _isLoading = false);
    }
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
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              _buildCategoryChips(),
              const SizedBox(height: 16),
              Expanded(
                child: _cachedProducts == null
                    ? const Center(child: CircularProgressIndicator())
                    : _buildProductList(widget.searchQuery),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
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
              label: Text(
                category.toUpperCase(),
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
              selected: isSelected,
              selectedColor: primaryColor,
              backgroundColor: Colors.grey[200],
              onSelected: (_) => setState(() => _currentCategory = category),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductList(String searchQuery) {
    final filtered = _cachedProducts!.where((p) {
      final matchesSearch =
      p.title.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesCategory = _currentCategory == 'all' ||
          p.category.toString().split('.').last.toLowerCase() == _currentCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    if (filtered.isEmpty) {
      return const Center(child: Text('Produk masih kosong'));
    }

    return ProductTile(
      products: filtered,
      onProductTap: _handleProductTap,
    );
  }

  void _handleProductTap(ProductModel product) {
    if (_currentUser != null) {
      Navigator.of(context)
          .push(MaterialPageRoute(
        builder: (_) => DetailScreen(
          product: product,
          userData: _currentUser!,
        ),
      ))
          .then((_) => _fetchProducts());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login Untuk melihat detail')),
      );
    }
  }
}