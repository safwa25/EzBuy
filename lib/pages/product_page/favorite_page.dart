import 'package:flutter/material.dart';
import '../product_page/models/product_model.dart';
import '../../utils/product_card.dart';

class FavoritePage extends StatefulWidget {
  static List<Product> favoriteProducts = [];

  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  @override
  Widget build(BuildContext context) {
    final favorites = FavoritePage.favoriteProducts;

    return Scaffold(
 
      body: favorites.isEmpty
          ? const Center(
              child: Text(
                "No favorites yet!",
                style: TextStyle(fontSize: 18),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: favorites.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.7,
              ),
              itemBuilder: (context, index) {
                final product = favorites[index];
                return ProductCard(
                  product: product,
                  showBuyButton: true,
                  isLoggedIn: true,
                );
              },
            ),
    );
  }
}