// lib/blocs/category/category_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/category_model.dart';
import '../../data/repositories/category_repository.dart';
import 'category_event.dart';
import 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryRepository _categoryRepository;

  CategoryBloc(this._categoryRepository) : super(const CategoryInitial()) {
    on<LoadCategories>(_onLoadCategories);
    on<LoadMoreCategories>(_onLoadMoreCategories);
    on<LoadCategoryList>(_onLoadCategoryList); // ✅ Untuk dropdown
    on<AddCategory>(_onAddCategory);
    on<UpdateCategory>(_onUpdateCategory);
    on<DeleteCategory>(_onDeleteCategory);
  }

  // ❌ HAPUS: SharedPreferences methods
  // ❌ HAPUS: List<CategoryModel> _categories = []

  // ✅ LOAD CATEGORIES dengan pagination
  Future<void> _onLoadCategories(
      LoadCategories event,
      Emitter<CategoryState> emit,
      ) async {
    emit(const CategoryLoading());

    try {
      final response = await _categoryRepository.getCategories(
        limit: event.limit ?? 10,
        page: 1,
      );

      if (response.success && response.data != null) {
        final categories = response.data!.categories;

        if (categories.isEmpty) {
          emit(const CategoryEmpty());
        } else {
          emit(CategoryLoaded(
            categories: categories,
            currentPage: response.data!.currentPage,
            lastPage: response.data!.lastPage,
            hasNextPage: response.data!.hasNextPage,
            total: response.data!.total,
          ));
        }
      } else {
        emit(CategoryError(message: response.message));
      }
    } catch (e) {
      emit(CategoryError(message: 'Gagal memuat kategori: ${e.toString()}'));
    }
  }

  // ✅ LOAD MORE CATEGORIES (pagination)
  Future<void> _onLoadMoreCategories(
      LoadMoreCategories event,
      Emitter<CategoryState> emit,
      ) async {
    final currentState = state;
    if (currentState is! CategoryLoaded) return;
    if (!currentState.hasNextPage) return;

    emit(CategoryLoadingMore(currentState));

    try {
      final response = await _categoryRepository.getCategories(
        limit: 10,
        page: currentState.currentPage + 1,
      );

      if (response.success && response.data != null) {
        final allCategories = [
          ...currentState.categories,
          ...response.data!.categories,
        ];

        emit(CategoryLoaded(
          categories: allCategories,
          currentPage: response.data!.currentPage,
          lastPage: response.data!.lastPage,
          hasNextPage: response.data!.hasNextPage,
          total: response.data!.total,
        ));
      } else {
        emit(CategoryError(message: response.message));
      }
    } catch (e) {
      emit(CategoryError(message: 'Gagal memuat kategori: ${e.toString()}'));
    }
  }

  // ✅ LOAD CATEGORY LIST (untuk dropdown, tanpa pagination)
  Future<void> _onLoadCategoryList(
      LoadCategoryList event,
      Emitter<CategoryState> emit,
      ) async {
    emit(const CategoryLoading());

    try {
      final response = await _categoryRepository.listCategories();

      if (response.success && response.data != null) {
        if (response.data!.isEmpty) {
          emit(const CategoryEmpty());
        } else {
          emit(CategoryListLoaded(categories: response.data!));
        }
      } else {
        emit(CategoryError(message: response.message));
      }
    } catch (e) {
      emit(CategoryError(message: 'Gagal memuat daftar kategori: ${e.toString()}'));
    }
  }

  // ✅ ADD CATEGORY
  Future<void> _onAddCategory(
      AddCategory event,
      Emitter<CategoryState> emit,
      ) async {
    try {
      if (event.name.trim().isEmpty) {
        emit(const CategoryError(message: 'Nama kategori tidak boleh kosong'));
        return;
      }

      emit(const CategoryLoading());

      final newCategory = CategoryModel(
        categoryName: event.name.trim(),
      );

      final response = await _categoryRepository.createCategory(
        newCategory.toCreateJson(),
      );

      if (response.success) {
        emit(const CategoryActionSuccess(message: 'Kategori berhasil ditambahkan'));
        add(const LoadCategories());
      } else {
        emit(CategoryError(message: response.message));
      }
    } catch (e) {
      emit(CategoryError(message: 'Gagal menambahkan kategori: ${e.toString()}'));
    }
  }

  // ✅ UPDATE CATEGORY
  Future<void> _onUpdateCategory(
      UpdateCategory event,
      Emitter<CategoryState> emit,
      ) async {
    try {
      if (event.category.categoryName.trim().isEmpty) {
        emit(const CategoryError(message: 'Nama kategori tidak boleh kosong'));
        return;
      }

      emit(const CategoryLoading());

      final response = await _categoryRepository.updateCategory(
        event.category.id!,
        event.category.toJson(),
      );

      if (response.success) {
        emit(const CategoryActionSuccess(message: 'Kategori berhasil diperbarui'));
        add(const LoadCategories());
      } else {
        emit(CategoryError(message: response.message));
      }
    } catch (e) {
      emit(CategoryError(message: 'Gagal memperbarui kategori: ${e.toString()}'));
    }
  }

  // ✅ DELETE CATEGORY
  Future<void> _onDeleteCategory(
      DeleteCategory event,
      Emitter<CategoryState> emit,
      ) async {
    try {
      emit(const CategoryLoading());

      final response = await _categoryRepository.deleteCategory(event.categoryId);

      if (response.success) {
        emit(const CategoryActionSuccess(message: 'Kategori berhasil dihapus'));
        add(const LoadCategories());
      } else {
        emit(CategoryError(message: response.message));
      }
    } catch (e) {
      emit(CategoryError(message: 'Gagal menghapus kategori: ${e.toString()}'));
    }
  }
}