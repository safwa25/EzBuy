import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final double price;
  final String description;
  final List<String> images;
  final List<String> sizes;
  final List<String> colors;
  final String? category;
  final Map<String, dynamic>? stock;
  bool isFavorite;
  int quantity;

  Product({
    this.quantity = 1,
    required this.id,
    required this.name,
    required this.price,
    this.description = '',
    this.images = const [],
    this.sizes = const [],
    this.colors = const [],
    this.category,
    this.stock,
    this.isFavorite = false,
  });

  double get totalPrice => price * quantity;

  void increaseQuantity() => quantity++;
  void decreaseQuantity() {
    if (quantity > 1) quantity--;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'description': description,
      'images': images,
      'sizes': sizes,
      'colors': colors,
      'category': category,
      'stock': stock,
      'isFavorite': isFavorite,
      'quantity': quantity,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    final stock = map['stock'] != null
        ? Map<String, dynamic>.from(map['stock'])
        : null;

    // ✅ Safely extract colors and sizes from stock
    final colors = stock?.keys.map((e) => e.toString()).toList() ?? <String>[];

    final sizes = (stock != null && stock.isNotEmpty)
        ? ((stock.values.first as Map?)?.keys.map((e) => e.toString()).toList() ?? <String>[])
        : <String>[];

    return Product(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      description: map['description'] ?? '',
      // ✅ Handle imageUrl or images safely
      images: ((map['imageUrl'] ?? map['images']) ?? [])
          .map<String>((e) => e.toString())
          .toList(),
      sizes: sizes,
      colors: colors,
      category: map['category'],
      stock: stock,
      isFavorite: map['isFavorite'] ?? false,
      quantity: map['quantity'] ?? 1,
    );
  }

  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = (doc.data() ?? {}) as Map<String, dynamic>;
    final stock = data['stock'] != null
        ? Map<String, dynamic>.from(data['stock'])
        : null;

    // ✅ Safely handle nulls when reading nested fields
    final colors = stock?.keys.map((e) => e.toString()).toList() ?? <String>[];

    final sizes = (stock != null && stock.isNotEmpty)
        ? ((stock.values.first as Map?)?.keys.map((e) => e.toString()).toList() ?? <String>[])
        : <String>[];

    return Product(
      id: data['id'] ?? doc.id,
      name: data['name'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      description: data['description'] ?? '',
      images: ((data['imageUrl'] ?? data['images']) ?? [])
          .map<String>((e) => e.toString())
          .toList(),
      sizes: sizes,
      colors: colors,
      category: data['category'],
      stock: stock,
      isFavorite: data['isFavorite'] ?? false,
      quantity: data['quantity'] ?? 1,
    );
  }
}
