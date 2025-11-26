import 'package:dio/dio.dart';
import '../models/category_model.dart';
import '../models/api_response.dart';
import 'dio.dart';

class CategoryRepository {
  final Dio _dio = dio();

  // ✅ GET - Fetch categories dengan pagination
  Future<CategoryResponse> getCategories({
    int limit = 10,
    int page = 1,
  }) async {
    try {
      final response = await _dio.get(
        '/categories',
        queryParameters: {
          'limit': limit,
          'page': page,
        },
      );

      return CategoryResponse.fromJson(response.data);
    } catch (e) {
      return CategoryResponse(
        meta: Meta(
          code: 500,
          status: false,
          message: 'Gagal memuat kategori: ${e.toString()}',
        ),
      );
    }
  }

  // ✅ GET - List categories (tanpa pagination, untuk dropdown)
  Future<ApiResponse<List<CategoryModel>>> listCategories() async {
    try {
      final response = await _dio.get('/categories/list');

      if (response.data['success'] == true) {
        final categories = (response.data['data'] as List)
            .map((e) => CategoryModel.fromJson(e))
            .toList();

        return ApiResponse.success(
          message: response.data['message'],
          data: categories,
        );
      } else {
        return ApiResponse.error(
          message: response.data['message'],
        );
      }
    } catch (e) {
      return ApiResponse.error(
        message: 'Gagal memuat daftar kategori: ${e.toString()}',
      );
    }
  }

  // ✅ POST - Create category
  Future<ApiResponse<CategoryModel>> createCategory(
      Map<String, dynamic> data,
      ) async {
    try {
      final response = await _dio.post(
        '/categories/create',
        data: data,
      );

      if (response.data['meta']['status'] == true) {
        final category = CategoryModel.fromJson(response.data['data']);
        return ApiResponse.success(
          message: response.data['meta']['message'],
          data: category,
        );
      } else {
        return ApiResponse.error(
          message: response.data['meta']['message'],
        );
      }
    } catch (e) {
      return ApiResponse.error(
        message: 'Gagal menambahkan kategori: ${e.toString()}',
      );
    }
  }

  // ✅ PUT - Update category
  Future<ApiResponse<CategoryModel>> updateCategory(
      int id,
      Map<String, dynamic> data,
      ) async {
    try {
      final response = await _dio.put(
        '/categories/$id/update',
        data: data,
      );

      if (response.data['meta']['status'] == true) {
        final category = CategoryModel.fromJson(response.data['data']);
        return ApiResponse.success(
          message: response.data['meta']['message'],
          data: category,
        );
      } else {
        return ApiResponse.error(
          message: response.data['meta']['message'],
        );
      }
    } catch (e) {
      return ApiResponse.error(
        message: 'Gagal memperbarui kategori: ${e.toString()}',
      );
    }
  }

  // ✅ DELETE - Delete category
  Future<ApiResponse<void>> deleteCategory(int id) async {
    try {
      final response = await _dio.delete('/categories/$id/delete');

      if (response.data['meta']['status'] == true) {
        return ApiResponse.success(
          message: response.data['meta']['message'],
        );
      } else {
        return ApiResponse.error(
          message: response.data['meta']['message'],
        );
      }
    } catch (e) {
      return ApiResponse.error(
        message: 'Gagal menghapus kategori: ${e.toString()}',
      );
    }
  }
}