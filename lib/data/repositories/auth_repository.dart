import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/change_password_model.dart';
import '../models/login_model.dart';
import '../models/owner_model.dart';
import '../models/verification_model.dart' hide ResendOtpResponse;
import 'dio.dart';


class AuthRepository {
  final Dio _dio = dio();

  // Login
  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await _dio.post(
        '/login',
        data: request.toJson(),
      );
      final loginResponse = LoginResponse.fromJson(response.data);
      if (loginResponse.success &&
          loginResponse.data != null &&
          loginResponse.data!.isFullLogin) {
        await _saveToken(loginResponse.data!.accessToken!);
        await _saveUserData(loginResponse.data!);
      }

      return loginResponse;

    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw Exception('Network error: Tidak dapat terhubung ke server');
      }

      if (e.response != null) {
        final loginResponse = LoginResponse.fromJson(e.response!.data);

        return loginResponse;
      }

      throw Exception('Network error: ${e.message}');

    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<VerifyOtpResponse> verifyOtp({
    required int userId,
    required String otpCode,
  }) async {
    try {
      final response = await _dio.post(
        '/verify-otp',
        data: {
          'user_id': userId,
          'otp_code': otpCode,
        },
      );
      return VerifyOtpResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        return VerifyOtpResponse.fromJson(e.response!.data);
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  Future<ResendOtpResponse> resendOtpFromRegister(int userId) async {
    try {
      final response = await _dio.post(
        '/resend-otp',
        data: {'user_id': userId},
      );
      return ResendOtpResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        return ResendOtpResponse.fromJson(e.response!.data);
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  Future<ResendOtpResponse> resendOtp({required String email}) async {
    try {
      final response = await _dio.post(
        '/resend-otp',
        data: {'email': email},
      );

      return ResendOtpResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.data != null) {
        return ResendOtpResponse.fromJson(e.response!.data);
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  Future<RegisterResponse> registerOwner(Map<String, dynamic> request) async {
    try {
      final response = await _dio.post(
        '/register-owner',
        data: request,
      );

      return RegisterResponse.fromJson(response.data);
    } on DioException catch (e) {

      if (e.response != null) {
        return RegisterResponse.fromJson(e.response!.data);
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  Future<void> logout() async {
    try {
      final token = await getToken();
      if (token != null) {
        await _dio.post(
          '/logout',
          options: Options(
            headers: {'Authorization': 'Bearer $token'},
          ),
        );
      }
      await _clearSession();
    } catch (e) {
      await _clearSession();
      throw Exception('Logout error: $e');
    }
  }

  // Change Password
  Future<ChangePasswordResponse> changePassword(ChangePasswordRequest request) async {
    try {
      final token = await getToken();

      final response = await _dio.post(
        '/change-password',
        data: request.toJson(),
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      return ChangePasswordResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        return ChangePasswordResponse.fromJson(e.response!.data);
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  // Helper methods untuk token management
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  Future<void> _saveUserData(LoginData data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_role', data.role!);
    await prefs.setString('user_email', data.user!.email);
    await prefs.setString('user_name', data.user!.fullName);
    await prefs.setBool('is_logged_in', true);
  }

  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('user_role');
    await prefs.remove('user_email');
    await prefs.remove('user_name');
    await prefs.remove('user_id');
    await prefs.remove('user_data');
    await prefs.remove('auth_token');
    await prefs.setBool('is_logged_in', false);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_logged_in') ?? false;
  }
}