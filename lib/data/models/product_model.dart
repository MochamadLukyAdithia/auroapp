// import 'package:equatable/equatable.dart';
//
// class ProductModel extends Equatable {
//   final int? id;
//   final String? productPhoto;
//   final String productName;
//   final String productCode;
//   final double costPrice;
//   final double sellingPrice;
//   final int? productStock;
//   final String productUnits;
//   final double productDiscount;
//   final String? productDescription;
//   final int? categoryId;
//   final String? categoryName;
//   final int? companyId;
//   final DateTime? createdAt;
//   final DateTime? updatedAt;
//   final bool? hasTransactions;
//
//   const ProductModel({
//     this.id,
//     this.productPhoto,
//     required this.productName,
//     required this.productCode,
//     required this.costPrice,
//     required this.sellingPrice,
//     this.productStock,
//     required this.productUnits,
//     this.productDiscount = 0,
//     this.productDescription,
//     this.categoryId,
//     this.categoryName,
//     this.companyId,
//     this.createdAt,
//     this.updatedAt,
//     this.hasTransactions,
//   });
//
//   factory ProductModel.fromJson(Map<String, dynamic> json) {
//     return ProductModel(
//       id: _parseInt(json['id']),
//       productPhoto: json['product_photo'],
//       productName: json['product_name'] ?? '',
//       productCode: json['product_code'] ?? '',
//       costPrice: _parseDouble(json['cost_price']),
//       sellingPrice: _parseDouble(json['selling_price']),
//       productStock: json['product_stock'] != null ? _parseInt(json['product_stock']) : null,
//       productUnits: json['product_units'],
//       productDiscount: _parseDouble(json['product_discount']),
//       productDescription: json['product_description'],
//       categoryId: json['category_id'] != null ? _parseInt(json['category_id']) : null,
//       categoryName: json['category_name'],
//       companyId: _parseInt(json['company_id']),
//       createdAt: json['created_at'] != null
//           ? DateTime.tryParse(json['created_at'].toString())
//           : null,
//       updatedAt: json['updated_at'] != null
//           ? DateTime.tryParse(json['updated_at'].toString())
//           : null,
//       hasTransactions: json['has_transactions'] as bool?,
//     );
//   }
//
//   static int? _parseInt(dynamic value) {
//     if (value == null) return null;
//     if (value is int) return value;
//     if (value is double) return value.toInt();
//     if (value is String) return int.tryParse(value);
//     return null;
//   }
//
//   static double _parseDouble(dynamic value) {
//     if (value == null) return 0.0;
//     if (value is double) return value;
//     if (value is int) return value.toDouble();
//     if (value is String) return double.tryParse(value) ?? 0.0;
//     return 0.0;
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'product_name': productName,
//       'product_code': productCode,
//       'cost_price': costPrice,
//       'selling_price': sellingPrice,
//       'product_stock': productStock,
//       'product_units': productUnits,
//       'product_discount': productDiscount,
//       'product_description': productDescription,
//       'category_id': categoryId,
//     };
//   }
//
//   Map<String, dynamic> toCreateJson() {
//     return {
//       'product_name': productName,
//       'product_code': productCode,
//       'cost_price': costPrice.toString(),
//       'selling_price': sellingPrice.toString(),
//       'product_stock': productStock.toString(),
//       'product_units': productUnits,
//       'product_discount': (productDiscount ?? 0).toString(),
//       'product_description': productDescription ?? '',
//       'category_id': categoryId.toString(),
//     };
//   }
//
//   Map<String, dynamic> toUpdateJson() {
//     return {
//       'product_name': productName,
//       'product_code': productCode,
//       'cost_price': costPrice.toString(),
//       'selling_price': sellingPrice.toString(),
//       'product_units': productUnits,
//       'product_discount': productDiscount.toString(),
//       'product_description': productDescription ?? '',
//       'category_id': categoryId.toString(),
//     };
//   }
//
//   ProductModel copyWith({
//     int? id,
//     String? productPhoto,
//     String? productName,
//     String? productCode,
//     double? costPrice,
//     double? sellingPrice,
//     int? productStock,
//     String? productUnits,
//     double? productDiscount,
//     String? productDescription,
//     int? categoryId,
//     String? categoryName,
//     int? companyId,
//     DateTime? createdAt,
//     DateTime? updatedAt,
//   }) {
//     return ProductModel(
//       id: id ?? this.id,
//       productPhoto: productPhoto ?? this.productPhoto,
//       productName: productName ?? this.productName,
//       productCode: productCode ?? this.productCode,
//       costPrice: costPrice ?? this.costPrice,
//       sellingPrice: sellingPrice ?? this.sellingPrice,
//       productStock: productStock ?? this.productStock,
//       productUnits: productUnits ?? this.productUnits,
//       productDiscount: productDiscount ?? this.productDiscount,
//       productDescription: productDescription ?? this.productDescription,
//       categoryId: categoryId ?? this.categoryId,
//       categoryName: categoryName ?? this.categoryName,
//       companyId: companyId ?? this.companyId,
//       createdAt: createdAt ?? this.createdAt,
//       updatedAt: updatedAt ?? this.updatedAt,
//     );
//   }
//
//   @override
//   List<Object?> get props => [
//     id, productPhoto, productName, productCode, costPrice,
//     sellingPrice, productStock, productUnits, productDiscount,
//     productDescription, categoryId, categoryName, companyId,
//     createdAt, updatedAt, hasTransactions
//   ];
// }
//
//
// class ProductResponse {
//   final Meta meta;
//   final PaginatedProductData? data;
//   final int? totalRecords;
//
//   ProductResponse({
//     required this.meta,
//     this.data,
//     this.totalRecords,
//   });
//
//   factory ProductResponse.fromJson(Map<String, dynamic> json) {
//     return ProductResponse(
//       meta: Meta.fromJson(json['meta']),
//       data: json['data'] != null
//           ? PaginatedProductData.fromJson(json['data'])
//           : null,
//       totalRecords: json['totalRecords'],
//     );
//   }
//
//   bool get success => meta.status;
//   String get message => meta.message ?? '';
// }
//
// class PaginatedProductData {
//   final int currentPage;
//   final List<ProductModel> products;
//   final String? firstPageUrl;
//   final int? from;
//   final int lastPage;
//   final String? lastPageUrl;
//   final String? nextPageUrl;
//   final String path;
//   final int perPage;
//   final String? prevPageUrl;
//   final int? to;
//   final int total;
//
//   PaginatedProductData({
//     required this.currentPage,
//     required this.products,
//     this.firstPageUrl,
//     this.from,
//     required this.lastPage,
//     this.lastPageUrl,
//     this.nextPageUrl,
//     required this.path,
//     required this.perPage,
//     this.prevPageUrl,
//     this.to,
//     required this.total,
//   });
//
//   factory PaginatedProductData.fromJson(Map<String, dynamic> json) {
//     return PaginatedProductData(
//       currentPage: json['current_page'] ?? 1,
//       products: (json['data'] as List)
//           .map((e) => ProductModel.fromJson(e))
//           .toList(),
//       firstPageUrl: json['first_page_url'],
//       from: json['from'],
//       lastPage: json['last_page'] ?? 1,
//       lastPageUrl: json['last_page_url'],
//       nextPageUrl: json['next_page_url'],
//       path: json['path'] ?? '',
//       perPage: json['per_page'] ?? 10,
//       prevPageUrl: json['prev_page_url'],
//       to: json['to'],
//       total: json['total'] ?? 0,
//     );
//   }
//
//   bool get hasNextPage => nextPageUrl != null;
//   bool get hasPrevPage => prevPageUrl != null;
//   bool get isFirstPage => currentPage == 1;
//   bool get isLastPage => currentPage == lastPage;
// }
//
// // ✅ FIXED: Meta class dengan parsing yang lebih robust
// class Meta {
//   final int code;
//   final bool status;
//   final String? message;
//
//   Meta({
//     required this.code,
//     required this.status,
//     this.message,
//   });
//
//   factory Meta.fromJson(Map<String, dynamic> json) {
//     return Meta(
//       code: _parseInt(json['code']) ?? 0,  // ✅ FIX: Parse dengan safety
//       status: json['status'] == true || json['status'] == 1 || json['status'] == '1',  // ✅ Handle berbagai tipe boolean
//       message: json['message']?.toString(),
//     );
//   }
//
//   // ✅ Helper untuk parsing int
//   static int? _parseInt(dynamic value) {
//     if (value == null) return null;
//     if (value is int) return value;
//     if (value is double) return value.toInt();
//     if (value is String) return int.tryParse(value);
//     return null;
//   }
// }


import 'package:equatable/equatable.dart';

class ProductModel extends Equatable {
  final int? id;
  final String? productPhoto;
  final String productName;
  final String productCode;
  final double costPrice;
  final double sellingPrice;
  final int? productStock;
  final String productUnits;
  final double productDiscount;
  final String? productDescription;
  final int? categoryId;
  final String? categoryName;
  final int? companyId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool? hasTransactions;

  const ProductModel({
    this.id,
    this.productPhoto,
    required this.productName,
    required this.productCode,
    required this.costPrice,
    required this.sellingPrice,
    this.productStock,
    required this.productUnits,
    this.productDiscount = 0,
    this.productDescription,
    this.categoryId,
    this.categoryName,
    this.companyId,
    this.createdAt,
    this.updatedAt,
    this.hasTransactions,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: _parseInt(json['id']),
      productPhoto: json['product_photo'],
      productName: json['product_name'] ?? '',
      productCode: json['product_code'] ?? '',
      costPrice: _parseDouble(json['cost_price']),
      sellingPrice: _parseDouble(json['selling_price']),
      productStock: json['product_stock'] != null ? _parseInt(json['product_stock']) : null,
      productUnits: json['product_units'],
      productDiscount: _parseDouble(json['product_discount']),
      productDescription: json['product_description'],
      categoryId: json['category_id'] != null ? _parseInt(json['category_id']) : null,
      categoryName: json['category_name'],
      companyId: _parseInt(json['company_id']),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      hasTransactions: json['has_transactions'] as bool?,
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'product_name': productName,
      'product_code': productCode,
      'cost_price': costPrice,
      'selling_price': sellingPrice,
      'product_stock': productStock,
      'product_units': productUnits,
      'product_discount': productDiscount,
      'product_description': productDescription,
      'category_id': categoryId,
    };
  }

  // ✅ FIXED: toCreateJson sesuai dengan backend validation
  Map<String, dynamic> toCreateJson() {
    return {
      'product_name': productName,
      'product_code': productCode,
      'cost_price': costPrice.toString(),
      'selling_price': sellingPrice.toString(),
      'product_stock': (productStock ?? 0).toString(), // ✅ Handle null dengan default 0
      'product_units': productUnits,
      'product_discount': (productDiscount ?? 0).toString(), // ✅ Nullable jadi kirim 0 jika null
      'product_description': productDescription ?? '', // ✅ Nullable jadi kirim empty string
      'category_id': categoryId.toString(),
      // ❌ TIDAK perlu kirim is_active, backend sudah handle
      // ❌ TIDAK perlu kirim company_id, backend ambil dari Auth
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'product_name': productName,
      'product_code': productCode,
      'cost_price': costPrice.toString(),
      'selling_price': sellingPrice.toString(),
      'product_units': productUnits,
      'product_discount': productDiscount.toString(),
      'product_description': productDescription ?? '',
      'category_id': categoryId.toString(),
    };
  }

  ProductModel copyWith({
    int? id,
    String? productPhoto,
    String? productName,
    String? productCode,
    double? costPrice,
    double? sellingPrice,
    int? productStock,
    String? productUnits,
    double? productDiscount,
    String? productDescription,
    int? categoryId,
    String? categoryName,
    int? companyId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      productPhoto: productPhoto ?? this.productPhoto,
      productName: productName ?? this.productName,
      productCode: productCode ?? this.productCode,
      costPrice: costPrice ?? this.costPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      productStock: productStock ?? this.productStock,
      productUnits: productUnits ?? this.productUnits,
      productDiscount: productDiscount ?? this.productDiscount,
      productDescription: productDescription ?? this.productDescription,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      companyId: companyId ?? this.companyId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id, productPhoto, productName, productCode, costPrice,
    sellingPrice, productStock, productUnits, productDiscount,
    productDescription, categoryId, categoryName, companyId,
    createdAt, updatedAt, hasTransactions
  ];
}


class ProductResponse {
  final Meta meta;
  final PaginatedProductData? data;
  final int? totalRecords;

  ProductResponse({
    required this.meta,
    this.data,
    this.totalRecords,
  });

  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    return ProductResponse(
      meta: Meta.fromJson(json['meta']),
      data: json['data'] != null
          ? PaginatedProductData.fromJson(json['data'])
          : null,
      totalRecords: json['totalRecords'],
    );
  }

  bool get success => meta.status;
  String get message => meta.message ?? '';
}

class PaginatedProductData {
  final int currentPage;
  final List<ProductModel> products;
  final String? firstPageUrl;
  final int? from;
  final int lastPage;
  final String? lastPageUrl;
  final String? nextPageUrl;
  final String path;
  final int perPage;
  final String? prevPageUrl;
  final int? to;
  final int total;

  PaginatedProductData({
    required this.currentPage,
    required this.products,
    this.firstPageUrl,
    this.from,
    required this.lastPage,
    this.lastPageUrl,
    this.nextPageUrl,
    required this.path,
    required this.perPage,
    this.prevPageUrl,
    this.to,
    required this.total,
  });

  factory PaginatedProductData.fromJson(Map<String, dynamic> json) {
    return PaginatedProductData(
      currentPage: json['current_page'] ?? 1,
      products: (json['data'] as List)
          .map((e) => ProductModel.fromJson(e))
          .toList(),
      firstPageUrl: json['first_page_url'],
      from: json['from'],
      lastPage: json['last_page'] ?? 1,
      lastPageUrl: json['last_page_url'],
      nextPageUrl: json['next_page_url'],
      path: json['path'] ?? '',
      perPage: json['per_page'] ?? 10,
      prevPageUrl: json['prev_page_url'],
      to: json['to'],
      total: json['total'] ?? 0,
    );
  }

  bool get hasNextPage => nextPageUrl != null;
  bool get hasPrevPage => prevPageUrl != null;
  bool get isFirstPage => currentPage == 1;
  bool get isLastPage => currentPage == lastPage;
}

class Meta {
  final int code;
  final bool status;
  final String? message;

  Meta({
    required this.code,
    required this.status,
    this.message,
  });

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      code: _parseInt(json['code']) ?? 0,
      status: json['status'] == true || json['status'] == 1 || json['status'] == '1',
      message: json['message']?.toString(),
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}