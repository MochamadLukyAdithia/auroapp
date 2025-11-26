import 'package:equatable/equatable.dart';

class CategoryModel extends Equatable {
  final int? id;
  final String categoryName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CategoryModel({
    this.id,
    required this.categoryName,
    this.createdAt,
    this.updatedAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int,
      categoryName: json['category_name'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': categoryName, // Backend expect 'name'
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'name': categoryName, // Backend expect 'name'
    };
  }

  CategoryModel copyWith({
    int? id,
    String? categoryName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      categoryName: categoryName ?? this.categoryName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, categoryName, createdAt, updatedAt];
}

class CategoryResponse {
  final Meta meta;
  final PaginatedCategoryData? data;

  CategoryResponse({
    required this.meta,
    this.data,
  });

  factory CategoryResponse.fromJson(Map<String, dynamic> json) {
    return CategoryResponse(
      meta: Meta.fromJson(json['meta']),
      data: json['data'] != null
          ? PaginatedCategoryData.fromJson(json['data'])
          : null,
    );
  }

  bool get success => meta.status;
  String get message => meta.message ?? '';
}

class PaginatedCategoryData {
  final int currentPage;
  final List<CategoryModel> categories;
  final int lastPage;
  final String? nextPageUrl;
  final String? prevPageUrl;
  final int perPage;
  final int total;

  PaginatedCategoryData({
    required this.currentPage,
    required this.categories,
    required this.lastPage,
    this.nextPageUrl,
    this.prevPageUrl,
    required this.perPage,
    required this.total,
  });

  factory PaginatedCategoryData.fromJson(Map<String, dynamic> json) {
    return PaginatedCategoryData(
      currentPage: json['current_page'] ?? 1,
      categories: (json['data'] as List)
          .map((e) => CategoryModel.fromJson(e))
          .toList(),
      lastPage: json['last_page'] ?? 1,
      nextPageUrl: json['next_page_url'],
      prevPageUrl: json['prev_page_url'],
      perPage: json['per_page'] ?? 10,
      total: json['total'] ?? 0,
    );
  }

  bool get hasNextPage => nextPageUrl != null;
  bool get hasPrevPage => prevPageUrl != null;
}

// Reuse Meta dari models lain atau buat ulang
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
      code: json['code'],
      status: json['status'],
      message: json['message'],
    );
  }
}