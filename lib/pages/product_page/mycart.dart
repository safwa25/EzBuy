import 'package:flutter/material.dart';

class Product1 {
  final String name;
  final String subtitle;
  final double price;
  final String imageUrl;
  int quantity;

  Product1({
    required this.name,
    required this.subtitle,
    required this.price,
    required this.imageUrl,
    this.quantity = 1,
  });
}

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final List<Product1> products = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Cart')),
      body: products.isEmpty
          ? const Center(child: Text('No products in cart'))
          : ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return ListTile(
                  title: Text(product.name),
                  subtitle: Text(product.subtitle),
                  trailing: Text('\$${product.price.toStringAsFixed(2)}'),
                );
              },
            ),
    );
  }
}