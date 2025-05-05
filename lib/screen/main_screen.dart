import 'package:belanjain/components/colors.dart';
import 'package:belanjain/models/product/category.dart';
import 'package:belanjain/models/product/product_model.dart';
import 'package:belanjain/models/user_model.dart';
import 'package:belanjain/services/auth_service.dart';
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
  final formatCurrency = NumberFormat.decimalPattern('id');
  bool _isLoading = true;

  List<String> categories = ProductCategory.values.map((e) => e.value).toList();

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
      if(userId == null) {
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
          if (_currentUser != null && _currentUser!.role == 'seller')
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
    final screenWidth = MediaQuery.of(context).size.width;
    final int crossAxisCount;
    if (screenWidth < 360) {
      crossAxisCount = 1;
    } else if (screenWidth < 480) {
      crossAxisCount = 2;
    } else {
      crossAxisCount = 3;
    }

    const spacing = 12.0;

    final itemWidth = (screenWidth - (spacing * (crossAxisCount + 1))) / crossAxisCount;
    final itemHeight = itemWidth * 1.2;
    final aspectRatio = itemWidth / itemHeight;

    final filtered = _cachedProducts!.where((p) {
      final matchesSearch = p.title.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesCategory = _currentCategory == 'all' ||
          p.category.toString().split('.').last.toLowerCase() == _currentCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    if (filtered.isEmpty) {
      return const Center(child: Text('Produk masih kosong'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(spacing),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: aspectRatio,
      ),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final product = filtered[index];
        return _buildProductCard(product, screenWidth);
      },
    );
  }

  Widget _buildProductCard(ProductModel product, double screenWidth) {
    final bool isSmall = screenWidth < 360;
    final bool isMedium = screenWidth >= 360 && screenWidth < 480;

    return Material(
      color: Colors.grey[300],
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () {
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
        },
        child: Card(
          color: Colors.grey[100],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: ClipRRect(
                    child: Image.network(
                      product.imageUrl,
                      height: isSmall
                          ? 80
                          : isMedium
                          ? 100
                          : 120,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  product.title,
                  style: TextStyle(
                    fontSize: isSmall
                        ? 12
                        : isMedium
                        ? 14
                        : 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Rp.${formatCurrency.format(product.price)}',
                  style: TextStyle(
                    fontSize: isSmall
                        ? 12
                        : isMedium
                        ? 13
                        : 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, size: 16, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text('${product.rating}', style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


}