
import 'package:belanjain/components/colors.dart';
import 'package:belanjain/screen/auth/auth.dart';
import 'package:belanjain/screen/cart_screen.dart';
import 'package:belanjain/services/auth_service.dart';
import 'package:belanjain/services/product/cart_service.dart';
import 'package:flutter/material.dart';
import 'main_screen.dart';
import 'kamera_screen.dart';
import 'profile_screen.dart';
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
  String? _currentUserId;
  bool _isCheckingUser = true;
  bool _isUserExist = false;

  final List<Widget> widgetOptions = [];

  @override
  void initState() {
    super.initState();
    _loadUserAndCheck();
    _currentIndex = widget.initialTab;
    widgetOptions.addAll([
      MainScreen(inputCategory: 'all', searchQuery: _searchQuery, isSearching: _isSearching),
      // const KameraScreen(),
      const ProfileScreen(),
    ]);
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
    setState(() {
      _currentUserId = userId;
    });

    final exists = await AuthService().isUserExist(userId);
    setState(() {
      _isUserExist = exists;
      _isCheckingUser = false;
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
    print('Asdfghji ${_isCheckingUser}');
    print('Asdfghio ${_isUserExist}');
    print('Asdfghip ${_currentUserId}');

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
                if (_currentUserId != null) {
                  CartService().postCart();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => CartScreen(userId: _currentUserId!)),
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
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                const storage = FlutterSecureStorage();
                await storage.delete(key: 'uid');
                Navigator.of(context).popUntil((r) => r.isFirst);
              },
            ),
          ],
        ),
      ),
      body: MainScreen(
        inputCategory: 'all',
        searchQuery: _searchQuery,
        isSearching: _isSearching,
      ),
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
