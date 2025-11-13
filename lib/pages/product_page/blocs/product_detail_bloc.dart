import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ezbuy/pages/product_page/models/product_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ezbuy/pages/cart/cart_services.dart';

part 'product_detail_event.dart';
part 'product_detail_state.dart';

class ProductDetailBloc extends Bloc<ProductDetailEvent, ProductDetailState> {
  final CartService _cartService = CartService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ProductDetailBloc() : super(const ProductDetailState()) {
    on<LoadProduct>(_onLoadProduct);
    on<SelectColor>(_onSelectColor);
    on<SelectSize>(_onSelectSize);
    on<ChangeQuantity>(_onChangeQuantity);
    on<AddToCartPressed>(_onAddToCartPressed);
  }

  Future<void> _onLoadProduct(
      LoadProduct event, Emitter<ProductDetailState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final doc =
          await _firestore.collection('products').doc(event.productId).get();
      if (!doc.exists) {
        emit(state.copyWith(
            isLoading: false, errorMessage: 'Product not found'));
        return;
      }

      final product = Product.fromFirestore(doc);

      final initialAvailable = product.availableQuantity();

      emit(state.copyWith(
        product: product,
        isLoading: false,
        availableStock: initialAvailable,

        selectedColor: null,
        selectedSize: null,
        quantity: 1,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
          isLoading: false, errorMessage: 'Failed to load product: $e'));
    }
  }

  void _onSelectColor(SelectColor event, Emitter<ProductDetailState> emit) {
    final product = state.product;
    if (product == null) {
      emit(state.copyWith(
          errorMessage: 'Product not loaded. Cannot select color.'));
      return;
    }


    final stockForColor = product.stock != null && product.stock!.containsKey(event.color)
        ? Map<String, int>.from(product.stock![event.color]!)
        : <String, int>{};
    int totalForColor = 0;
    stockForColor.forEach((_, q) {
      totalForColor += q;
    });


    final availableSizes = stockForColor.keys.toList();

    emit(state.copyWith(
      selectedColor: event.color,
      selectedSize: null,
      availableStock: totalForColor,
      isOutOfStock: totalForColor == 0,
      errorMessage: null,

      availableSizes: availableSizes,
      quantity: 1,
    ));
  }

  void _onSelectSize(SelectSize event, Emitter<ProductDetailState> emit) {
    final color = state.selectedColor;
    final product = state.product;
    if (product == null) {
      emit(state.copyWith(errorMessage: 'Product not loaded.'));
      return;
    }
    if (color == null) {
      emit(state.copyWith(
          errorMessage: 'Please select a color before selecting size.'));
      return;
    }


    final sizesMap = product.stock != null && product.stock!.containsKey(color)
        ? Map<String, int>.from(product.stock![color]!)
        : <String, int>{};

    final available = (sizesMap[event.size] ?? 0);

    emit(state.copyWith(
      selectedSize: event.size,
      availableStock: available,
      isOutOfStock: available == 0,
      errorMessage: null,
      quantity: available > 0 ? 1 : 0,
    ));
  }

  void _onChangeQuantity(ChangeQuantity event, Emitter<ProductDetailState> emit) {
    final desired = event.quantity;
    final avail = state.availableStock;

    if (avail <= 0) {

      emit(state.copyWith(
        errorMessage: "This variant is out of stock.",
        quantity: 0,
      ));
      return;
    }

    if (desired < 1) {
      emit(state.copyWith(quantity: 1, errorMessage: null));
      return;
    }

    if (desired > avail) {
      emit(state.copyWith(
        errorMessage: "Only $avail item(s) available.",
        quantity: avail,
      ));
    } else {
      emit(state.copyWith(quantity: desired, errorMessage: null));
    }
  }

  Future<void> _onAddToCartPressed(
      AddToCartPressed event, Emitter<ProductDetailState> emit) async {
    final product = state.product;
    final color = state.selectedColor;
    final size = state.selectedSize;
    final qty = state.quantity;

    if (product == null) {
      emit(state.copyWith(errorMessage: "Product not loaded."));
      return;
    }

    final isOneSizeProduct =
            product.category == "Accessories" ||
            product.category == "Makeup";

    if (color == null || (!isOneSizeProduct && size == null)) {
      emit(state.copyWith(errorMessage: "Please select a color ${isOneSizeProduct ? '' : ' and size'} first."));
      return;
    }

    if (qty <= 0) {
      emit(state.copyWith(errorMessage: "Quantity must be at least 1."));
      return;
    }


    final available = product.availableQuantity(color: color, size: size);
    if (available < qty) {
      emit(state.copyWith(errorMessage: "Only $available item(s) left in stock."));
      return;
    }


    emit(state.copyWith(isAdding: true, errorMessage: null));
    try {

      await _cartService.addToCart(product, qty: qty, color: color, size: size);

      emit(state.copyWith(isAdding: false, errorMessage: null));
    } catch (e) {
      emit(state.copyWith(isAdding: false, errorMessage: "Failed to add to cart: $e"));
    }
  }
}
