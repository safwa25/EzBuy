class Product {
  final String id;
  final String name;
  final double price;
  final String description;
  final List<String> images;
  final List<String> sizes;
  final List<String> colors;
  final String? category;
  bool isFavorite=false ;

  Product({
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
}
