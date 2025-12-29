// repositories/customer_repository.dart
import 'package:dio/dio.dart';
import '../models/api_response.dart';
import '../models/customer_model.dart';
import 'dio.dart';

class CustomerRepository {
  final Dio _dio = dio();

  // ✅ Get All Customers (pagination & search)
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

      if (response.statusCode == 200) {
        final meta = json['meta'];
        final data = json['data'];

        final isSuccess = meta['status'] == true || meta['success'] == true;

        if (isSuccess) {
          final customerList = data['data'] as List;
          final customers =
          customerList.map((item) => Customer.fromJson(item)).toList();

          return ApiResponse.success(
            message: meta['message'] ?? 'Data pelanggan berhasil ditampilkan',
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
        message: json['meta']?['message'] ?? 'Gagal menampilkan data pelanggan',
        code: json['meta']?['code'] ?? response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse.error(
        message: 'Terjadi kesalahan tidak diketahui',
        code: 500,
      );
    }
  }

  // ✅ Get Customer By ID
  Future<ApiResponse<Customer>> getCustomer(int id) async {
    try {
      final response = await _dio.get('/customers/$id');
      final json = response.data;

      if (response.statusCode == 200) {
        final meta = json['meta'];
        final isSuccess = meta['status'] == true || meta['success'] == true;

        if (isSuccess) {
          return ApiResponse.success(
            message: meta['message'] ?? 'Data pelanggan berhasil ditampilkan',
            data: Customer.fromJson(json['data']),
            code: meta['code'] ?? response.statusCode ?? 200,
          );
        }
      }

      return ApiResponse.error(
        message: json['meta']?['message'] ??
            'Pelanggan tidak dapat ditemukan atau sudah dihapus',
        code: json['meta']?['code'] ?? response.statusCode ?? 404,
      );
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse.error(
        message: 'Terjadi kesalahan tidak diketahui',
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
          message: meta['message'] ?? 'Pelanggan berhasil ditambahkan',
          data: Customer.fromJson(json['data']),
          code: meta['code'] ?? response.statusCode ?? 200,
        );
      }

      return ApiResponse.error(
        message: meta['message'] ?? 'Gagal menambahkan pelanggan',
        code: meta['code'] ?? response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse.error(
        message: 'Terjadi kesalahan tidak diketahui',
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
          message: meta['message'] ?? 'Data pelanggan berhasil diperbarui',
          data: Customer.fromJson(json['data']),
          code: meta['code'] ?? response.statusCode ?? 200,
        );
      }

      return ApiResponse.error(
        message: meta['message'] ?? 'Gagal memperbarui data pelanggan',
        code: meta['code'] ?? response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse.error(
        message: 'Terjadi kesalahan tidak diketahui',
        code: 500,
      );
    }
  }

  // ✅ Delete Customer
  Future<ApiResponse<void>> deleteCustomer(int id) async {
    try {
      final response = await _dio.delete('/customers/$id/delete');
      final json = response.data;
      final meta = json['meta'];
      final isSuccess = meta['status'] == true || meta['success'] == true;

      if (isSuccess) {
        return ApiResponse.success(
          message: meta['message'] ?? 'Pelanggan berhasil dihapus',
          code: meta['code'] ?? response.statusCode ?? 200,
        );
      }

      return ApiResponse.error(
        message: meta['message'] ?? 'Gagal menghapus pelanggan',
        code: meta['code'] ?? response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse.error(
        message: 'Terjadi kesalahan tidak diketahui',
        code: 500,
      );
    }
  }

  // ✅ Handle Dio Errors (Bahasa Indonesia)
  ApiResponse<T> _handleDioError<T>(DioException e) {
    if (e.response != null) {
      final json = e.response!.data;
      final meta = json['meta'];

      // Error validasi (422)
      if (e.response!.statusCode == 422 && json['data'] != null) {
        final errors = json['data'] as Map<String, dynamic>?;
        final errorMessage = errors?.values.first is List
            ? (errors!.values.first as List).first.toString()
            : meta?['message'] ?? 'Data tidak valid';

        return ApiResponse.error(
          message: errorMessage,
          code: e.response!.statusCode ?? 422,
        );
      }

      return ApiResponse.error(
        message: meta?['message'] ?? e.message ?? 'Terjadi kesalahan pada server',
        code: meta?['code'] ?? e.response!.statusCode ?? 500,
      );
    }

    // Timeout koneksi
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return ApiResponse.error(
        message: 'Koneksi timeout. Periksa koneksi internet Anda.',
        code: 408,
      );
    }

    // Tidak ada internet
    if (e.type == DioExceptionType.connectionError) {
      return ApiResponse.error(
        message: 'Tidak ada koneksi internet. Periksa jaringan Anda.',
        code: 503,
      );
    }

    return ApiResponse.error(
      message: e.message ?? 'Terjadi kesalahan jaringan',
      code: 500,
    );
  }
}
