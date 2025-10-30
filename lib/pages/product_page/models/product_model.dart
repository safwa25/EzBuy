class Product {
  final String id;
  final String name;
  final double price;
  final String description;
  final List<String> images;
  final List<String> sizes;
  final List<String> colors;
  final String? category;
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
    this.isFavorite = false,
  });

  double get totalPrice => price * quantity;

 
  void increaseQuantity() => quantity++;
  void decreaseQuantity() {
    if (quantity > 1) quantity--;
  }

  //Convert product to map used for db and firebase
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
      'isFavorite': isFavorite,
      'quantity': quantity,
    };
  }

  // Create product from map
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      description: map['description'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      sizes: List<String>.from(map['sizes'] ?? []),
      colors: List<String>.from(map['colors'] ?? []),
      category: map['category'],
      isFavorite: map['isFavorite'] ?? false,
      quantity: map['quantity'] ?? 1,
    );
  }
}
