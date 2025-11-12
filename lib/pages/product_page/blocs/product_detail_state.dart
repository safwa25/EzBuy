part of 'product_detail_bloc.dart';

class ProductDetailState extends Equatable {
  final Product? product;
  final bool isLoading;
  final String? selectedColor;
  final String? selectedSize;
  final int quantity;
  final int availableStock;
  final bool isOutOfStock;
  final String? errorMessage;

  bool get canAddToCart =>
      !isLoading &&
          !isOutOfStock &&
          selectedColor != null &&
          selectedSize != null &&
          availableStock > 0;

  const ProductDetailState({
    this.product,
    this.isLoading = false,
    this.selectedColor,
    this.selectedSize,
    this.quantity = 1,
    this.availableStock = 0,
    this.isOutOfStock = false,
    this.errorMessage,
  });

  ProductDetailState copyWith({
    Product? product,
    bool? isLoading,
    String? selectedColor,
    String? selectedSize,
    int? quantity,
    int? availableStock,
    bool? isOutOfStock,
    String? errorMessage,
  }) {
    return ProductDetailState(
      product: product ?? this.product,
      isLoading: isLoading ?? this.isLoading,
      selectedColor: selectedColor ?? this.selectedColor,
      selectedSize: selectedSize ?? this.selectedSize,
      quantity: quantity ?? this.quantity,
      availableStock: availableStock ?? this.availableStock,
      isOutOfStock: isOutOfStock ?? this.isOutOfStock,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    product,
    isLoading,
    selectedColor,
    selectedSize,
    quantity,
    availableStock,
    isOutOfStock,
    errorMessage
  ];
}
