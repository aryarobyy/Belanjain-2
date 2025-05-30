import 'package:belanjain/components/colors.dart';
import 'package:belanjain/models/user_model.dart';
import 'package:belanjain/screen/auth/auth.dart';
import 'package:belanjain/screen/cart_screen.dart';
import 'package:belanjain/screen/product/add_product.dart';
import 'package:belanjain/screen/profile/user_profile.dart';
import 'package:belanjain/services/auth_service.dart';
import 'package:belanjain/services/product/cart_service.dart';
import 'package:flutter/material.dart';
import 'main_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class IndexScreen extends StatefulWidget {
  final int initialTab;
  const IndexScreen({
    super.key,
    this.initialTab = 0,
  });

  @override
  State<IndexScreen> createState() => _IndexScreenState();
}

class _IndexScreenState extends State<IndexScreen> {
  late int _currentIndex;
  bool _isSearching = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  bool _isCheckingUser = true;
  bool _isUserExist = false;
  UserModel? _currUserData;

  final GlobalKey<State> _mainScreenKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadUserAndCheck();
    _currentIndex = widget.initialTab;
  }

  Future<void> _loadUserAndCheck() async {
    const storage = FlutterSecureStorage();
    final String? userId = await storage.read(key: 'uid');

    if (userId == null || userId.isEmpty) {
      setState(() {
        _isUserExist = false;
        _isCheckingUser = false;
      });
      return;
    }

    final exists = await AuthService().isUserExist(userId);
    final userData = await AuthService().getUserById(userId);

    setState(() {
      _currUserData = userData;
      _isUserExist = exists;
      _isCheckingUser = false;
    });
  }

  void _onTapped(int index) {
    setState(() {
      _currentIndex = index;
      if (index != 0) {
        _isSearching = false;
        _searchQuery = '';
        _searchController.clear();
      }
    });
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
    });
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchQuery = '';
        _searchController.clear();
      }
    });
  }

  Widget _getCurrentWidget() {
    switch (_currentIndex) {
      case 0:
        return MainScreen(
          key: ValueKey('main_${_searchQuery}_${_isSearching}'),
          inputCategory: 'all',
          searchQuery: _searchQuery,
          isSearching: _isSearching,
        );
      case 1:
        return UserProfile(userData: _currUserData!);
      default:
        return MainScreen(
          inputCategory: 'all',
          searchQuery: _searchQuery,
          isSearching: _isSearching,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingUser) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return _isUserExist ? buildNav(context) : const AuthScreen();
  }

  Widget buildNav(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: _currentIndex == 0
            ? (_isSearching
            ? Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Cari produk...',
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              hintStyle: TextStyle(color: Colors.grey),
            ),
            style: const TextStyle(color: Colors.black),
            onChanged: _onSearchChanged,
            onSubmitted: (value) {
              _onSearchChanged(value);
            },
          ),
        )
            : const Text('Belanjain'))
            : Text(
          _getTitle(),
          style: const TextStyle(color: Colors.white),
        ),
        actions: _currentIndex == 0
            ? (_isSearching
            ? [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: _toggleSearch,
          ),
        ]
            : [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _toggleSearch,
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () {
              if (_currUserData?.userId != null) {
                CartService().postCart();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CartScreen(userId: _currUserData!.userId),
                  ),
                );
              }
            },
          ),
        ])
            : null,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: primaryColor),
              child: Text(
                'Belanjain Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              selected: _currentIndex == 0,
              onTap: () {
                _onTapped(0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              selected: _currentIndex == 1,
              onTap: () {
                _onTapped(1);
                Navigator.pop(context);
              },
            ),
            if (_currUserData?.role == 'seller')
              ListTile(
                leading: const Icon(Icons.add_box),
                title: const Text('Add Product'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddProduct(sellerData: _currUserData!),
                    ),
                  );
                },
              ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                AuthService().signOut(_currUserData!.userId);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const AuthScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: _getCurrentWidget(),
    );
  }

  String _getTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Home';
      case 1:
        return 'Profile';
      default:
        return 'Belanjain';
    }
  }
}