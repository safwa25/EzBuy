import 'package:ezbuy/pages/cart/mycart.dart';
import 'package:flutter/material.dart';
import '../../main.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'favorite_page.dart';
import 'home.dart';
import 'ProfilePage.dart';


class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key, required bool isLoggedIn});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  int _bottomNavIndex = 0;

  final List<Widget> _pages = [
    const ProductGridView(isLoggedIn: true),
    const FavoritePage(),
    const ProfilePage(),
  ];

  void _toggleTheme() {
    final currentMode = themeNotifier.value;
    themeNotifier.value = currentMode == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF1E1E1E), const Color(0xFF2D2D2D)]
                  : [Colors.white, Colors.grey.shade50],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Products",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 26,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeNotifier,
            builder: (context, mode, _) {
              return Container(
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color:
                      isDark 
                      ? Colors.white.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CartPage()),
                        );
                      },
                      icon: Icon(Icons.add_shopping_cart_rounded),
                    ),
                    SizedBox(width: 8),
                    IconButton(
                      icon: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) {
                          return RotationTransition(
                            turns: animation,
                            child: FadeTransition(
                              opacity: animation,
                              child: child,
                            ),
                          );
                        },
                        child: Icon(
                          isDark
                              ? Icons.light_mode_rounded
                              : Icons.dark_mode_rounded,
                          key: ValueKey(isDark),
                          color: mode == ThemeMode.dark
                              ? Colors.amber.shade300
                              : Colors.deepOrange.shade600,
                          size: 26,
                        ),
                      ),
                      onPressed: _toggleTheme,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.05, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: _pages[_bottomNavIndex],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [Colors.orange.shade400, Colors.deepOrange.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: FloatingActionButton(
          backgroundColor: Colors.transparent,
          elevation: 0,
          shape: const CircleBorder(),
          child: const Icon(Icons.home_rounded, size: 36, color: Colors.white),
          onPressed: () {
            setState(() {
              _bottomNavIndex = 0;
            });
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: AnimatedBottomNavigationBar(
          iconSize: 36,
          activeColor: isDark
              ? Colors.orange.shade400
              : Colors.deepOrange.shade600,
          inactiveColor: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          leftCornerRadius: 32,
          rightCornerRadius: 32,
          elevation: 0,
          icons: const [Icons.favorite_rounded, Icons.person_rounded],
          activeIndex: _bottomNavIndex == 0 ? -1 : _bottomNavIndex - 1,
          gapLocation: GapLocation.center,
          notchSmoothness: NotchSmoothness.verySmoothEdge,
          onTap: (index) {
            setState(() {
              _bottomNavIndex = index + 1;
            });
          },
        ),
      ),
    );
  }
}
