// lib/blocs/product/product_bloc.dart

import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/product_repository.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository _productRepository;

  ProductBloc(this._productRepository) : super(const ProductInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<LoadMoreProducts>(_onLoadMoreProducts);
    on<AddProduct>(_onAddProduct);
    on<UpdateProduct>(_onUpdateProduct);
    on<DeleteProduct>(_onDeleteProduct);
    on<FilterProductsByCategory>(_onFilterProductsByCategory);
  }


  Future<void> _onLoadProducts(
      LoadProducts event,
      Emitter<ProductState> emit,
      ) async {
    emit(const ProductLoading());

    try {
      final response = await _productRepository.getProducts(
        limit: event.limit,
        page: 1,
      );

      if (response.success && response.data != null) {
        final products = response.data!.products;

        if (products.isEmpty) {
          emit(const ProductEmpty());
        } else {
          emit(ProductLoaded(
            products: products,
            currentPage: response.data!.currentPage,
            lastPage: response.data!.lastPage,
            hasNextPage: response.data!.hasNextPage,
            total: response.data!.total,
          ));
        }
      } else {
        emit(ProductError(message: response.message));
      }
    } catch (e) {
      emit(ProductError(message: 'Gagal memuat produk: ${e.toString()}'));
    }
  }

  // ✅ LOAD MORE PRODUCTS (Pagination)
  Future<void> _onLoadMoreProducts(
      LoadMoreProducts event,
      Emitter<ProductState> emit,
      ) async {
    final currentState = state;
    if (currentState is! ProductLoaded) return;
    if (!currentState.isLimited) return;
    if (!currentState.hasNextPage) return;

    emit(ProductLoadingMore(currentState));

    try {
      final response = await _productRepository.getProducts(
        limit: 20,
        page: currentState.currentPage + 1,
      );

      if (response.success && response.data != null) {
        final allProducts = [
          ...currentState.products,
          ...response.data!.products,
        ];

        emit(ProductLoaded(
          products: allProducts,
          currentPage: response.data!.currentPage,
          lastPage: response.data!.lastPage,
          hasNextPage: response.data!.hasNextPage,
          total: response.data!.total,
          filteredCategoryId: currentState.filteredCategoryId,
          isLimited: currentState.isLimited,
        ));
      } else {
        emit(ProductError(message: response.message));
      }
    } catch (e) {
      emit(ProductError(message: 'Gagal memuat produk: ${e.toString()}'));
    }
  }

  // ✅ ADD PRODUCT via API
  Future<void> _onAddProduct(
      AddProduct event,
      Emitter<ProductState> emit,
      ) async {
    try {
      // ✅ Validasi di client side tetap ada
      if (event.name.trim().isEmpty) {
        emit(const ProductError(message: 'Nama produk tidak boleh kosong'));
        return;
      }

      if (event.code.trim().isEmpty) {
        emit(const ProductError(message: 'Kode produk tidak boleh kosong'));
        return;
      }

      if (event.basePrice <= 0) {
        emit(const ProductError(message: 'Harga dasar harus lebih dari 0'));
        return;
      }

      if (event.sellingPrice <= 0) {
        emit(const ProductError(message: 'Harga jual harus lebih dari 0'));
        return;
      }

      if (event.stock < 0) {
        emit(const ProductError(message: 'Stok tidak boleh negatif'));
        return;
      }

      emit(const ProductLoading());

      // ✅ Buat ProductModel temporary
      final newProduct = ProductModel(
        productName: event.name.trim(),
        productCode: event.code.trim(),
        costPrice: event.basePrice,
        sellingPrice: event.sellingPrice,
        productStock: event.stock,
        productUnits: event.unit,
        productDiscount: event.discount,
        productDescription: event.description?.trim(),
        categoryId: event.categoryId,
      );


      // ✅ Kirim ke API
      final response = await _productRepository.createProduct(
        newProduct.toCreateJson(),
        event.photoFile, // File? dari image_picker
      );


      if (response.success) {
        emit(const ProductActionSuccess(message: 'Produk berhasil ditambahkan'));

        // ✅ Reload products dari API
        add(const LoadProducts());
      } else {
        emit(ProductError(message: response.message));
      }
    } catch (e) {
      emit(ProductError(message: 'Gagal menambahkan produk: ${e.toString()}'));
    }
  }

  // ✅ UPDATE PRODUCT via API
  Future<void> _onUpdateProduct(
      UpdateProduct event,
      Emitter<ProductState> emit,
      ) async {
    try {
      // ✅ Validasi
      if (event.product.productName.trim().isEmpty) {
        emit(const ProductError(message: 'Nama produk tidak boleh kosong'));
        return;
      }

      if (event.product.productCode.trim().isEmpty) {
        emit(const ProductError(message: 'Kode produk tidak boleh kosong'));
        return;
      }

      if (event.product.costPrice <= 0) {
        emit(const ProductError(message: 'Harga dasar harus lebih dari 0'));
        return;
      }

      if (event.product.sellingPrice <= 0) {
        emit(const ProductError(message: 'Harga jual harus lebih dari 0'));
        return;
      }

      emit(const ProductLoading());

      // ✅ Update via API
      final response = await _productRepository.updateProduct(
        event.product.id!,
        event.product.toJson(),
        event.photoFile, // File? untuk ganti foto
      );

      if (response.success) {
        emit(const ProductActionSuccess(message: 'Produk berhasil diperbarui'));

        // ✅ Reload products
        add(const LoadProducts());
      } else {
        emit(ProductError(message: response.message));
      }
    } catch (e) {
      emit(ProductError(message: 'Gagal memperbarui produk: ${e.toString()}'));
    }
  }

  // ✅ DELETE PRODUCT via API
  Future<void> _onDeleteProduct(
      DeleteProduct event,
      Emitter<ProductState> emit,
      ) async {
    try {
      emit(const ProductLoading());

      final response = await _productRepository.deleteProduct(event.productId);

      if (response.success) {
        emit(const ProductActionSuccess(message: 'Produk berhasil dihapus'));

        // ✅ Reload products
        add(const LoadProducts());
      } else {
        emit(ProductError(message: response.message));
      }
    } catch (e) {
      emit(ProductError(message: 'Gagal menghapus produk: ${e.toString()}'));
    }
  }

  // ✅ FILTER BY CATEGORY (Local filter dari data yang sudah di-load)
  Future<void> _onFilterProductsByCategory(
      FilterProductsByCategory event,
      Emitter<ProductState> emit,
      ) async {
    final currentState = state;
    if (currentState is! ProductLoaded) return;

    try {
      if (event.categoryId == null) {
        // Reset filter - tampilkan semua
        emit(currentState.copyWith(filteredCategoryId: null));
        return;
      }

      // Filter products yang sudah di-load
      emit(currentState.copyWith(filteredCategoryId: event.categoryId));
    } catch (e) {
      emit(ProductError(message: 'Gagal memfilter produk: ${e.toString()}'));
    }
  }
}