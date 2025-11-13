class CartItem {
  final String docId; // doc id in users/{uid}/cart => might be productId_color_size
  final String productId;
  final String? selectedColor;
  final String? selectedSize;
  final int quantity;
  final Map<String, dynamic>? rawProductData; // optional cached product fields for UI (name, price, images...)

  CartItem({
    required this.docId,
    required this.productId,
    this.selectedColor,
    this.selectedSize,
    required this.quantity,
    this.rawProductData,
  });

  factory CartItem.fromDoc(String docId, Map<String, dynamic> data) {
    return CartItem(
      docId: docId,
      productId: (data['id'] ?? docId.split('_').first).toString(),
      selectedColor: data['selectedColor'] as String?,
      selectedSize: data['selectedSize'] as String?,
      quantity: (data['quantity'] ?? 0) as int,
      rawProductData: data, // keep the rest for UI
    );
  }
}
