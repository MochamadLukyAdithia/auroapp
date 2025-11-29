import 'package:dio/dio.dart';
import '../models/api_response.dart';
import '../models/transaction_model.dart';
import 'dio.dart';

class TransactionRepository {
  final Dio _dio = dio();

  // ✅ Create Transaction (POST)
  Future<ApiResponse<TransactionModel>> createTransaction({
    required DateTime transactionDate,
    required int subtotal,
    required int transactionDiscount,
    required int transactionTax,
    required int totalTransaction,
    String? nameOtherCost,
    required int otherCost,
    required int totalPayment,
    required int changeAmount,
    String? transactionDescription,
    required int totalProfit,
    int? customerId,
    required int companyPaymentMethodId,
    required List<Map<String, dynamic>> details,
  }) async {
    try {
      final response = await _dio.post(
        '/transactions',
        data: {
          'transaction_date': transactionDate.toIso8601String(),
          'subtotal': subtotal,
          'transaction_discount': transactionDiscount,
          'transaction_tax': transactionTax,
          'total_transaction': totalTransaction,
          'name_other_cost': nameOtherCost,
          'other_cost': otherCost,
          'total_payment': totalPayment,
          'change_amount': changeAmount,
          'transaction_description': transactionDescription,
          'total_profit': totalProfit,
          'customer_id': customerId,
          'company_payment_method_id': companyPaymentMethodId,
          'details': details,
        },
      );

      if (response.data['meta']['status'] == true) {
        final transaction = TransactionModel.fromJson(response.data['data']);
        return ApiResponse.success(
          message: response.data['meta']['message'],
          data: transaction,
          code: response.data['meta']['code'],
        );
      } else {
        return ApiResponse.error(
          message: response.data['meta']['message'],
          code: response.data['meta']['code'],
        );
      }
    } on DioException catch (e) {
      return ApiResponse.error(
        message: e.response?.data['meta']['message'] ?? 'Failed to create transaction',
        code: e.response?.statusCode ?? 500,
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'Unexpected error: ${e.toString()}',
      );
    }
  }

  // ✅ Get All Transactions (GET with filters)
  Future<ApiResponse<List<TransactionModel>>> getTransactions({
    String? startDate,
    String? endDate,
    int? customerId,
    int? paymentMethodId,
    String? search,
    String sortBy = 'transaction_date',
    String sortOrder = 'desc',
    int perPage = 15,
    int page = 1,
  }) async {
    try {
      final response = await _dio.get(
        '/transactions',
        queryParameters: {
          if (startDate != null) 'start_date': startDate,
          if (endDate != null) 'end_date': endDate,
          if (customerId != null) 'customer_id': customerId,
          if (paymentMethodId != null) 'payment_method_id': paymentMethodId,
          if (search != null) 'search': search,
          'sort_by': sortBy,
          'sort_order': sortOrder,
          'per_page': perPage,
          'page': page,
        },
      );

      if (response.data['meta']['status'] == true) {
        final transactions = (response.data['data']['data'] as List)
            .map((json) => TransactionModel.fromJson(json))
            .toList();

        return ApiResponse.success(
          message: response.data['meta']['message'],
          data: transactions,
          code: response.data['meta']['code'],
        );
      } else {
        return ApiResponse.error(
          message: response.data['meta']['message'],
          code: response.data['meta']['code'],
        );
      }
    } on DioException catch (e) {
      return ApiResponse.error(
        message: e.response?.data['meta']['message'] ?? 'Failed to fetch transactions',
        code: e.response?.statusCode ?? 500,
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'Unexpected error: ${e.toString()}',
      );
    }
  }

  // ✅ Get Transaction Detail by ID (GET)
  Future<ApiResponse<TransactionModel>> getTransactionById(int id) async {
    try {
      final response = await _dio.get('/transactions/$id');

      if (response.data['meta']['status'] == true) {
        final transaction = TransactionModel.fromJson(response.data['data']);
        return ApiResponse.success(
          message: response.data['meta']['message'],
          data: transaction,
          code: response.data['meta']['code'],
        );
      } else {
        return ApiResponse.error(
          message: response.data['meta']['message'],
          code: response.data['meta']['code'],
        );
      }
    } on DioException catch (e) {
      return ApiResponse.error(
        message: e.response?.data['meta']['message'] ?? 'Failed to fetch transaction detail',
        code: e.response?.statusCode ?? 500,
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'Unexpected error: ${e.toString()}',
      );
    }
  }

  // ✅ Get Transaction Summary (GET)
  Future<ApiResponse<Map<String, dynamic>>> getTransactionSummary({
    String? startDate,
    String? endDate,
  }) async {
    try {
      final response = await _dio.get(
        '/transactions/summary',
        queryParameters: {
          if (startDate != null) 'start_date': startDate,
          if (endDate != null) 'end_date': endDate,
        },
      );

      if (response.data['meta']['status'] == true) {
        return ApiResponse.success(
          message: response.data['meta']['message'],
          data: response.data['data'],
          code: response.data['meta']['code'],
        );
      } else {
        return ApiResponse.error(
          message: response.data['meta']['message'],
          code: response.data['meta']['code'],
        );
      }
    } on DioException catch (e) {
      return ApiResponse.error(
        message: e.response?.data['meta']['message'] ?? 'Failed to fetch summary',
        code: e.response?.statusCode ?? 500,
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'Unexpected error: ${e.toString()}',
      );
    }
  }
}