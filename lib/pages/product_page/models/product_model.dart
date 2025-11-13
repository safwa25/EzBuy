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

  /// stock structure:
  /// {
  ///   "colorA": { "sizeS": 5, "sizeM": 3 },
  ///   "colorB": { "sizeS": 2, "sizeL": 10 }
  /// }
  final Map<String, Map<String, int>>? stock;

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

  Product copyWith({
    String? id,
    String? name,
    double? price,
    String? description,
    List<String>? images,
    List<String>? sizes,
    List<String>? colors,
    String? category,
    Map<String, Map<String, int>>? stock,
    bool? isFavorite,
    int? quantity,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      description: description ?? this.description,
      images: images ?? this.images,
      sizes: sizes ?? this.sizes,
      colors: colors ?? this.colors,
      category: category ?? this.category,
      stock: stock ?? this.stock,
      isFavorite: isFavorite ?? this.isFavorite,
      quantity: quantity ?? this.quantity,
    );
  }

  /// Returns available quantity for given color/size.
  /// If both color and size null -> returns total stock across all variants.
  int availableQuantity({String? color, String? size}) {
    if (stock == null || stock!.isEmpty) return 0;
    if (color == null && size == null) {
      // sum all
      return stock!.values
          .map((sizesMap) => sizesMap.values.fold<int>(0, (a, b) => a + b))
          .fold<int>(0, (a, b) => a + b);
    }
    if (color != null) {
      final sizesMap = stock![color];
      if (sizesMap == null || sizesMap.isEmpty) return 0;
      if (size == null) {
        return sizesMap.values.fold<int>(0, (a, b) => a + b);
      } else {
        return sizesMap[size] ?? 0;
      }
    } else {
      // color null, size provided -> sum that size across all colors
      int sum = 0;
      stock!.forEach((_, sizesMap) {
        sum += (sizesMap[size] ?? 0);
      });
      return sum;
    }
  }

  /// convenience check
  bool isAvailable(int requiredQty, {String? color, String? size}) {
    return availableQuantity(color: color, size: size) >= requiredQty;
  }

  Map<String, dynamic> toMap() {
    // convert stock to Map<String, dynamic>
    final stockMap = stock?.map((c, sizesMap) {
      return MapEntry(
          c,
          sizesMap.map((s, q) => MapEntry(s, q))
      );
    });
    return {
      'id': id,
      'name': name,
      'price': price,
      'description': description,
      'imageUrl': images,
      'sizes': sizes,
      'colors': colors,
      'category': category,
      'stock': stockMap,
      'isFavorite': isFavorite,
      'quantity': quantity,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    final rawStock = map['stock'];
    Map<String, Map<String, int>>? parsedStock;
    if (rawStock != null && rawStock is Map) {
      parsedStock = {};
      rawStock.forEach((k, v) {
        if (v is Map) {
          parsedStock![k.toString()] = v.map((sk, sv) =>
              MapEntry(sk.toString(), (sv is int) ? sv : int.tryParse(sv.toString()) ?? 0));
        }
      });
    }

    final colors = parsedStock?.keys.map((e) => e.toString()).toList() ?? <String>[];
    final sizes = (parsedStock != null && parsedStock.isNotEmpty)
        ? ((parsedStock.values.first.keys).map((e) => e.toString()).toList())
        : <String>[];

    return Product(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      description: map['description'] ?? '',
      images: ((map['imageUrl'] ?? map['images']) ?? [])
          .map<String>((e) => e.toString())
          .toList(),
      sizes: sizes,
      colors: colors,
      category: map['category'],
      stock: parsedStock,
      isFavorite: map['isFavorite'] ?? false,
      quantity: map['quantity'] ?? 1,
    );
  }

  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = (doc.data() ?? {}) as Map<String, dynamic>;
    return Product.fromMap({...data, 'id': data['id'] ?? doc.id});
  }
}
