import 'package:flutter/material.dart';
import '../../utils/product_card.dart';
import 'product_detail_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../product_page/models/product_model.dart';

class ProductGridView extends StatefulWidget {
  final bool isLoggedIn;
  const ProductGridView({super.key, required this.isLoggedIn});

  @override
  State<ProductGridView> createState() => _ProductGridViewState();
}

class _ProductGridViewState extends State<ProductGridView> {
  String selectedCategory = 'All';
  String searchQuery = '';

  final List<String> categories = [
    'All',
    'Clothes',
    'Shoes',
    'Makeup',
    'Accessories',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchBar(),
              const SizedBox(height: 12),
              _buildCategoryList(),
              const SizedBox(height: 12),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('products')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text(
                          'No products found',
                          style: TextStyle(fontSize: 18),
                        ),
                      );
                    }


                    final allProducts = snapshot.data!.docs
                        .map((doc) => Product.fromFirestore(doc))
                        .toList();

                    final filteredProducts = allProducts.where((product) {
                      final matchesCategory = selectedCategory == 'All' ||
                          product.category == selectedCategory;
                      final matchesSearch = product.name
                          .toLowerCase()
                          .contains(searchQuery.toLowerCase());
                      return matchesCategory && matchesSearch;
                    }).toList();

                    if (filteredProducts.isEmpty) {
                      return const Center(
                        child: Text(
                          'No products found',
                          style: TextStyle(fontSize: 18),
                        ),
                      );
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.all(6),
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.68,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ProductDetailPage(productId: product.id),
                              ),
                            );
                          },
                          child: ProductCard(
                            product: product,
                            showBuyButton: true,
                            isLoggedIn: widget.isLoggedIn,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      onChanged: (value) => setState(() => searchQuery = value),
      decoration: InputDecoration(
        hintText: 'Search products...',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.grey.withOpacity(0.15),
        contentPadding:
        const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildCategoryList() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category;

          return GestureDetector(
            onTap: () => setState(() => selectedCategory = category),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF0026CC)
                    : Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  category,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
