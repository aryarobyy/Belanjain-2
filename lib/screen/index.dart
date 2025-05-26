
import 'package:belanjain/components/colors.dart';
import 'package:belanjain/models/user_model.dart';
import 'package:belanjain/screen/auth/auth.dart';
import 'package:belanjain/screen/cart_screen.dart';
import 'package:belanjain/screen/product/add_product.dart';
import 'package:belanjain/screen/profile/seller_profile.dart';
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

  final List<Widget> widgetOptions = [];

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

      widgetOptions.clear();
      widgetOptions.addAll([
        MainScreen(inputCategory: 'all', searchQuery: _searchQuery, isSearching: _isSearching),
        // const KameraScreen(),
        _currUserData!.role == 'seller' ?  SellerProfile(userId: _currUserData!.userId,) : UserProfile(userId: _currUserData!.userId),
      ]);
    });
  }

  void _onTapped(int index) {
    setState(() {
      _currentIndex = index;
      _isSearching = false;
      _searchQuery = '';
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingUser) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return _isUserExist
        ? buildNav(context)
        : const AuthScreen();
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
            ? TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Search...'),
          onChanged: (v) => setState(() => _searchQuery = v),
        )
          : const Text('Belanjain'))
          : Text(
            _getTitle(),
          style: const TextStyle(
            color: Colors.white
          ),
        ),
        actions: _currentIndex == 0
            ? (_isSearching
            ? [
          IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => setState(() {
                _isSearching = false;
                _searchQuery = '';
                _searchController.clear();
              })),
        ]
            : [
          IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => setState(() => _isSearching = true)),
          IconButton(
              icon: const Icon(Icons.shopping_cart_outlined),
              onPressed: () {
                if (_currUserData?.userId != null) {
                  CartService().postCart();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CartScreen(userId: _currUserData!.userId)),
                  );
                }
              }),
        ])
            : null,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: primaryColor),
              child: Text('Belanjain Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
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
            // ListTile(
            //   leading: const Icon(Icons.camera_alt),
            //   title: const Text('Kamera'),
            //   selected: _currentIndex == 1,
            //   onTap: () {
            //     _onTapped(1);
            //     Navigator.pop(context);
            //   },
            // ),
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
                    MaterialPageRoute(builder: (_) => AddProduct(sellerData: _currUserData!)), // sesuaikan
                  );
                },
              ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                const storage = FlutterSecureStorage();
                await storage.delete(key: 'uid');
                Navigator.push(context, MaterialPageRoute(builder: (_) => AuthScreen()));
              },
            ),
          ],
        ),
      ),
      body: widgetOptions[_currentIndex]
    );
  }

  String _getTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Home';
      // case 1:
      //   return 'Kamera';
      case 1:
        return 'Profile';
      default:
        return 'Belanjain';
    }
  }
}
