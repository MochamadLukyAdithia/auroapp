import 'package:dio/dio.dart';
import '../models/api_response.dart';
import '../models/payment_method_model.dart';
import 'dio.dart';

class PaymentMethodRepository {
  final Dio _dio = dio();

  //  Get Payment Methods (Grouped by type)
  Future<ApiResponse<PaymentMethodsGrouped>> getPaymentMethods() async {
    try {
      final response = await _dio.get('/payment-methods');

      if (response.statusCode == 200) {
        final meta = response.data['meta'];
        final data = response.data['data'];

        // ✅ Check meta status
        if (meta['status'] == true && data is Map<String, dynamic>) {
          final grouped = PaymentMethodsGrouped.fromJson(data);

          return ApiResponse.success(
            message: meta['message'] ?? 'Payment methods loaded successfully',
            data: grouped,
          );
        } else {
          return ApiResponse.error(
            message: meta['message'] ?? 'Failed to load payment methods',
            code: meta['code'] ?? 500,
          );
        }
      } else {
        return ApiResponse.error(
          message: response.data['message'] ?? 'Failed to load payment methods',
          code: response.statusCode ?? 500,
        );
      }
    } on DioException catch (e) {
      return ApiResponse.error(
        message: e.response?.data['message'] ?? 'Network error',
        code: e.response?.statusCode ?? 500,
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'Unexpected error: ${e.toString()}',
      );
    }
  }


  /// Update Payment Method Status (Toggle enabled/disabled)
  Future<ApiResponse<void>> updatePaymentMethodStatus({
    required int paymentMethodId,
    required bool isEnabled,
  }) async {
    try {
      // ✅ Kirim sebagai STRING untuk ENUM!
      final payload = {
        'status_payment_methods': isEnabled ? '1' : '0', // ✅ String, bukan integer!
      };

      print('📤 PUT /payment-methods/$paymentMethodId/update');
      print('📦 Payload: $payload');

      final response = await _dio.put(
        '/payment-methods/$paymentMethodId/update',
        data: payload,
      );

      print('📥 Response: ${response.data}');

      if (response.data['meta']['status'] == true) {
        return ApiResponse(
          success: true,
          message: response.data['meta']['message'] ?? 'Status updated',
        );
      } else {
        return ApiResponse(
          success: false,
          message: response.data['meta']['message'] ?? 'Update failed',
        );
      }
    } on DioException catch (e) {
      print('❌ PUT Error: ${e.response?.data}');
      return ApiResponse(
        success: false,
        message: e.response?.data['meta']['message'] ?? 'Network error',
      );
    } catch (e) {
      print('❌ Unexpected Error: $e');
      return ApiResponse(
        success: false,
        message: 'Unexpected error: ${e.toString()}',
      );
    }
  }
}