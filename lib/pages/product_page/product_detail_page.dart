import 'package:flutter/material.dart';
import 'models/product_model.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late PageController _pageController;
  int _currentImageIndex = 0;
  String selectedSize = "";
  String selectedColor = "";
  int quantity = 1;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
      ),


      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                      : Colors.black87,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {

                },
                icon: const Icon(Icons.remove_red_eye),
                label: const Text(
                  "View",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark
                      ? const Color(0xFF00E676)
                      : const Color(0xFF00C853),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${product.name} added to cart')),
                  );
                },
                child: const Text(
                  "Add to Cart",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
            SizedBox(
              height: 300,
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: product.images.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentImageIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          product.images[index],
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
                      children: List.generate(product.images.length, (index) {
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


            Text(
              "\$${product.price}",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.secondary,
              ),
            ),

            const SizedBox(height: 20),


            if (product.sizes.isNotEmpty) ...[
              Text(
                "Size",
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: product.sizes.map((size) {
                  return ChoiceChip(
                    label: Text(size),
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


            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (product.colors.isNotEmpty) ...[
                  Row(
                    children: product.colors.map((colorHex) {
                      final color = Color(
                          int.parse(colorHex.substring(1, 7), radix: 16) +
                              0xFF000000);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedColor = colorHex;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: color,
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
                ],
                DropdownButton<int>(
                  value: quantity,
                  items: List.generate(10, (index) => index + 1)
                      .map((qty) => DropdownMenuItem(
                    value: qty,
                    child: Text("$qty"),
                  ))
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


            Text(
              product.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.white70 : Colors.black87,
                height: 1.4,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
