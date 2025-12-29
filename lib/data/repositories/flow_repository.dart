import 'package:dio/dio.dart';
import '../models/api_response.dart';
import 'dio.dart';

class CashFlowRepository {
  final Dio _dio = dio();

  /// Get cash flow reports with optional filters
  ///
  /// Parameters:
  /// - [month]: Filter by month (1-12)
  /// - [year]: Filter by year (e.g., 2024)
  /// - [type]: Filter by type (income/outcome)
  Future<ApiResponse<Map<String, dynamic>>> getCashFlowReport({
    int? month,
    int? year,
    String? type,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};

      if (month != null) {
        queryParams['month'] = month;
      }

      if (year != null) {
        queryParams['year'] = year;
      }

      if (type != null) {
        queryParams['type'] = type;
      }

      final response = await _dio.get(
        '/cashflow-reports',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.statusCode == 200 && response.data['meta']['status'] == true) {
        return ApiResponse.success(
          message: response.data['meta']['message'] ?? 'Cash flow report retrieved successfully',
          data: response.data['data'],
          code: response.statusCode ?? 200,
        );
      } else {
        return ApiResponse.error(
          message: response.data['message'] ?? 'Failed to retrieve cash flow report',
          code: response.statusCode ?? 500,
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        return ApiResponse.error(
          message: e.response?.data['message'] ?? 'Server error occurred',
          code: e.response?.statusCode ?? 500,
        );
      } else {
        return ApiResponse.error(
          message: e.message ?? 'Network error occurred',
          code: 500,
        );
      }
    } catch (e) {
      return ApiResponse.error(
        message: 'Unexpected error: ${e.toString()}',
        code: 500,
      );
    }
  }

  /// Get financial detail by ID
  Future<ApiResponse<Map<String, dynamic>>> getFinancialById(int id) async {
    try {
      final response = await _dio.get('/cashflow-reports/financial/detail/$id');

      if (response.statusCode == 200 && response.data['meta']['status'] == true) {
        return ApiResponse.success(
          message: response.data['meta']['message'] ?? 'Cash flow Financial detail report retrieved successfully',
          data: response.data['data'],
          code: response.statusCode ?? 200,
        );
      } else {
        return ApiResponse.error(
          message: response.data['message'] ?? 'Failed to retrieve financial detail',
          code: response.statusCode ?? 500,
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        return ApiResponse.error(
          message: e.response?.data['message'] ?? 'Server error occurred',
          code: e.response?.statusCode ?? 500,
        );
      } else {
        return ApiResponse.error(
          message: e.message ?? 'Network error occurred',
          code: 500,
        );
      }
    } catch (e) {
      return ApiResponse.error(
        message: 'Unexpected error: ${e.toString()}',
        code: 500,
      );
    }
  }
}