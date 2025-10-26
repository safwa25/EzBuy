import 'package:ezbuy/auth/login_screen.dart';
import 'package:ezbuy/auth/signup_screen.dart';
import 'package:ezbuy/core/theme/colors.dart';
import 'package:flutter/material.dart';
import '../../main.dart'; 
import '../../utils/product_card.dart';
import 'product_detail_page.dart';
import 'Data/products_data.dart';

class Welcomescreen extends StatefulWidget {
  final bool isLoggedIn;

  const Welcomescreen({super.key, this.isLoggedIn = false});

  @override
  State<Welcomescreen> createState() => _WelcomescreenState();
}

class _WelcomescreenState extends State<Welcomescreen> {
  String selectedCategory = 'All';
  String searchQuery = '';

  final List<String> categories = [
    'All',
    'Clothes',
    'Shoes',
    'Makeup',
    'Accessories',
  ];

  void _toggleTheme() {
    final currentMode = themeNotifier.value;
    themeNotifier.value = currentMode == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
  }

  void _showLoginPrompt() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please log in to add to favorites!'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 2),
      ),
    );
  
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, mode, child) {
        final isDark = mode == ThemeMode.dark; 

        final filteredProducts = products.where((product) {
          final matchesCategory =
              selectedCategory == 'All' || product.category == selectedCategory;
          final matchesSearch =
              product.name.toLowerCase().contains(searchQuery.toLowerCase());
          return matchesCategory && matchesSearch;
        }).toList();

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Welcome ',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LoginScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDark ? AppColors.darkPrimary : AppColors.lightPrimary, 
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Login'),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const SignUpScreen()),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary), 
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Sign Up'),
                          ),
                          const SizedBox(width: 8),
                       
                          ValueListenableBuilder<ThemeMode>(
                            valueListenable: themeNotifier,
                            builder: (context, localMode, _) {
                              final localIsDark = localMode == ThemeMode.dark;
                              return Container(
                                margin: const EdgeInsets.only(right: 0),
                                decoration: BoxDecoration(
                                  color: localIsDark
                                      ? Colors.white.withOpacity(0.1)
                                      : Colors.grey.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: IconButton(
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
                                      localIsDark 
                                          ? Icons.light_mode_rounded
                                          : Icons.dark_mode_rounded,
                                      key: ValueKey(localIsDark),
                                      color: localIsDark
                                          ? Colors.amber.shade300
                                          : Colors.deepOrange.shade600,
                                      size: 26,
                                    ),
                                  ),
                                  onPressed: _toggleTheme,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    onChanged: (value) => setState(() => searchQuery = value),
                    style: TextStyle(color: isDark ? Colors.white : Colors.black), 
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      hintStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                      prefixIcon: Icon(Icons.search, color: isDark ? Colors.white70 : Colors.black54),
                      filled: true,
                      fillColor: isDark ? Colors.grey.withOpacity(0.8) : Colors.grey.withOpacity(0.15),
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        final isSelected = selectedCategory == category;

                        return GestureDetector(
                          onTap: () => setState(() => selectedCategory = category),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (isDark ? AppColors.darkPrimary : AppColors.lightPrimary)
                                  : (isDark ? Colors.grey.withOpacity(0.3) : Colors.grey.withOpacity(0.2)),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text(
                                category,
                                style: TextStyle(
                                  color: isSelected 
                                      ? Colors.white 
                                      : (isDark ? Colors.white70 : Colors.black87),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: filteredProducts.isEmpty
                        ? Center(
                            child: Text(
                              'No products found',
                              style: TextStyle(
                                fontSize: 18,
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.all(6),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.68,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                            itemCount: filteredProducts.length,
                            itemBuilder: (context, index) {
                              final product = filteredProducts[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ProductDetailPage(product: product),
                                    ),
                                  );
                                },
                                child: ProductCard(
                                  product: product,
                                  showBuyButton: false, 
                                  isLoggedIn: widget.isLoggedIn, 
                                  onFavoriteTap: _showLoginPrompt,
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}