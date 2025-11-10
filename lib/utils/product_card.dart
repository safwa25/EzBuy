import 'package:ezbuy/pages/cart/cart_services.dart';
import 'package:flutter/material.dart';
import '../pages/product_page/product_detail_page.dart';
import '../pages/product_page/models/product_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final bool showBuyButton;
  final bool isLoggedIn;

  const ProductCard({
    super.key,
    required this.product,
    this.showBuyButton = true,
    this.isLoggedIn = false,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  late bool isFavorite;
  final cartService = CartService();
  final userId = FirebaseAuth.instance.currentUser?.uid;
  final firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    isFavorite = widget.product.isFavorite;
  }

  Future<void> toggleFavorite() async {
    if (userId == null) return;

    final favRef = firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(widget.product.id);

    try {
      if (isFavorite) {
        await favRef.delete();
      } else {
        await favRef.set(widget.product.toMap());
      }

      setState(() {
        isFavorite = !isFavorite;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update favorites: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(
                productId: widget.product.id, isLoggedIn: widget.isLoggedIn),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                flex: 2,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                        bottom: Radius.circular(20),
                      ),
                      child: Image.network(
                        widget.product.images[0],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(
                            isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: 24,
                            color: isFavorite ? Colors.red : Colors.grey,
                          ),
                          onPressed: toggleFavorite,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "\$${widget.product.price}",
                            style: TextStyle(
                              color: isDark
                                  ? Colors.blueAccent.withOpacity(0.8)
                                  : const Color(0xFF0026CC),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (widget.showBuyButton)
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.add_shopping_cart,
                                  size: 20,
                                  color: Colors.orange,
                                ),
                                onPressed: () async {
                                  try {
                                    await cartService.addToCart(widget.product);

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content:
                                            Text("Product added to cart!"),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            "Failed to add to cart: $e"),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
