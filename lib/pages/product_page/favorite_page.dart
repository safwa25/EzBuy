import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/product_model.dart'; // Ensure this import is correct

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {

  final List<Product> _favoriteProducts = [
    Product(
        name: 'Example Product 1',
        price: 19.99,
        image: 'assets/images/product1.jpg'),
    Product(
        name: 'Example Product 2',
        price: 29.99,
        image: 'assets/images/product2.jpg'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.grey.withOpacity(0.1),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.arrow_back,
                          color: Colors.black,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    "Favorites",
                    style: GoogleFonts.cairo(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 45), // Replaces the empty container
                ],
              ),
            ),
            // Here is where you would display the list of favorite products
            Expanded(
              child: _favoriteProducts.isEmpty
                  ? Center(
                child: Text(
                  "No favorite products yet!",
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
              )
                  : ListView.builder(
                itemCount: _favoriteProducts.length,
                itemBuilder: (context, index) {
                  final product = _favoriteProducts[index];
                  return ListTile(
                    leading: Image.asset(product.image, width: 50, height: 50, fit: BoxFit.cover,),
                    title: Text(product.name),
                    subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.favorite, color: Colors.red),
                      onPressed: () {
                        // Handle removing from favorites
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// A simple Product model for demonstration
class Product {
  final String name;
  final double price;
  final String image;

  Product({required this.name, required this.price, required this.image});
}