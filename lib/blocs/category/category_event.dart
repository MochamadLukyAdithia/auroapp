// lib/blocs/category/category_event.dart

import 'package:equatable/equatable.dart';
import '../../data/models/category_model.dart';

abstract class CategoryEvent extends Equatable {
  const CategoryEvent();

  @override
  List<Object?> get props => [];
}

class LoadCategories extends CategoryEvent {
  final int? limit;
  final int? page;

  const LoadCategories({this.limit, this.page});

  @override
  List<Object?> get props => [limit, page];
}

class LoadMoreCategories extends CategoryEvent {
  const LoadMoreCategories();
}

class LoadCategoryList extends CategoryEvent {
  const LoadCategoryList();
}

class AddCategory extends CategoryEvent {
  final String name;

  const AddCategory({required this.name});

  @override
  List<Object?> get props => [name];
}

class UpdateCategory extends CategoryEvent {
  final CategoryModel category;

  const UpdateCategory({required this.category});

  @override
  List<Object?> get props => [category];
}

class DeleteCategory extends CategoryEvent {
  final int categoryId; // ✅ Ubah ke int

  const DeleteCategory(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}