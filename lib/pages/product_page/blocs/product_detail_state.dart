part of 'product_detail_bloc.dart';

class ProductDetailState extends Equatable {
  final Product? product;
  final bool isLoading;       
  final bool isAdding;        
  final String? selectedColor;
  final String? selectedSize;
  final int quantity;
  final int availableStock;
  final bool isOutOfStock;
  final String? errorMessage;

  final List<String> availableSizes;

  bool get canAddToCart {
    final isOneSizeProduct = product != null &&
        (product!.sizes.isEmpty ||
            product!.category == "Accessories" ||
            product!.category == "Makeup");

    return !isLoading &&
        !isAdding &&
        !isOutOfStock &&
        selectedColor != null &&
        availableStock > 0 &&
        (isOneSizeProduct || selectedSize != null);
  }


  const ProductDetailState({
    this.product,
    this.isLoading = false,
    this.isAdding = false,
    this.selectedColor,
    this.selectedSize,
    this.quantity = 1,
    this.availableStock = 0,
    this.isOutOfStock = false,
    this.errorMessage,
    this.availableSizes = const [],
  });

  ProductDetailState copyWith({
    Product? product,
    bool? isLoading,
    bool? isAdding,
    String? selectedColor,
    String? selectedSize,
    int? quantity,
    int? availableStock,
    bool? isOutOfStock,
    String? errorMessage,
    List<String>? availableSizes,
  }) {
    return ProductDetailState(
      product: product ?? this.product,
      isLoading: isLoading ?? this.isLoading,
      isAdding: isAdding ?? this.isAdding,
      selectedColor: selectedColor ?? this.selectedColor,
      selectedSize: selectedSize ?? this.selectedSize,
      quantity: quantity ?? this.quantity,
      availableStock: availableStock ?? this.availableStock,
      isOutOfStock: isOutOfStock ?? this.isOutOfStock,
      errorMessage: errorMessage,
      availableSizes: availableSizes ?? this.availableSizes,
    );
  }

  @override
  List<Object?> get props => [
        product,
        isLoading,
        isAdding,
        selectedColor,
        selectedSize,
        quantity,
        availableStock,
        isOutOfStock,
        errorMessage,
        availableSizes,
      ];
}
