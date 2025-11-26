// repositories/customer_repository.dart
import 'package:dio/dio.dart';
import '../models/api_response.dart';
import '../models/customer_model.dart';
import 'dio.dart';


class CustomerRepository {
  final Dio _dio = dio(); // ✅ Gunakan Dio instance yang sudah ada

  // ✅ Get All Customers (dengan pagination & search)
  Future<ApiResponse<Map<String, dynamic>>> getCustomers({
    int page = 1,
    int? limit,
    String? search,
  }) async {
    try {
      final response = await _dio.get(
        '/customers',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (search != null && search.isNotEmpty) 'search': search,
        },
      );

      final json = response.data;

      // ✅ Backend menggunakan struktur: { meta: {...}, data: {...} }
      if (response.statusCode == 200) {
        final meta = json['meta'];
        final data = json['data'];

        // Cek success dari meta
        final isSuccess = meta['status'] == true || meta['success'] == true;

        if (isSuccess) {
          final customerList = data['data'] as List;
          final customers = customerList
              .map((item) => Customer.fromJson(item))
              .toList();

          return ApiResponse.success(
            message: meta['message'] ?? 'Customers retrieved successfully',
            data: {
              'customers': customers,
              'current_page': data['current_page'] ?? 1,
              'last_page': data['last_page'] ?? 1,
              'per_page': data['per_page'] ?? customers.length,
              'total': data['total'] ?? customers.length,
            },
            code: meta['code'] ?? response.statusCode ?? 200,
          );
        }
      }

      return ApiResponse.error(
        message: json['meta']?['message'] ?? 'Failed to get customers',
        code: json['meta']?['code'] ?? response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e, stackTrace) {
      print('Error in getCustomers: $e');
      print('StackTrace: $stackTrace');
      return ApiResponse.error(
        message: 'Unexpected error: ${e.toString()}',
        code: 500,
      );
    }
  }

  // ✅ Get Customer by ID
  Future<ApiResponse<Customer>> getCustomer(String id) async {
    try {
      final response = await _dio.get('/customers/$id');
      final json = response.data;

      if (response.statusCode == 200) {
        final meta = json['meta'];
        final isSuccess = meta['status'] == true || meta['success'] == true;

        if (isSuccess) {
          return ApiResponse.success(
            message: meta['message'] ?? 'Customer retrieved successfully',
            data: Customer.fromJson(json['data']),
            code: meta['code'] ?? response.statusCode ?? 200,
          );
        }
      }

      return ApiResponse.error(
        message: json['meta']?['message'] ?? 'Customer not found',
        code: json['meta']?['code'] ?? response.statusCode ?? 404,
      );
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse.error(
        message: 'Unexpected error: ${e.toString()}',
        code: 500,
      );
    }
  }

  // ✅ Add Customer
  Future<ApiResponse<Customer>> addCustomer(Customer customer) async {
    try {
      final response = await _dio.post(
        '/customers/create',
        data: customer.toCreateJson(),
      );

      final json = response.data;
      final meta = json['meta'];
      final isSuccess = meta['status'] == true || meta['success'] == true;

      if (isSuccess) {
        return ApiResponse.success(
          message: meta['message'] ?? 'Customer added successfully',
          data: Customer.fromJson(json['data']),
          code: meta['code'] ?? response.statusCode ?? 200,
        );
      }

      return ApiResponse.error(
        message: meta['message'] ?? 'Failed to add customer',
        code: meta['code'] ?? response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse.error(
        message: 'Unexpected error: ${e.toString()}',
        code: 500,
      );
    }
  }

  // ✅ Update Customer
  Future<ApiResponse<Customer>> updateCustomer(Customer customer) async {
    try {
      final response = await _dio.put(
        '/customers/${customer.id}/update',
        data: customer.toUpdateJson(),
      );

      final json = response.data;
      final meta = json['meta'];
      final isSuccess = meta['status'] == true || meta['success'] == true;

      if (isSuccess) {
        return ApiResponse.success(
          message: meta['message'] ?? 'Customer updated successfully',
          data: Customer.fromJson(json['data']),
          code: meta['code'] ?? response.statusCode ?? 200,
        );
      }

      return ApiResponse.error(
        message: meta['message'] ?? 'Failed to update customer',
        code: meta['code'] ?? response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse.error(
        message: 'Unexpected error: ${e.toString()}',
        code: 500,
      );
    }
  }

  // ✅ Delete Customer
  Future<ApiResponse<void>> deleteCustomer(String id) async {
    try {
      final response = await _dio.delete('/customers/$id/delete');
      final json = response.data;
      final meta = json['meta'];
      final isSuccess = meta['status'] == true || meta['success'] == true;

      if (isSuccess) {
        return ApiResponse.success(
          message: meta['message'] ?? 'Customer deleted successfully',
          code: meta['code'] ?? response.statusCode ?? 200,
        );
      }

      return ApiResponse.error(
        message: meta['message'] ?? 'Failed to delete customer',
        code: meta['code'] ?? response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse.error(
        message: 'Unexpected error: ${e.toString()}',
        code: 500,
      );
    }
  }

  // ✅ Handle Dio Errors
  ApiResponse<T> _handleDioError<T>(DioException e) {
    if (e.response != null) {
      final json = e.response!.data;

      // ✅ Handle struktur { meta: {...}, data: {...} }
      final meta = json['meta'];

      // Handle validation errors (422)
      if (e.response!.statusCode == 422 && json['data'] != null) {
        final errors = json['data'] as Map<String, dynamic>?;
        final errorMessage = errors?.values.first is List
            ? (errors!.values.first as List).first.toString()
            : meta?['message'] ?? 'Validation failed';

        return ApiResponse.error(
          message: errorMessage,
          code: e.response!.statusCode ?? 422,
        );
      }

      return ApiResponse.error(
        message: meta?['message'] ?? e.message ?? 'Server error',
        code: meta?['code'] ?? e.response!.statusCode ?? 500,
      );
    }

    // Network errors
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return ApiResponse.error(
        message: 'Connection timeout. Please check your internet connection.',
        code: 408,
      );
    }

    if (e.type == DioExceptionType.connectionError) {
      return ApiResponse.error(
        message: 'No internet connection. Please check your network.',
        code: 503,
      );
    }

    return ApiResponse.error(
      message: e.message ?? 'Network error occurred',
      code: 500,
    );
  }
}