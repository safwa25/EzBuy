import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ezbuy/pages/cart/cart_services.dart';
import 'package:flutter/material.dart';
import 'models/product_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../cart/mycart.dart';

class ProductDetailPage extends StatefulWidget {
  final String productId;
  final bool isLoggedIn;

  const ProductDetailPage({
    super.key,
    required this.productId,
    this.isLoggedIn = false,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late PageController _pageController;
  int _currentImageIndex = 0;
  String selectedSize = "";
  String selectedColor = "";
  int quantity = 1;

  final _cartService = CartService();
  final _auth = FirebaseAuth.instance;

  final Map<String, Color> colorMap = {
    'Black': Colors.black,
    'Blue': Colors.blue,
    'Red': Colors.red,
    'White': Colors.white,
    'Pink': Colors.pink,
    'Brown': Colors.brown,
    'Green': Colors.green,
    'Cream': Color(0xFFFFFDD0),
    'Beige': Color(0xFFF5F5DC),
    'Black and Blue': Colors.blueGrey,
    // Add more colors here as needed
  };


  Product? product;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    fetchProduct();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> fetchProduct() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId)
          .get();

      if (doc.exists) {
        setState(() {
          product = Product.fromFirestore(doc);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product not found')),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading product: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (product == null) {
      return const Scaffold(
        body: Center(child: Text('Product not found')),
      );
    }

    final currentProduct = product!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          currentProduct.name,
          style: GoogleFonts.cairo(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: 18,
          top: 14,
        ),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark
                      ? Colors.white.withOpacity(0.15)
                      : const Color(0xFF0026CC),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {},
                icon: const Icon(Icons.remove_red_eye, size: 24),
                label: Text(
                  "View",
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF9900),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () async {
                  final user = _auth.currentUser;
                  if (user == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please login to add items to cart'),
                        backgroundColor: Colors.redAccent,
                        duration: Duration(seconds: 2),
                      ),
                    );
                    return;
                  }

                  if (selectedColor.isEmpty || selectedSize.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select a color and size'),
                        backgroundColor: Colors.redAccent,
                        duration: Duration(seconds: 2),
                      ),
                    );
                    return;
                  }

                  try {
                    for (int i = 0; i < quantity; i++) {
                      await _cartService.addToCart(currentProduct);
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Item added to cart successfully!'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                      ),
                    );

                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CartPage()),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error adding to cart: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: Text(
                  "Add to Cart",
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Images ---
            SizedBox(
              height: 300,
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: currentProduct.images.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentImageIndex = index.clamp(0, currentProduct.images.length - 1);
                      });
                    },
                    itemBuilder: (context, index) {
                      if (index >= currentProduct.images.length) {
                        return const SizedBox();
                      }
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          currentProduct.images[index],
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      );
                    },
                  ),
                  Positioned(
                    bottom: 10,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(currentProduct.images.length, (index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentImageIndex == index ? 10 : 6,
                          height: _currentImageIndex == index ? 10 : 6,
                          decoration: BoxDecoration(
                            color: _currentImageIndex == index
                                ? theme.colorScheme.primary
                                : Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // --- Price ---
            Text(
              "\$${currentProduct.price}",
              style: GoogleFonts.cairo(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.amber.shade600 : Colors.amber.shade900,
              ),
            ),
            const SizedBox(height: 20),

            // --- Colors ---
            if (currentProduct.colors.isNotEmpty) ...[
              Text(
                "Color",
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: currentProduct.colors.map((colorHex) {
                  final colorValue = colorMap[colorHex] ?? Colors.grey; // fallback
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedColor = colorHex;
                        selectedSize = "";
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                        color: colorValue,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selectedColor == colorHex
                              ? theme.colorScheme.primary
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
            ],

            // --- Sizes ---
            if (currentProduct.sizes.isNotEmpty) ...[
              Text(
                "Size",
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: currentProduct.sizes.map((size) {
                  return ChoiceChip(
                    label: Text(
                      size,
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    selected: selectedSize == size,
                    onSelected: (_) {
                      setState(() {
                        selectedSize = size;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
            ],

            // --- Quantity ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Quantity",
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                DropdownButton<int>(
                  value: quantity,
                  items: List.generate(10, (index) => index + 1)
                      .map(
                        (qty) => DropdownMenuItem(
                      value: qty,
                      child: Text(
                        "$qty",
                        style: GoogleFonts.cairo(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      quantity = value!;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // --- Description ---
            Text(
              "Description",
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              currentProduct.description,
              style: GoogleFonts.cairo(
                color: isDark ? Colors.white70 : Colors.black87,
                height: 1.4,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
