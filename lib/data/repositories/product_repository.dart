import 'dart:io';
import 'package:dio/dio.dart';
import 'package:pos_mobile/data/models/product_model.dart';
import '../models/api_response.dart';
import 'dio.dart';

class ProductRepository {
  final Dio _dio = dio();


  // GET
  Future<ProductResponse> getProducts({
    int? limit,
    int page = 1,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
      };

      if (limit != null) {
        queryParams['limit'] = limit;
      }

      final response = await _dio.get(
        '/products',
        queryParameters: {
          'limit': limit,
          'page': page,
        },
      );

      return ProductResponse.fromJson(response.data);
    } catch (e) {
      return ProductResponse(
        meta: Meta(
          code: 500,
          status: false,
          message: 'Gagal memuat produk: ${e.toString()}',
        ),
      );
    }
  }

  // POST
  Future<ApiResponse<ProductModel>> createProduct(
      Map<String, dynamic> data,
      File? photoFile,
      ) async {
    try {
      FormData formData = FormData.fromMap(data);

      if (photoFile != null) {
        String fileName = photoFile.path.split('/').last;
        formData.files.add(
          MapEntry(
            'product_photo',
            await MultipartFile.fromFile(
              photoFile.path,
              filename: fileName,
            ),
          ),
        );
      }

      final response = await _dio.post(
        '/products/create',
        data: formData,
      );

      if (response.data['meta']['status'] == true) {
        final product = ProductModel.fromJson(response.data['data']);
        return ApiResponse(
          success: true,
          message: response.data['meta']['message'],
          data: product,
        );
      } else {
        return ApiResponse(
          success: false,
          message: response.data['meta']['message'],
        );
      }
    } on DioException catch (e) {
      String errorMessage = 'Gagal menambahkan produk';
      if (e.response?.data != null) {
        if (e.response!.data is Map) {
          errorMessage = e.response!.data['message'] ??
              e.response!.data['meta']?['message'] ??
              errorMessage;
        }
      }
      return ApiResponse(
        success: false,
        message: errorMessage,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Gagal menambahkan produk: ${e.toString()}',
      );
    }
  }


  Future<ApiResponse<ProductModel>> getProduct(int id) async {
    try {
      final response = await _dio.get('/products/$id');

      if (response.data['success'] == true) {
        final product = ProductModel.fromJson(response.data['data']);
        return ApiResponse(
          success: true,
          message: 'Product retrieved successfully',
          data: product,
        );
      } else {
        return ApiResponse(
          success: false,
          message: response.data['message'],
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Gagal memuat detail produk: ${e.toString()}',
      );
    }
  }

  // POST
  Future<ApiResponse<ProductModel>> updateProduct(
      int id,
      Map<String, dynamic> data,
      File? photoFile,
      ) async {
    try {
      FormData formData = FormData.fromMap(data);

      // Field foto untuk update: 'imageFile'
      if (photoFile != null) {
        String fileName = photoFile.path.split('/').last;
        formData.files.add(
          MapEntry(
            'imageFile',
            await MultipartFile.fromFile(
              photoFile.path,
              filename: fileName,
            ),
          ),
        );
      }

      final response = await _dio.post(
        '/products/$id/update',
        data: formData,
      );

      if (response.data['meta']['status'] == true) {
        final product = ProductModel.fromJson(response.data['data']);
        return ApiResponse(
          success: true,
          message: response.data['meta']['message'],
          data: product,
        );
      } else {
        return ApiResponse(
          success: false,
          message: response.data['meta']['message'],
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Gagal memperbarui produk: ${e.toString()}',
      );
    }
  }

  Future<ApiResponse<void>> deleteProduct(int id) async {
    try {
      final response = await _dio.delete('/products/$id/delete');

      if (response.data['meta']['status'] == true) {
        return ApiResponse(
          success: true,
          message: response.data['meta']['message'],
        );
      } else {
        return ApiResponse(
          success: false,
          message: response.data['meta']['message'],
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Gagal menghapus produk: ${e.toString()}',
      );
    }
  }
}