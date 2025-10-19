import 'package:ezbuy/pages/product_page/models/product_model.dart';
import 'package:flutter/material.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
  static List<Product> cardProducts = [];
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Cart')),
      body: CartPage.cardProducts.isEmpty
          ? const Center(child: Text('No products in cart'))
          : ListView.builder(
              itemCount: CartPage.cardProducts.length,
              itemBuilder: (context, index) {
                final product = CartPage.cardProducts[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xfff0f0f0),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2), // shadow color
                          blurRadius: 4, // how soft the shadow is
                          spreadRadius: 1, // how much it spreads
                          offset: const Offset(0, 4), // position: (x, y)
                        ),
                      ],
                    ),

                    padding: EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ProductCartImage(product: product),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(product.name),
                            Text(product.description),
                          ],
                        ),
                        Text("${product.price}"),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class ProductCartImage extends StatelessWidget {
  const ProductCartImage({
    super.key,
    required this.product,
  });

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xffffffff),
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          image: AssetImage("${product.images}"),
          fit: BoxFit.cover,
        ),
      ),
      width: 100,
      height: 100,
    );
  }
}
