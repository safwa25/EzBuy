import 'package:ezbuy/pages/cart/cart_services.dart';
import 'package:ezbuy/pages/cart/mycart.dart';
import 'package:flutter/material.dart';
import '../../main.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import '../favorite/favorite_page.dart';
import 'home.dart';
import '../profile/ProfilePage.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key, required bool isLoggedIn});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  int _bottomNavIndex = 0;
  final CartService _cartService = CartService();

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
        title: Text(
          _bottomNavIndex==2? "Profile":
          "Products",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 26,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        actions: [
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeNotifier,
            builder: (context, mode, _) {
              return Container(
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CartPage(),
                            ),
                          );
                        },
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Image.asset(
                              isDark
                                  ? "assets/images/orange_EB_logo.png"
                                  : "assets/images/app_icon.png",
                              width: MediaQuery.of(context).size.width * 0.1,
                            ),

                            StreamBuilder<int>(
                              stream: _cartService.cartItemCountStream(),
                              builder: (context, snapshot) {
                                int count = snapshot.data ?? 0;
                                if (count == 0) return const SizedBox();

                                return Positioned(
                                  top: 0,
                                  right: count < 10
                                      ? 0
                                      : count < 100
                                      ? -4
                                      : -16,
                                  child: StreamBuilder<int>(
                                    stream: CartService().cartItemCountStream(),
                                    builder: (context, snapshot) {
                                      final count = snapshot.data ?? 0;

                                      if (count == 0)
                                        return const SizedBox.shrink();

                                      final displayCount = count > 100
                                          ? '+100'
                                          : '$count';

                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 2,
                                          horizontal: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius: BorderRadius.circular(
                                            100,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.red.withOpacity(
                                                0.4,
                                              ),
                                              blurRadius: 6,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          displayCount,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      if(_bottomNavIndex == 0)
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
                        onPressed:  () {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (!mounted) return;
                            _toggleTheme();
                          });
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
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
      bottomNavigationBar: AnimatedBottomNavigationBar(
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
    );
  }
}
