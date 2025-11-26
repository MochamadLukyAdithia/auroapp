import 'package:dio/dio.dart';
import '../models/api_response.dart';
import '../models/owner_model.dart';
import 'dio.dart';


class ProfileRepository {
  final Dio _dio = dio();

  // Get user profile
  Future<ApiResponse<Owner>> getProfile() async {
    try {
      final response = await _dio.get('/user/profile');

      if (response.statusCode == 200) {
        final data = response.data;

        // Parsing response sesuai struktur API Laravel
        if (data['success'] == true) {
          final owner = Owner.fromJson(data['data']);

          return ApiResponse.success(
            message: data['message'] ?? 'Profil berhasil dimuat',
            data: owner,
            code: response.statusCode ?? 200,
          );
        } else {
          return ApiResponse.error(
            message: data['message'] ?? 'Gagal memuat profil',
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

  // Update user profile
  Future<ApiResponse<Owner>> updateProfile({
    required String fullName,
    required String phoneNumber,
    required String userAddress,
    String? email,
  }) async {
    try {
      final response = await _dio.post(
        '/user/profile/update-profile',
        data: {
          'name': fullName,
          'noTelephone': phoneNumber,
          'address': userAddress,
          if (email != null) 'email': email,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['success'] == true) {
          final owner = Owner.fromJson(data['data']);

          return ApiResponse.success(
            message: data['message'] ?? 'Profil berhasil diperbarui',
            data: owner,
            code: response.statusCode ?? 200,
          );
        } else {
          return ApiResponse.error(
            message: data['message'] ?? 'Gagal memperbarui profil',
            code: response.statusCode ?? 500,
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

  // Update profile dengan FormData (untuk upload foto)
  Future<ApiResponse<Owner>> updateProfileWithPhoto({
    required String name,
    required String phone,
    required String address,
    String? email,
    String? photoPath,
  }) async {
    try {
      final formData = FormData.fromMap({
        'name': name,
        'phone': phone,
        'address': address,
        if (email != null) 'email': email,
        if (photoPath != null)
          'photo': await MultipartFile.fromFile(
            photoPath,
            filename: photoPath.split('/').last,
          ),
      });

      final response = await _dio.post(
        '/user/profile/update-profile',
        data: formData,
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['success'] == true) {
          final owner = Owner.fromJson(data['data']);

          return ApiResponse.success(
            message: data['message'] ?? 'Profil berhasil diperbarui',
            data: owner,
            code: response.statusCode ?? 200,
          );
        } else {
          return ApiResponse.error(
            message: data['message'] ?? 'Gagal memperbarui profil',
            code: response.statusCode ?? 500,
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

  // Handle Dio errors
  ApiResponse<Owner> _handleDioError(DioException e) {
    String message = 'Terjadi kesalahan';
    int code = 500;

    if (e.response != null) {
      code = e.response!.statusCode ?? 500;

      // Parse error message dari response
      if (e.response!.data is Map) {
        message = e.response!.data['message'] ??
            e.response!.data['error'] ??
            'Terjadi kesalahan';
      } else {
        message = e.response!.statusMessage ?? 'Terjadi kesalahan';
      }
    } else {
      // Handle connection errors
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
          message = 'Koneksi timeout';
          break;
        case DioExceptionType.sendTimeout:
          message = 'Timeout saat mengirim data';
          break;
        case DioExceptionType.receiveTimeout:
          message = 'Timeout saat menerima data';
          break;
        case DioExceptionType.connectionError:
          message = 'Tidak ada koneksi internet';
          break;
        case DioExceptionType.cancel:
          message = 'Request dibatalkan';
          break;
        default:
          message = e.message ?? 'Terjadi kesalahan';
      }
    }

    return ApiResponse.error(message: message, code: code);
  }
}