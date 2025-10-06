import 'package:flutter/material.dart';
import '../../main.dart';
import 'product_detail_page.dart';
import 'Data/products_data.dart';
import 'models/product_model.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'favorite_page.dart';
import 'home.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  int _bottomNavIndex = 0;

  final List<Widget> _pages = [
    const ProductGridView(),
    const FavoritePage(),
    const Center(child: Text("Profile Page")),
  ];

  void _toggleTheme() {
    themeNotifier.value =
    themeNotifier.value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          "Products",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        actions: [
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeNotifier,
            builder: (context, mode, _) {
              return Container(
                margin: const EdgeInsets.only(right: 8),
                child: IconButton(
                  icon: Icon(
                    mode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode,
                    color: mode == ThemeMode.dark ? Colors.amber : Colors.black45,
                  ),
                  onPressed: _toggleTheme,
                ),
              );
            },
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _pages[_bottomNavIndex],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.4),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: FloatingActionButton(
          backgroundColor: Colors.orange,
          elevation: 12,
          shape: const CircleBorder(),
          child: Icon(
            Icons.home_rounded,
            size: 40,
            color: Colors.white,
          ),
          onPressed: () {
            setState(() {
              _bottomNavIndex = 0;
            });
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar(
        iconSize: 40,
        activeColor: isDark ? Colors.orange : Colors.deepOrange.shade600,
        inactiveColor: isDark ? Colors.white54 : Colors.grey.shade600,
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        leftCornerRadius: 32,
        rightCornerRadius: 32,
        elevation: 8,
        icons: const [
          Icons.favorite_rounded,
          Icons.person_rounded,
        ],
        activeIndex: _bottomNavIndex == 0 ? -1 : _bottomNavIndex - 1,
        gapLocation: GapLocation.center,
        notchSmoothness: NotchSmoothness.verySmoothEdge,
        onTap: (index) {
          setState(() {
            _bottomNavIndex = index + 1;
          });
        },
      ),
    );
  }
}

