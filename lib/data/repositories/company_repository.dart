import 'dart:io';
import 'package:dio/dio.dart';
import '../models/api_response.dart';
import '../models/company_model.dart';
import 'dio.dart';

class CompanyRepository {
  final Dio _dio = dio();

  /// Get Company Data dari Profile API
  Future<ApiResponse<Company>> getCompany() async {
    try {
      final response = await _dio.get('/user/profile/');

      if (response.statusCode == 200) {
        final data = response.data['data'];

        // Cek apakah user sudah punya company
        if (data['store_name'] != null &&
            data['store_name'].toString().isNotEmpty) {
          final company = Company.fromJson(data);
          return ApiResponse.success(
            message: 'Company data loaded',
            data: company,
          );
        } else {
          // User belum setup company
          return ApiResponse.success(
            message: 'No company data',
            data: null,
          );
        }
      } else {
        return ApiResponse.error(
          message: response.data['message'] ?? 'Failed to load company',
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

  /// Update Company dengan file upload
  Future<ApiResponse<void>> updateCompany({
    required String name,
    required String address,
    required String phone,
    File? logo,
  }) async {
    try {
      // Siapkan form data
      FormData formData = FormData.fromMap({
        'name': name,
        'address': address,
        'phone': phone,
      });

      // Tambahkan logo jika ada
      if (logo != null) {
        String fileName = logo.path.split('/').last;
        formData.files.add(
          MapEntry(
            'logo',
            await MultipartFile.fromFile(
              logo.path,
              filename: fileName,
            ),
          ),
        );
      }

      // Kirim request
      final response = await _dio.post(
        '/user/profile/update-company',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;

        if (responseData is Map && responseData.containsKey('meta')) {
          final meta = responseData['meta'];
          final isSuccess = meta['status'] == true;
          final message = meta['message'] ?? 'Company updated successfully';

          if (isSuccess) {
            return ApiResponse.success(message: message);
          } else {
            return ApiResponse.error(
              message: message,
              code: meta['code'] ?? 500,
            );
          }
        }

        if (responseData is Map && responseData.containsKey('success')) {
          final isSuccess = responseData['success'] == true;
          final message = responseData['message'] ?? 'Company updated successfully';

          if (isSuccess) {
            return ApiResponse.success(message: message);
          } else {
            return ApiResponse.error(
              message: message,
              code: response.statusCode ?? 500,
            );
          }
        }


        return ApiResponse.success(message: 'Company updated successfully');
      } else {

        return ApiResponse.error(
          message: response.data?['message'] ?? 'Failed to update company',
          code: response.statusCode ?? 500,
        );
      }
    } on DioException catch (e) {

      String errorMessage = 'Network error';

      if (e.response?.data is Map) {
        final data = e.response!.data;


        if (data.containsKey('meta')) {
          errorMessage = data['meta']['message'] ?? errorMessage;
        }

        else if (data.containsKey('message')) {
          errorMessage = data['message'] ?? errorMessage;
        }
      }

      return ApiResponse.error(
        message: errorMessage,
        code: e.response?.statusCode ?? 500,
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'Unexpected error: ${e.toString()}',
      );
    }
  }
}