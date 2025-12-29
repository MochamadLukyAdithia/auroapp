import 'package:dio/dio.dart';
import '../models/api_response.dart';
import 'dio.dart';

class OutcomeRepository {
  final Dio _dio = dio();

  /// Get outcome reports with optional filters
  ///
  /// Parameters:
  /// - [limit]: Number of items per page (default: 10)
  /// - [page]: Page number (default: 1)
  /// - [month]: Filter by month (1-12)
  /// - [year]: Filter by year (e.g., 2024)
  Future<ApiResponse<Map<String, dynamic>>> getOutcomeReport({
    int limit = 10,
    int page = 1,
    int? month,
    int? year,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'limit': limit,
        'page': page,
      };

      if (month != null) {
        queryParams['month'] = month;
      }

      if (year != null) {
        queryParams['year'] = year;
      }

      final response = await _dio.get(
        '/outcome-reports',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return ApiResponse.success(
          message: response.data['message'] ?? 'Outcome report retrieved successfully',
          data: response.data['data'],
          code: response.statusCode ?? 200,
        );
      } else {
        return ApiResponse.error(
          message: response.data['message'] ?? 'Failed to retrieve outcome report',
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