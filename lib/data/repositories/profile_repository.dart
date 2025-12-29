import 'package:dio/dio.dart';
import '../models/api_response.dart';
import '../models/owner_model.dart';
import 'dio.dart';


class ProfileRepository {
  final Dio _dio = dio();

  Future<ApiResponse<Owner>> getProfile() async {
    try {
      final response = await _dio.get('/user/profile');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['success'] == true && data['data'] != null) {
          final owner = Owner.fromJson(data['data']);
          return ApiResponse.success(
            message: 'Profil berhasil dimuat',
            data: owner,
            code: response.statusCode ?? 200,
          );
        } else {
          return ApiResponse.error(
            message: 'Gagal memuat profil - data kosong',
            code: response.statusCode ?? 500,
          );
        }
      }

      return ApiResponse.error(
        message: 'Gagal memuat profil',
        code: response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse.error(
        message: 'Terjadi kesalahan: ${e.toString()}',
        code: 500,
      );
    }
  }

  Future<ApiResponse<Owner>> updateProfile({
    required String fullName,
    required String phoneNumber,
  }) async {
    try {
      final response = await _dio.post(
        '/user/profile/update-profile',
        data: {
          'full_name': fullName,
          'phone_number': phoneNumber,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;

        // ✅ Backend pakai structure "meta" dan "data"
        if (data['meta']?['status'] == true) { // UBAH dari data['success']
          return ApiResponse.success(
            message: data['meta']['message'] ?? 'Profil berhasil diperbarui',
            data: null,
            code: response.statusCode ?? 200,
          );
        } else {
          return ApiResponse.error(
            message: data['meta']?['message'] ?? 'Gagal memperbarui profil',
            code: data['meta']?['code'] ?? 500,
          );
        }
      }

      return ApiResponse.error(
        message: 'Gagal memperbarui profil',
        code: response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse.error(
        message: 'Terjadi kesalahan: ${e.toString()}',
        code: 500,
      );
    }
  }

  Future<ApiResponse<void>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await _dio.post(
        '/user/profile/update-profile',
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['meta']?['status'] == true) {
          return ApiResponse.success(
            message: data['meta']['message'] ?? 'Password berhasil diubah',
            data: null,
            code: response.statusCode ?? 200,
          );
        } else {
          // Handle specific error messages from backend
          final errorMessage = data['meta']?['message'] ?? 'Gagal mengubah password';

          return ApiResponse.error(
            message: errorMessage,
            code: data['meta']?['code'] ?? 400,
          );
        }
      }

      return ApiResponse.error(
        message: 'Gagal mengubah password',
        code: response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

// Handler untuk DioException
  ApiResponse<T> _handleDioError<T>(DioException e) {
    String errorMessage = 'Terjadi kesalahan';
    int errorCode = 500;

    if (e.response != null) {
      errorCode = e.response!.statusCode ?? 500;

      // Parse error message dari response
      final data = e.response!.data;
      if (data is Map<String, dynamic>) {
        errorMessage = data['meta']?['message'] ??
            data['message'] ??
            'Gagal mengubah password';
      }
    } else {
      // Network errors
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
          errorMessage = 'Koneksi timeout, periksa jaringan Anda';
          break;
        case DioExceptionType.sendTimeout:
          errorMessage = 'Pengiriman data timeout';
          break;
        case DioExceptionType.receiveTimeout:
          errorMessage = 'Penerimaan data timeout';
          break;
        case DioExceptionType.connectionError:
          errorMessage = 'Tidak dapat terhubung ke server';
          break;
        case DioExceptionType.badResponse:
          errorMessage = 'Response server tidak valid';
          break;
        case DioExceptionType.cancel:
          errorMessage = 'Request dibatalkan';
          break;
        default:
          errorMessage = 'Terjadi kesalahan: ${e.message}';
      }
    }

    return ApiResponse.error(
      message: errorMessage,
      code: errorCode,
    );
  }
}