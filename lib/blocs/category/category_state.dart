// lib/blocs/category/category_state.dart

import 'package:equatable/equatable.dart';
import '../../data/models/category_model.dart';

abstract class CategoryState extends Equatable {
  const CategoryState();

  @override
  List<Object?> get props => [];
}

class CategoryInitial extends CategoryState {
  const CategoryInitial();
}

class CategoryLoading extends CategoryState {
  const CategoryLoading();
}

class CategoryLoadingMore extends CategoryState {
  final CategoryLoaded previousState;

  const CategoryLoadingMore(this.previousState);

  @override
  List<Object?> get props => [previousState];
}

class CategoryLoaded extends CategoryState {
  final List<CategoryModel> categories;
  final int currentPage;
  final int lastPage;
  final bool hasNextPage;
  final int total;

  const CategoryLoaded({
    required this.categories,
    this.currentPage = 1,
    this.lastPage = 1,
    this.hasNextPage = false,
    this.total = 0,
  });

  @override
  List<Object?> get props => [
    categories,
    currentPage,
    lastPage,
    hasNextPage,
    total,
  ];
}

// ✅ State khusus untuk list categories (dropdown)
class CategoryListLoaded extends CategoryState {
  final List<CategoryModel> categories;

  const CategoryListLoaded({required this.categories});

  @override
  List<Object?> get props => [categories];
}

class CategoryEmpty extends CategoryState {
  const CategoryEmpty();
}

class CategoryActionSuccess extends CategoryState {
  final String message;

  const CategoryActionSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class CategoryError extends CategoryState {
  final String message;

  const CategoryError({required this.message});

  @override
  List<Object?> get props => [message];
}