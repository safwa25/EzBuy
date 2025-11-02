import 'package:ezbuy/pages/cart/cart_services.dart';
import 'package:ezbuy/pages/cart/checkout_bar.dart';
import 'package:ezbuy/pages/product_page/models/product_model.dart';
import 'package:flutter/material.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final CartService _cartService = CartService();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('My Cart'), centerTitle: true),

      // 🔥 عرض البيانات من Firebase مباشرة
      body: StreamBuilder<List<Product>>(
        stream: _cartService.getCartItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No products in cart'));
          }

          final cartItems = snapshot.data!;

          return ListView.builder(
            itemCount: cartItems.length,
            itemBuilder: (context, index) {
              final product = cartItems[index];

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 8,
                  ),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color.fromARGB(255, 45, 45, 45)
                        : const Color(0xfff0f0f0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: product.images[0].startsWith('http')
                            ? Image.network(
                                product.images[0],
                                width: MediaQuery.of(context).size.width * 0.15,
                                fit: BoxFit.cover,
                              )
                            : Image.asset(
                                product.images[0],
                                width: MediaQuery.of(context).size.width * 0.15,
                                fit: BoxFit.cover,
                              ),
                      ),

                      const SizedBox(width: 8),

                     
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Ref. ${product.id}",
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      
                      Flexible(
                        flex: 2,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _quantityButton(Icons.remove, () async {
                                  await _cartService.decreaseQuantity(product);
                                }),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  child: Text(
                                    '${product.quantity}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                _quantityButton(Icons.add, () async {
                                  await _cartService.addToCart(product);
                                }),
                              ],
                            ),
                          ],
                        ),
                      ),

                     
                      Flexible(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "\$${product.totalPrice.toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Colors.grey,
                                size: 20,
                              ),
                              onPressed: () async {
                                await _cartService.removeFromCart(product.id);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),

      
      bottomNavigationBar: StreamBuilder<double>(
        stream: _cartService.getTotalPrice(),
        builder: (context, snapshot) {
          final total = snapshot.data ?? 0.0;
          return CheckoutBar(isDark: isDark, total: total);
        },
      ),
    );
  }

  Widget _quantityButton(IconData icon, VoidCallback onPressed) {
    return Container(
      width: 32,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      child: IconButton(icon: Icon(icon, size: 18), onPressed: onPressed),
    );
  }
}
