import 'package:flutter/material.dart';
import 'models/product_model.dart';
import 'package:google_fonts/google_fonts.dart';

import 'mycart.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;
  final bool isLoggedIn ;

  const ProductDetailPage({super.key, required this.product,this.isLoggedIn=false});

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
        title: Text(
          product.name,
          style: GoogleFonts.cairo(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),


      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 18,top: 14),
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
                      : Color(0xFF0026CC),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {

                },
                icon: const Icon(Icons.remove_red_eye,size: 24,),
                label:  Text(
                  "View",
                  style: GoogleFonts.cairo(fontSize:18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark
                      ? const Color(0xFFFF9900)
                      : const Color(0xFFFF9900),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
               onPressed: () {
         if (!widget.isLoggedIn) {
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(
          content: Text('Please login to add items to cart'),
           backgroundColor: Colors.redAccent,
           duration: Duration(seconds: 2),
          ),
          );
        } else {
         Navigator.push(context, MaterialPageRoute(builder: (context)=>CartPage()));
        }
      },

                child:  Text(
                  "Add to Cart",
                  style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold),
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
              style: GoogleFonts.cairo(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color:isDark? Colors.amber.shade600 : Colors.amber.shade900,
              ),
            ),

            const SizedBox(height: 20),


            if (product.sizes.isNotEmpty) ...[
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
                children: product.sizes.map((size) {
                  return ChoiceChip(
                    label: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      child: Text(
                        size,
                        style: GoogleFonts.cairo(fontSize: 16,fontWeight: FontWeight.bold),
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
                          width: 35,
                          height: 35,
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
                    child: Text(
                      "$qty",
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
              "Description",
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              product.description,
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
