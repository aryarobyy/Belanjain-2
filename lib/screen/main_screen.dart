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
  List<ProductModel>? _allProducts;
  List<ProductModel>? _displayedProducts;
  bool _isLoading = true;

  List<String> categories = ProductCategory.values.map((e) => e.value).toList();

  @override
  void initState() {
    super.initState();
    _currentCategory = widget.inputCategory;
    _fetchCurrentUser();
    _fetchProducts();
  }

  @override
  void didUpdateWidget(covariant MainScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery ||
        oldWidget.isSearching != widget.isSearching ||
        oldWidget.inputCategory != widget.inputCategory) {
      _currentCategory = widget.inputCategory;
      _filterProducts();
    }
  }

  Future<void> _fetchCurrentUser() async {
    try {
      const storage = FlutterSecureStorage();
      String? userId = await storage.read(key: 'uid');
      if (userId == null) return;

      final user = await AuthService().getUserById(userId);
      setState(() {
        _currentUser = user;
      });
    } catch (e) {
      debugPrint('Error fetching user: $e');
    }
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<ProductModel> products;

      if (widget.isSearching && widget.searchQuery.isNotEmpty) {
        final allProducts = await ProductService().getProducts();
        products = allProducts.where((product) =>
            product.title.toLowerCase().contains(widget.searchQuery.toLowerCase())
        ).toList();
      } else {
        products = await ProductService().getProducts();
      }

      setState(() {
        _allProducts = products;
      });

      _filterProducts();

    } catch (e) {
      debugPrint('Error fetching products: $e');
      setState(() {
        _allProducts = [];
        _displayedProducts = [];
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterProducts() {
    if (_allProducts == null) return;

    List<ProductModel> filtered = _allProducts!.where((product) {
      // Category filter
      final matchesCategory = _currentCategory == 'all' ||
          product.category.toString().split('.').last.toLowerCase() == _currentCategory.toLowerCase();

      bool matchesSearch = true;
      if (!widget.isSearching && widget.searchQuery.isNotEmpty) {
        matchesSearch = product.title.toLowerCase().contains(widget.searchQuery.toLowerCase());
      }

      return matchesCategory && matchesSearch;
    }).toList();

    setState(() {
      _displayedProducts = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                widget.isSearching ? 'Searching products...' : 'Loading products...',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          _buildCategoryChips(),
          Expanded(
            child: _displayedProducts == null
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Loading products...',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
                : _buildProductList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SizedBox(
        height: 70,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          scrollDirection: Axis.horizontal,
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final isSelected = _currentCategory == category;
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _currentCategory = category;
                    });
                    _filterProducts();
                  },
                  borderRadius: BorderRadius.circular(25),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(
                        colors: [
                          primaryColor,
                          primaryColor.withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                          : null,
                      color: isSelected ? null : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(25),
                      border: isSelected
                          ? null
                          : Border.all(
                        color: Colors.grey.withOpacity(0.2),
                        width: 1,
                      ),
                      boxShadow: isSelected
                          ? [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isSelected)
                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            child: const Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        Text(
                          category.toUpperCase(),
                          style: TextStyle(
                            color: isSelected ? Colors.white : const Color(0xFF64748B),
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            fontSize: 13,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProductList() {
    if (_displayedProducts!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Icon(
                      widget.isSearching ? Icons.search_off : Icons.shopping_basket_outlined,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.isSearching
                        ? 'Tidak ada hasil pencarian'
                        : 'Produk masih kosong',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.isSearching
                        ? 'Coba kata kunci lain atau ubah kategori'
                        : 'Belum ada produk di kategori ini',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return ProductTile(
      products: _displayedProducts!,
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
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.login, color: Colors.white, size: 20),
              SizedBox(width: 12),
              Text(
                'Login untuk melihat detail',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          backgroundColor: Colors.orange[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }
}