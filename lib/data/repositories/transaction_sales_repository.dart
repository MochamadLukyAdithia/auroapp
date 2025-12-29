import 'package:dio/dio.dart';

import '../models/api_response.dart';
import '../models/transaction_sales_report_model.dart';
import 'dio.dart';

class TransactionReportRepository {
  final Dio _dio = dio();

  Future<ApiResponse<TransactionReportResponse>> getTransactionReports({
    int? limit,
    int? page,
    String? search,
    String? startDate,
    String? endDate,
  }) async {
    try {
      // Build query parameters
      Map<String, dynamic> queryParams = {};
      if (limit != null) queryParams['limit'] = limit;
      if (page != null) queryParams['page'] = page;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (startDate != null) queryParams['start_date'] = startDate;
      if (endDate != null) queryParams['end_date'] = endDate;

      final response = await _dio.get(
        '/transaction-reports',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final reportResponse = TransactionReportResponse.fromJson(response.data['data']);

        return ApiResponse.success(
          message: response.data['message'] ?? 'Transaction reports retrieved successfully',
          data: reportResponse,
          code: response.statusCode ?? 200,
        );
      }

      return ApiResponse.error(
        message: response.data['message'] ?? 'Failed to get transaction reports',
        code: response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      return ApiResponse.error(
        message: e.response?.data['message'] ?? 'Network error: ${e.message}',
        code: e.response?.statusCode ?? 500,
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'Unexpected error: $e',
        code: 500,
      );
    }
  }

  /// Get Transaction Report Detail by ID
  Future<ApiResponse<TransactionReportDetail>> getTransactionReportDetail(int id) async {
    try {
      final response = await _dio.get('/transaction-reports/detail/$id');

      if (response.statusCode == 200) {
        final detail = TransactionReportDetail.fromJson(response.data['data']);

        return ApiResponse.success(
          message: response.data['message'] ?? 'Detail transaksi berhasil diambil',
          data: detail,
          code: response.statusCode ?? 200,
        );
      }

      return ApiResponse.error(
        message: response.data['message'] ?? 'Failed to get transaction detail',
        code: response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      return ApiResponse.error(
        message: e.response?.data['message'] ?? 'Network error: ${e.message}',
        code: e.response?.statusCode ?? 500,
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'Unexpected error: $e',
        code: 500,
      );
    }
  }


  Future<ApiResponse<TransactionReportResponse>> getCashierTransactionReports({
    int? limit,
    int? page,
    String? search,
    String? startDate,
    String? endDate,
  }) async {
    try {
      // Build query parameters
      Map<String, dynamic> queryParams = {};
      if (limit != null) queryParams['limit'] = limit;
      if (page != null) queryParams['page'] = page;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (startDate != null) queryParams['start_date'] = startDate;
      if (endDate != null) queryParams['end_date'] = endDate;

      final response = await _dio.get(
        '/cashier/transaction-report',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final reportResponse = TransactionReportResponse.fromJson(response.data['data']);

        return ApiResponse.success(
          message: response.data['message'] ?? 'Cashier transaction reports retrieved successfully',
          data: reportResponse,
          code: response.statusCode ?? 200,
        );
      }

      return ApiResponse.error(
        message: response.data['message'] ?? 'Failed to get cashier transaction reports',
        code: response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      return ApiResponse.error(
        message: e.response?.data['message'] ?? 'Network error: ${e.message}',
        code: e.response?.statusCode ?? 500,
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'Unexpected error: $e',
        code: 500,
      );
    }
  }

  /// Get Cashier Transaction Report Detail by ID
  Future<ApiResponse<TransactionReportDetail>> getCashierTransactionReportDetail(int id) async {
    try {
      final response = await _dio.get('/cashier/transaction-report/$id');

      if (response.statusCode == 200) {
        final detail = TransactionReportDetail.fromJson(response.data['data']);

        return ApiResponse.success(
          message: response.data['message'] ?? 'Detail transaksi kasir berhasil diambil',
          data: detail,
          code: response.statusCode ?? 200,
        );
      }

      return ApiResponse.error(
        message: response.data['message'] ?? 'Failed to get cashier transaction detail',
        code: response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      return ApiResponse.error(
        message: e.response?.data['message'] ?? 'Network error: ${e.message}',
        code: e.response?.statusCode ?? 500,
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'Unexpected error: $e',
        code: 500,
      );
    }
  }
}