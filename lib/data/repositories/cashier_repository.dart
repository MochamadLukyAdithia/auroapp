import '../models/cashier_model.dart';
import '../models/api_response.dart';
import 'dio.dart';
import 'package:dio/dio.dart';

class CashierRepository {
  final Dio _dio = dio();

  Future<ApiResponse<Map<String, dynamic>>> getCashiers({
    int? limit,
    String? search,
  }) async {
    try {
      final response = await _dio.get(
        '/users',
        queryParameters: {
          'role': 'cashier',
          if (limit != null) 'limit': limit,
          if (search != null && search.isNotEmpty) 'search': search,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        final meta = response.data['meta'];

        final List<Cashier> cashiers = (data['data'] as List)
            .map((json) => Cashier.fromJson(json))
            .toList();

        return ApiResponse.success(
          message: meta['message'] ?? 'Cashiers retrieved successfully',
          data: {
            'cashiers': cashiers,
            'current_page': data['current_page'],
            'last_page': data['last_page'],
            'per_page': data['per_page'],
            'total': data['total'],
          },
          code: response.statusCode!,
        );
      }

      return ApiResponse.error(
        message: response.data['meta']?['message'] ?? 'Failed to fetch cashiers',
        code: response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      if (e.response != null) {
        final meta = e.response?.data['meta'];
        return ApiResponse.error(
          message: meta?['message'] ?? 'Failed to fetch cashiers',
          code: e.response?.statusCode ?? 500,
        );
      }
      return ApiResponse.error(
        message: 'Network error: ${e.message}',
        code: 500,
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'Unexpected error: ${e.toString()}',
        code: 500,
      );
    }
  }

  Future<ApiResponse<Cashier>> createCashier({
    required Cashier cashier,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await _dio.post(
        '/users/create',
        data: cashier.toCreateJson(
          password: password,
          passwordConfirmation: passwordConfirmation,
        ),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final meta = response.data['meta'];
        return ApiResponse.success(
          message: meta['message'] ?? 'Cashier created successfully',
          data: null,
          code: response.statusCode!,
        );
      }

      return ApiResponse.error(
        message: response.data['meta']?['message'] ?? 'Failed to create cashier',
        code: response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      if (e.response != null) {
        final meta = e.response?.data['meta'];

        if (e.response?.statusCode == 422) {
          final errors = e.response?.data['data'];
          String errorMessage = 'Validation failed';

          if (errors != null && errors is Map) {
            errorMessage = errors.values.first is List
                ? (errors.values.first as List).first
                : errors.values.first.toString();
          }

          return ApiResponse.error(
            message: errorMessage,
            code: 422,
          );
        }

        return ApiResponse.error(
          message: meta?['message'] ?? 'Failed to create cashier',
          code: e.response?.statusCode ?? 500,
        );
      }
      return ApiResponse.error(
        message: 'Network error: ${e.message}',
        code: 500,
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'Unexpected error: ${e.toString()}',
        code: 500,
      );
    }
  }

  Future<ApiResponse<Cashier>> updateCashier({
    required int id,
    required Cashier cashier,
    String? password,
    String? passwordConfirmation,
  }) async {
    try {
      final response = await _dio.put(
        '/users/$id/update',
        data: cashier.toUpdateJson(
          password: password,
          passwordConfirmation: passwordConfirmation,
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final meta = response.data['meta'];
        return ApiResponse.success(
          message: meta['message'] ?? 'Cashier updated successfully',
          data: null,
          code: response.statusCode!,
        );
      }

      return ApiResponse.error(
        message: response.data['meta']?['message'] ?? 'Failed to update cashier',
        code: response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      if (e.response != null) {
        final meta = e.response?.data['meta'];

        if (e.response?.statusCode == 422) {
          final errors = e.response?.data['data'];
          String errorMessage = 'Validation failed';

          if (errors != null && errors is Map) {
            errorMessage = errors.values.first is List
                ? (errors.values.first as List).first
                : errors.values.first.toString();
          }

          return ApiResponse.error(
            message: errorMessage,
            code: 422,
          );
        }

        if (e.response?.statusCode == 404) {
          return ApiResponse.error(
            message: 'Cashier not found',
            code: 404,
          );
        }

        return ApiResponse.error(
          message: meta?['message'] ?? 'Failed to update cashier',
          code: e.response?.statusCode ?? 500,
        );
      }
      return ApiResponse.error(
        message: 'Network error: ${e.message}',
        code: 500,
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'Unexpected error: ${e.toString()}',
        code: 500,
      );
    }
  }

  Future<ApiResponse<void>> deleteCashier(int id) async {
    try {
      final response = await _dio.delete('/users/$id/delete');

      if (response.statusCode == 200 || response.statusCode == 202) {
        final meta = response.data['meta'];
        return ApiResponse.success(
          message: meta['message'] ?? 'Cashier deleted successfully',
          code: response.statusCode!,
        );
      }

      return ApiResponse.error(
        message: response.data['meta']?['message'] ?? 'Failed to delete cashier',
        code: response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      if (e.response != null) {
        final meta = e.response?.data['meta'];

        if (e.response?.statusCode == 404) {
          return ApiResponse.error(
            message: 'Cashier not found',
            code: 404,
          );
        }

        return ApiResponse.error(
          message: meta?['message'] ?? 'Failed to delete cashier',
          code: e.response?.statusCode ?? 500,
        );
      }
      return ApiResponse.error(
        message: 'Network error: ${e.message}',
        code: 500,
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'Unexpected error: ${e.toString()}',
        code: 500,
      );
    }
  }
}