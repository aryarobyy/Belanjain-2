import 'package:flutter/material.dart';
import 'main_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'title': 'Belanjain',
      'subtitle': 'Nikmati Diskon yang besar dari belanjain',
      'image': 'assets/images/shopping1.png',
    },
    {
      'title': 'Belanjain',
      'subtitle': 'Banyak Barang Menarik',
      'image': 'assets/images/shopping2.png',
    },
    {
      'title': 'Belanjain',
      'subtitle': 'Jangan Lewatkan Penawaran Terbaik',
      'image': 'assets/images/shopping3.png',
    },
  ];

  void _nextPage() {
    setState(() {
      if (_currentIndex < _pages.length - 1) {
        _currentIndex += 1;
      } else if (_currentIndex == _pages.length) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const MainScreen(inputCategory: "all"),
          ),
        );
      }
    });
  }

  void _previousPage() {
    setState(() {
      if (_currentIndex > 0) {
        _currentIndex -= 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Belanjain')),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                _pages[_currentIndex]['title'],
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(_pages[_currentIndex]['subtitle']),
              ),
              Flexible(
                child: SizedBox(
                  height: 600,
                  child: Image.asset(
                    _pages[_currentIndex]['image'],
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text('Halaman: ${_currentIndex + 1}'),
              ),
              const SizedBox(height: 20),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Center(
                        child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width < 600
                                  ? 130
                                  : 200,
                              child: ElevatedButton(
                                onPressed: _currentIndex > 0 ? _previousPage : null,
                                child: const Text('Kembali'),
                              ),
                            )),
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width < 600
                                ? 130
                                : 200,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_currentIndex < _pages.length - 1) {
                                  _nextPage();
                                } else {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => const MainScreen(inputCategory: "All"),
                                    ),
                                  );
                                }
                              },
                              child: const Text('Lanjut'),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
