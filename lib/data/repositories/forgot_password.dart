// lib/repositories/forget_password_repository.dart
import 'package:dio/dio.dart';

import '../models/api_response.dart';
import '../models/forgot_password_model.dart';
import 'dio.dart';


class ForgetPasswordRepository {
  final Dio _dio = dio();

  Future<ApiResponse<ForgetPasswordResponse>> sendResetPasswordEmail(
      ForgetPasswordRequest request,
      ) async {
    try {
      final response = await _dio.post(
        '/forget-password/email',
        data: request.toJson(),
      );

      // Parse response data
      final responseData = ForgetPasswordResponse.fromJson(
        response.data['data'] ?? {},
      );

      return ApiResponse.success(
        message: response.data['message'] ?? 'Email berhasil dikirim',
        data: responseData,
        code: response.statusCode ?? 200,
      );
    } on DioException catch (e) {
      // Handle DioException
      if (e.response != null) {
        final errorMessage = e.response?.data['message'] ??
            e.response?.data['error'] ??
            'Terjadi kesalahan';

        return ApiResponse.error(
          message: errorMessage,
          code: e.response?.statusCode ?? 500,
        );
      } else {
        // Network error atau timeout
        return ApiResponse.error(
          message: 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
          code: 503,
        );
      }
    } catch (e) {
      // Handle unexpected errors
      return ApiResponse.error(
        message: 'Terjadi kesalahan: ${e.toString()}',
        code: 500,
      );
    }
  }
}