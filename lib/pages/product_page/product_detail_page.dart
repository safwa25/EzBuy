import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ezbuy/pages/cart/mycart.dart';
import 'blocs/product_detail_bloc.dart';
import 'package:ezbuy/pages/cart/cart_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ezbuy/pages/product_page/models/product_model.dart';

class ProductDetailPage extends StatelessWidget {
  final String productId;
  final bool isLoggedIn;

  const ProductDetailPage({
    super.key,
    required this.productId,
    this.isLoggedIn = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProductDetailBloc()
        ..add(LoadProduct(productId)),
      child: ProductDetailView(),
    );
  }
}

class ProductDetailView extends StatelessWidget {
  final Map<String, Color> colorMap = const {
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
  };

  ProductDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<ProductDetailBloc, ProductDetailState>(
          builder: (context, state) {
            return Text(
              state.product?.name ?? "Product Detail",
              style: GoogleFonts.cairo(fontSize: 24, fontWeight: FontWeight.bold),
            );
          },
        ),
      ),

      bottomNavigationBar: BlocBuilder<ProductDetailBloc, ProductDetailState>(
        builder: (context, state) {
          final bloc = context.read<ProductDetailBloc>();

          return Container(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 18, top: 14),
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
                    onPressed: state.product == null
                        ? null
                        : () {

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Viewing ${state.product!.name}')),
                      );
                    },
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
                    onPressed: state.canAddToCart
                        ? () {
                      bloc.add(const AddToCartPressed());
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Item added to cart!'),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 2),
                        ),
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CartPage()),
                      );
                    }
                        : null,
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
          );
        },
      ),

      body: BlocConsumer<ProductDetailBloc, ProductDetailState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final product = state.product;
          if (product == null) {
            return const Center(child: Text('Product not found'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                if (product.images.isNotEmpty)
                  SizedBox(
                    height: 300,
                    child: PageView.builder(
                      itemCount: product.images.length,
                      itemBuilder: (context, index) => ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          product.images[index],
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 24),


                Text(
                  "\$${product.price}",
                  style: GoogleFonts.cairo(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.amber.shade600 : Colors.amber.shade900,
                  ),
                ),
                const SizedBox(height: 20),


                if (product.colors.isNotEmpty) ...[
                  Text(
                    "Color",
                    style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: product.colors.map((colorHex) {
                      final colorValue = colorMap[colorHex] ?? Colors.grey;
                      return GestureDetector(
                        onTap: () => context.read<ProductDetailBloc>().add(SelectColor(colorHex)),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 35,
                          height: 35,
                          decoration: BoxDecoration(
                            color: colorValue,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: state.selectedColor == colorHex
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


                if (product.sizes.isNotEmpty) ...[
                  Text(
                    "Size",
                    style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: product.sizes.map((size) {
                      return ChoiceChip(
                        label: Text(
                          size,
                          style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        selected: state.selectedSize == size,
                        onSelected: (_) {
                          context.read<ProductDetailBloc>().add(SelectSize(size));
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                ],


                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Quantity",
                      style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    DropdownButton<int>(
                      value: state.quantity,
                      items: List.generate(10, (index) => index + 1)
                          .map(
                            (qty) => DropdownMenuItem(
                          value: qty,
                          child: Text(
                            "$qty",
                            style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          context.read<ProductDetailBloc>().add(ChangeQuantity(value));
                        }
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 24),


                Text(
                  "Description",
                  style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 24),
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
          );
        },
      ),
    );
  }
}
