// lib/blocs/category/category_search_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/category_model.dart';

class CategorySearchCubit extends Cubit<CategorySearchState> {
  CategorySearchCubit()
      : super(CategorySearchState(
    categories: [],
    filteredCategories: [],
    query: '',
  ));

  void setCategories(List<CategoryModel> categories) {
    emit(CategorySearchState(
      categories: categories,
      filteredCategories: categories,
      query: state.query,
    ));
  }

  void searchCategories(String query) {
    final filtered = state.categories.where((category) {
      return category.categoryName
          .toLowerCase()
          .contains(query.toLowerCase());
    }).toList();

    emit(CategorySearchState(
      categories: state.categories,
      filteredCategories: filtered,
      query: query,
    ));
  }

  void clearSearch() {
    emit(CategorySearchState(
      categories: state.categories,
      filteredCategories: state.categories,
      query: '',
    ));
  }
}

class CategorySearchState {
  final List<CategoryModel> categories;
  final List<CategoryModel> filteredCategories;
  final String query;

  CategorySearchState({
    required this.categories,
    required this.filteredCategories,
    required this.query,
  });
}