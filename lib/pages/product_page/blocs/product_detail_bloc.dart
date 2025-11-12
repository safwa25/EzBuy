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
      emit(state.copyWith(product: product, isLoading: false));
    } catch (e) {
      emit(state.copyWith(
          isLoading: false, errorMessage: 'Failed to load product: $e'));
    }
  }

  void _onSelectColor(SelectColor event, Emitter<ProductDetailState> emit) {
    emit(state.copyWith(
      selectedColor: event.color,
      selectedSize: null,
      availableStock: 0,
      isOutOfStock: false,
      errorMessage: null,
    ));
  }

  void _onSelectSize(SelectSize event, Emitter<ProductDetailState> emit) {
    final color = state.selectedColor;
    if (color == null || state.product == null) return;

    final stockMap = state.product!.stock?[color] ?? {};
    final available = stockMap[event.size] ?? 0;

    emit(state.copyWith(
      selectedSize: event.size,
      availableStock: available,
      isOutOfStock: available == 0,
      errorMessage: null,
    ));
  }

  void _onChangeQuantity(ChangeQuantity event, Emitter<ProductDetailState> emit) {
    if (event.quantity > state.availableStock) {
      emit(state.copyWith(
        errorMessage: "Only ${state.availableStock} item(s) available.",
        quantity: state.availableStock,
      ));
    } else if (event.quantity < 1) {
      emit(state.copyWith(quantity: 1));
    } else {
      emit(state.copyWith(
        quantity: event.quantity,
        errorMessage: null,
      ));
    }
  }


  Future<void> _onAddToCartPressed(
      AddToCartPressed event, Emitter<ProductDetailState> emit) async {
    final product = state.product;
    final color = state.selectedColor;
    final size = state.selectedSize;

    if (product == null || color == null || size == null) {
      emit(state.copyWith(
          errorMessage: "Please select a color and size first."));
      return;
    }

    final available = state.availableStock;
    if (available == 0) {
      emit(state.copyWith(errorMessage: "This variant is out of stock."));
      return;
    }

    if (state.quantity > available) {
      emit(state.copyWith(
          errorMessage: "Only $available item(s) left in stock."));
      return;
    }

    try {
      for (int i = 0; i < state.quantity; i++) {
        await _cartService.addToCart(product);
      }
      emit(state.copyWith(errorMessage: null));
    } catch (e) {
      emit(state.copyWith(errorMessage: "Failed to add to cart: $e"));
    }
  }
}
