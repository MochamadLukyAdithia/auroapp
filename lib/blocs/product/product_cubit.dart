// bloc/product/product_search_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/product_model.dart';

class ProductSearchState {
  final String query;
  final List<ProductModel> filteredProducts;
  final List<ProductModel> allProducts;
  final ProductFilterState filterState;

  ProductSearchState({
    required this.query,
    required this.filteredProducts,
    required this.allProducts,
    required this.filterState,
  });

  ProductSearchState copyWith({
    String? query,
    List<ProductModel>? filteredProducts,
    List<ProductModel>? allProducts,
    ProductFilterState? filterState,
  }) {
    return ProductSearchState(
      query: query ?? this.query,
      filteredProducts: filteredProducts ?? this.filteredProducts,
      allProducts: allProducts ?? this.allProducts,
      filterState: filterState ?? this.filterState,
    );
  }
}

class ProductSearchCubit extends Cubit<ProductSearchState> {
  ProductSearchCubit()
      : super(ProductSearchState(
    query: '',
    filteredProducts: [],
    allProducts: [],
    filterState: ProductFilterState(),
  ));

  // ✅ Set products dari ProductBloc
  void setProducts(List<ProductModel> products) {
    emit(state.copyWith(
      allProducts: products,
      filteredProducts: _applyFilters(products, state.query, state.filterState),
    ));
  }

  void searchProducts(String query) {
    emit(state.copyWith(
      query: query,
      filteredProducts: _applyFilters(state.allProducts, query, state.filterState),
    ));
  }

  void applyFilter(ProductFilterState filterState) {
    emit(state.copyWith(
      filterState: filterState,
      filteredProducts: _applyFilters(state.allProducts, state.query, filterState),
    ));
  }

  void resetFilter() {
    final defaultFilter = ProductFilterState();
    emit(state.copyWith(
      filterState: defaultFilter,
      filteredProducts: _applyFilters(state.allProducts, state.query, defaultFilter),
    ));
  }

  void clearSearch() {
    emit(state.copyWith(
      query: '',
      filteredProducts: _applyFilters(state.allProducts, '', state.filterState),
    ));
  }

  void filterByCategory(int? categoryId) {
    if (categoryId == null) {
      emit(state.copyWith(
        filteredProducts: _applyFilters(state.allProducts, state.query, state.filterState),
      ));
      return;
    }

    final filtered = state.allProducts
        .where((product) => product.categoryId == categoryId)
        .toList();

    emit(state.copyWith(
      filteredProducts: _applyFilters(filtered, state.query, state.filterState),
    ));
  }

  List<ProductModel> _applyFilters(
      List<ProductModel> products,
      String query,
      ProductFilterState filterState,
      ) {
    var filtered = products;

    // 1️⃣ Filter by search query
    if (query.isNotEmpty) {
      filtered = filtered.where((product) {
        final searchLower = query.toLowerCase();
        final nameLower = product.productName.toLowerCase(); // ✅ Update field
        final codeLower = product.productCode.toLowerCase(); // ✅ Update field
        return nameLower.contains(searchLower) || codeLower.contains(searchLower);
      }).toList();
    }

    // 2️⃣ Filter by stock status
    if (filterState.stockStatus != StockFilterType.all) {
      filtered = filtered.where((product) {
        final stock = product.productStock; // ✅ Update field
        switch (filterState.stockStatus) {
          case StockFilterType.empty:
            return stock == 0;
          case StockFilterType.low:
            return stock! > 0 && stock <= 5;
          case StockFilterType.available:
            return stock! > 5;
          case StockFilterType.all:
          default:
            return true;
        }
      }).toList();
    }

    // 3️⃣ Sort products
    switch (filterState.sortBy) {
      case SortType.nameAsc:
        filtered.sort((a, b) => a.productName.toLowerCase().compareTo(b.productName.toLowerCase()));
        break;
      case SortType.nameDesc:
        filtered.sort((a, b) => b.productName.toLowerCase().compareTo(a.productName.toLowerCase()));
        break;
      case SortType.codeAsc:
        filtered.sort((a, b) => a.productCode.toLowerCase().compareTo(b.productCode.toLowerCase()));
        break;
      case SortType.codeDesc:
        filtered.sort((a, b) => b.productCode.toLowerCase().compareTo(a.productCode.toLowerCase()));
        break;
      case SortType.priceAsc:
        filtered.sort((a, b) => a.sellingPrice.compareTo(b.sellingPrice));
        break;
      case SortType.priceDesc:
        filtered.sort((a, b) => b.sellingPrice.compareTo(a.sellingPrice));
        break;
      case SortType.stockAsc:
        filtered.sort((a, b) {
          final stockA = a.productStock ?? 0;
          final stockB = b.productStock ?? 0;
          return stockA.compareTo(stockB);
        });
        break;

      case SortType.stockDesc:
        filtered.sort((a, b) {
          final stockA = a.productStock ?? 0;
          final stockB = b.productStock ?? 0;
          return stockB.compareTo(stockA);
        });
        break;
      case SortType.newest:
        filtered.sort((a, b) {
          if (a.createdAt == null || b.createdAt == null) return 0;
          return b.createdAt!.compareTo(a.createdAt!);
        });
        break;
      case SortType.oldest:
        filtered.sort((a, b) {
          if (a.createdAt == null || b.createdAt == null) return 0;
          return a.createdAt!.compareTo(b.createdAt!);
        });
        break;
    }

    return filtered;
  }
}

// ============================================================
// 🎯 ENUMS untuk Sort & Filter
// ============================================================

enum SortType {
  newest,
  oldest,
  nameAsc,
  nameDesc,
  codeAsc,
  codeDesc,
  priceAsc,
  priceDesc,
  stockAsc,
  stockDesc,
}

enum StockFilterType {
  all,
  available,
  low,
  empty,
}

// ============================================================
// 🎯 FILTER STATE
// ============================================================

class ProductFilterState {
  final SortType sortBy;
  final StockFilterType stockStatus;

  ProductFilterState({
    this.sortBy = SortType.newest,
    this.stockStatus = StockFilterType.all,
  });

  ProductFilterState copyWith({
    SortType? sortBy,
    StockFilterType? stockStatus,
  }) {
    return ProductFilterState(
      sortBy: sortBy ?? this.sortBy,
      stockStatus: stockStatus ?? this.stockStatus,
    );
  }

  bool get hasActiveFilter {
    return sortBy != SortType.newest || stockStatus != StockFilterType.all;
  }

  // Helper untuk mendapatkan label
  String get sortLabel {
    switch (sortBy) {
      case SortType.newest:
        return 'Terbaru';
      case SortType.oldest:
        return 'Terlama';
      case SortType.nameAsc:
        return 'Nama (A-Z)';
      case SortType.nameDesc:
        return 'Nama (Z-A)';
      case SortType.codeAsc:
        return 'Kode (A-Z)';
      case SortType.codeDesc:
        return 'Kode (Z-A)';
      case SortType.priceAsc:
        return 'Harga Terendah';
      case SortType.priceDesc:
        return 'Harga Tertinggi';
      case SortType.stockAsc:
        return 'Stok Terendah';
      case SortType.stockDesc:
        return 'Stok Tertinggi';
    }
  }

  String get stockLabel {
    switch (stockStatus) {
      case StockFilterType.all:
        return 'Semua';
      case StockFilterType.available:
        return 'Tersedia (>10)';
      case StockFilterType.low:
        return 'Menipis (1-10)';
      case StockFilterType.empty:
        return 'Habis (0)';
    }
  }
}