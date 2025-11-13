import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../cart/mycart.dart';
import 'blocs/product_detail_bloc.dart';
import '../cart/cart_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/product_model.dart';
import '../favorite/favorite_services.dart';

List<String> sortSizes(List<String> sizes) {
  const sizeOrder = ["XS", "S", "M", "L", "XL", "XXL", "XXXL", "38", "39", "40", "41", "42", "43"];
  return sizeOrder.where((s) => sizes.contains(s)).toList();
}

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
      child: ProductDetailView(isLoggedIn: isLoggedIn),
    );
  }
}

class ProductDetailView extends StatelessWidget {
  final FavoriteService _favoriteService = FavoriteService();
  final bool isLoggedIn;

  final Map<String, Color> colorMap = const {
    'Black': Colors.black,
    'White': Colors.white,
    'Red': Colors.red,
    'Blue': Colors.blue,
    'Green': Colors.green,
    'Brown': Colors.brown,
    'Pink': Colors.pink,
    'Cream': Color(0xFFFFFDD0),
    'Beige': Color(0xFFF5F5DC),
    'Black and Blue': Colors.blueGrey,
    'Beige and White': Color(0xFFF8F8E7),
    'White and Blue': Color(0xFFB0C4DE),
    'White and Black': Color(0xFFCCCCCC),
    'Blue and Black': Color(0xFF1A237E),
    'Navy Blue': Color(0xFF001F3F),
    'Magenta': Color(0xFFFF00FF),
    'Purple': Colors.purple,
    'Silver': Color(0xFFC0C0C0),
    'Gold': Color(0xFFFFD700),
    'Champagne': Color(0xFFF7E7CE),
    'Rosy Pink': Color(0xFFFFC0CB),
    'Strawberry Glaze': Color(0xFFFF6F61),
    'Cherry Sparkle': Color(0xFFD2042D),
    'Crimson Kiss': Color(0xFF990000),
    'Berry Rouge': Color(0xFF8B004B),
    'Golden Glow': Color(0xFFFFD700),
    'Ruby Shine': Color(0xFF9B111E),
    'Cheektone': Color(0xFFFFA6C9),
    'Fleur': Color(0xFFFFB6B9),
    'Juicy': Color(0xFFFF7F50),
    'Ruby': Color(0xFFE0115F),
    'Light Pink': Color(0xFFFFB6C1),
    'pink': Colors.pink,
  };

  ProductDetailView({super.key, required this.isLoggedIn});

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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isLoggedIn)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      "You must be logged in to add to cart",
                      style: GoogleFonts.cairo(
                        color: Colors.red,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),


                Row(
                  children: [
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
                        onPressed: (isLoggedIn && state.canAddToCart)
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


                if (product.sizes.isNotEmpty && product.category != "Accessories" && product.category != "Makeup") ...[
                  Text(
                    "Size",
                    style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: sortSizes(product.sizes).map((size) {
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
                    Row(
                      children: [

                        IconButton(
                          onPressed: state.quantity > 1
                              ? () {
                            context
                                .read<ProductDetailBloc>()
                                .add(ChangeQuantity(state.quantity - 1));
                          }
                              : null,
                          icon: const Icon(Icons.remove_circle_outline),
                          color: Colors.grey.shade700,
                          iconSize: 28,
                        ),

                        Container(
                          width: 48,
                          height: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "${state.quantity}",
                            style: GoogleFonts.cairo(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),


                        IconButton(
                          onPressed: (state.availableStock > 0 && state.quantity < state.availableStock)
                              ? () {
                            context
                                .read<ProductDetailBloc>()
                                .add(ChangeQuantity(state.quantity + 1));
                          }
                              : () {
                            if (state.availableStock > 0 &&
                                state.quantity >= state.availableStock) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Only ${state.availableStock} in stock!",
                                    style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                                  ),
                                  backgroundColor: Colors.redAccent,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.add_circle_outline),
                          color: Colors.grey.shade700,
                          iconSize: 28,
                        ),

                      ],
                    ),
                  ],
                ),
                if (state.availableStock > 0)
                  Text(
                    "In stock: ${state.availableStock}",
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                else
                  Text(
                    "Out of stock",
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
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
