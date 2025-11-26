// shop_state.dart
part of 'shop_cubit.dart';

abstract class ShopState extends Equatable {
  const ShopState();

  @override
  List<Object?> get props => [];
}

class ShopInitial extends ShopState {}

class ShopLoading extends ShopState {}

class ShopEmpty extends ShopState {} // Untuk first time

class ShopLoaded extends ShopState {
  final Shop shop;

  const ShopLoaded(this.shop);

  @override
  List<Object?> get props => [shop];
}

class ShopSaved extends ShopState {
  final Shop shop;

  const ShopSaved(this.shop);

  @override
  List<Object?> get props => [shop];
}

class ShopError extends ShopState {
  final String message;

  const ShopError(this.message);

  @override
  List<Object?> get props => [message];
}