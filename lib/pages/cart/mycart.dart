import 'package:ezbuy/pages/cart/checkout_bar.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
                    margin: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 8,
                    ),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color.fromARGB(255, 45, 45, 45) : const Color(0xfff0f0f0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                     
                    
                      children: [
                        // 🖼 Product Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            product.images[0],
                            width: MediaQuery.of(context).size.width * 0.15,
                            fit: BoxFit.cover,
                          ),
                        ),

                        SizedBox(width: 8,),

                        // 📄 Product Info
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

                        

                        // 🔢 Quantity Buttons
                        Flexible(
                          flex: 2,
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _quantityButton(Icons.remove, () {
                                    setState(() {
                                      if (product.quantity > 1) product.quantity--;
                                    });
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
                                  _quantityButton(Icons.add, () {
                                    setState(() {
                                      product.quantity++;
                                    });
                                  }),
                                ],
                              ),
                            ],
                          ),
                        ),

                

                        // 💰 Price + Delete Icon (بشكل مرن)
                        Flexible(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "\$${(product.price * product.quantity).toStringAsFixed(2)}",
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
                                onPressed: () {
                                  setState(() {
                                    CartPage.cardProducts.removeAt(index);
                                  });
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
            ),
      bottomNavigationBar: CheckoutBar(isDark: isDark),
    );
  }
}

Widget _quantityButton(IconData icon, VoidCallback onPressed) {
  return Container(
    width: 32,
    
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      // color: Colors.grey.shade300,
    ),
    child: IconButton(icon: Icon(icon, size: 18), onPressed: onPressed),
  );
}
