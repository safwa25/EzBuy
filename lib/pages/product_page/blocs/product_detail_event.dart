part of 'product_detail_bloc.dart';

abstract class ProductDetailEvent extends Equatable {
  const ProductDetailEvent();

  @override
  List<Object?> get props => [];
}

class LoadProduct extends ProductDetailEvent {
  final String productId;
  const LoadProduct(this.productId);

  @override
  List<Object?> get props => [productId];
}

class SelectColor extends ProductDetailEvent {
  final String color;
  const SelectColor(this.color);

  @override
  List<Object?> get props => [color];
}

class SelectSize extends ProductDetailEvent {
  final String size;
  const SelectSize(this.size);

  @override
  List<Object?> get props => [size];
}

class ChangeQuantity extends ProductDetailEvent {
  final int quantity;
  const ChangeQuantity(this.quantity);

  @override
  List<Object?> get props => [quantity];
}

class AddToCartPressed extends ProductDetailEvent {
  const AddToCartPressed();
}

class UpdateStock extends ProductDetailEvent {
  final int availableStock;
  const UpdateStock(this.availableStock);

  @override
  List<Object?> get props => [availableStock];
}
