// bloc/product/product_state.dart
import 'package:equatable/equatable.dart';
import '../../data/models/product_model.dart';

abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {
  const ProductInitial();
}

class ProductLoading extends ProductState {
  const ProductLoading();
}

class ProductLoadingMore extends ProductState {
  final ProductLoaded previousState;

  const ProductLoadingMore(this.previousState);

  @override
  List<Object?> get props => [previousState];
}

class ProductLoaded extends ProductState {
  final List<ProductModel> products;
  final int currentPage;
  final int lastPage;
  final bool hasNextPage;
  final int total;
  final int? filteredCategoryId;
  final bool isLimited;

  const ProductLoaded({
    required this.products,
    this.currentPage = 1,
    this.lastPage = 1,
    this.hasNextPage = false,
    this.total = 0,
    this.filteredCategoryId,
    this.isLimited = true,
  });

  List<ProductModel> get filteredProducts {
    if (filteredCategoryId == null) {
      return products;
    }
    return products
        .where((product) => product.categoryId == filteredCategoryId)
        .toList();
  }

  ProductLoaded copyWith({
    List<ProductModel>? products,
    int? currentPage,
    int? lastPage,
    bool? hasNextPage,
    int? total,
    int? filteredCategoryId,
  }) {
    return ProductLoaded(
      products: products ?? this.products,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      total: total ?? this.total,
      filteredCategoryId: filteredCategoryId ?? this.filteredCategoryId,
    );
  }

  @override
  List<Object?> get props => [
    products,
    currentPage,
    lastPage,
    hasNextPage,
    total,
    filteredCategoryId,
    isLimited
  ];
}

class ProductEmpty extends ProductState {
  const ProductEmpty();
}

class ProductError extends ProductState {
  final String message;

  const ProductError({required this.message});

  @override
  List<Object?> get props => [message];
}

class ProductActionSuccess extends ProductState {
  final String message;

  const ProductActionSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

