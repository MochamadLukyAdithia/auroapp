import 'package:dio/dio.dart';
import '../models/api_response.dart';
import '../models/finance_model.dart';
import 'dio.dart';

class FinanceRepository {
  final Dio _dio = dio();

  // ✅ Get Financials (dengan parsing ke List<Finance>)
  Future<ApiResponse<List<Finance>>> getFinancials({
    int limit = 10,
    int page = 1,
  }) async {
    try {
      final response = await _dio.get(
        '/financials',
        queryParameters: {
          'limit': limit,
          'page': page,
        },
      );

      if (response.statusCode == 200) {
        // ✅ Parse data dari Laravel pagination
        final data = response.data['data'];
        final List<Finance> finances = [];

        if (data['data'] != null && data['data'] is List) {
          finances.addAll(
            (data['data'] as List)
                .map((json) => Finance.fromJson(json))
                .toList(),
          );
        }

        return ApiResponse.success(
          message: response.data['message'] ?? 'Financials retrieved successfully',
          data: finances,
          code: response.statusCode ?? 200,
        );
      }

      return ApiResponse.error(
        message: response.data['message'] ?? 'Failed to get financials',
        code: response.statusCode ?? 500,
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

  // ✅ Create Finance (langsung terima object Finance)
  Future<ApiResponse<Finance>> createFinance(Finance finance) async {
    try {
      final response = await _dio.post(
        '/financials/create',
        data: {
          'financials_type': finance.type.value,
          'financials_date': Finance.formatDate(finance.date),
          'financials_name': finance.name,
          'nominal': finance.amount,
          if (finance.description != null)
            'financials_description': finance.description,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final createdFinance = Finance.fromJson(response.data['data']);

        return ApiResponse.success(
          message: response.data['message'] ?? 'Data financial berhasil ditambahkan',
          data: createdFinance,
          code: response.statusCode ?? 201,
        );
      }

      return ApiResponse.error(
        message: response.data['message'] ?? 'Failed to create finance',
        code: response.statusCode ?? 500,
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

  // ✅ Delete Finance
  Future<ApiResponse<void>> deleteFinance(int id) async {
    try {
      final response = await _dio.delete('/financials/$id/delete');

      if (response.statusCode == 200) {
        return ApiResponse.success(
          message: response.data['message'] ?? 'Keuangan berhasil dihapus',
          code: response.statusCode ?? 200,
        );
      }

      return ApiResponse.error(
        message: response.data['message'] ?? 'Failed to delete finance',
        code: response.statusCode ?? 500,
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

  // ✅ Error Handler
  ApiResponse<T> _handleDioError<T>(DioException error) {
    String message;
    int code;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = 'Connection timeout';
        code = 408;
        break;

      case DioExceptionType.badResponse:
        final response = error.response;
        message = response?.data['message'] ?? 'Server error';
        code = response?.statusCode ?? 500;
        break;

      case DioExceptionType.cancel:
        message = 'Request cancelled';
        code = 499;
        break;

      case DioExceptionType.connectionError:
        message = 'No internet connection';
        code = 503;
        break;

      default:
        message = 'Something went wrong';
        code = 500;
    }

    return ApiResponse.error(message: message, code: code);
  }
}