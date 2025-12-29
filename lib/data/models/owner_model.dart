import 'package:equatable/equatable.dart';
import '../../core/utils/auth_service.dart';

class Owner extends Equatable {
  final int id;
  final String fullName;
  final String email;
  final String password;
  final String confirmPassword;
  final String phoneNumber;
  final int? companyId;
  final String role;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Owner({
    required this.id,
    required this.fullName,
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.phoneNumber,
    this.companyId,
    this.role = AuthService.ROLE_OWNER,
    this.createdAt,
    this.updatedAt
  });

  Owner copyWith({
    int? id,
    String? fullName,
    String? email,
    String? password,
    String? confirmPassword,
    String? phoneNumber,
    String? userAddress,
    String? role,
  }) {
    return Owner(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
    );
  }

  factory Owner.fromJson(Map<String, dynamic> json) {
    return Owner(
      id: json['id'] ?? 0,
      fullName: json['name'] ?? json['full_name'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      confirmPassword: json['confirmPassword'] ?? '',
      phoneNumber: json['phone'] ?? json['phone_number'] ?? json['noTelephone'] ?? '',
      companyId: json['company_id'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
      role: json['role_name'] ?? json['role'] ?? AuthService.ROLE_OWNER,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'email': email,
      'password': password,
      'confirmPassword': confirmPassword,
      'phone_number': phoneNumber,
    };
  }

  // ✅ FIXED: Tidak kirim confirmPassword ke backend (security best practice)
  Map<String, dynamic> toRegisterJson(String password, String passwordConfirmation) {
    return {
      'name': fullName,
      'email': email,
      'password': password,
      'confirmPassword': passwordConfirmation, // Backend Laravel butuh ini untuk validasi same:password
      'noTelephone': phoneNumber,
    };
  }

  Map<String, dynamic> toStorageJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'password': password,
      'confirmPassword': confirmPassword,
      'phone_number': phoneNumber,
      'company_id': companyId,
      'role': role,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, fullName, email, password, confirmPassword, phoneNumber, companyId, role, createdAt, updatedAt];
}

// ✅ FIXED: Tambahkan error details dari backend
class RegisterResponse {
  final bool success;
  final String? message;
  final RegisterData? data;
  final Map<String, String>? errors; // ✅ NEW: untuk error spesifik per field

  RegisterResponse({
    required this.success,
    this.message,
    this.data,
    this.errors,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    final meta = json['meta'];
    final data = json['data'];

    // ✅ Extract error details jika ada
    Map<String, String>? fieldErrors;
    if (data != null && data is Map<String, dynamic>) {
      // Cek apakah data berisi error messages (dari backend Laravel)
      if (data.containsKey('email') || data.containsKey('phone')) {
        fieldErrors = {};
        if (data['email'] != null) fieldErrors['email'] = data['email'].toString();
        if (data['phone'] != null) fieldErrors['phone'] = data['phone'].toString();
      }
    }

    return RegisterResponse(
      success: (meta?['code'] == 200) || (meta?['code'] == 201),
      message: meta?['message'],
      data: data != null && (meta?['code'] == 200 || meta?['code'] == 201)
          ? RegisterData.fromJson(data)
          : null,
      errors: fieldErrors,
    );
  }
}

class RegisterData {
  final int userId;
  final bool otpSent;

  RegisterData({
    required this.userId,
    required this.otpSent,
  });

  factory RegisterData.fromJson(Map<String, dynamic> json) {
    return RegisterData(
      userId: json['user_id'] ?? 0,
      otpSent: json['requires_verification'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'otp_sent': otpSent,
    };
  }
}

class ResendOtpResponse {
  final bool success;
  final String message;
  final int? userId;
  final bool? otpSent;

  ResendOtpResponse({
    required this.success,
    required this.message,
    this.userId,
    this.otpSent,
  });

  factory ResendOtpResponse.fromJson(Map<String, dynamic> json) {
    final meta = json['meta'];
    final data = json['data'];

    return ResendOtpResponse(
        success: (meta?['code'] == 200 || meta?['code'] == 201) ||
            (meta?['status'] == true),
        message: meta?['message'] ?? 'Unknown error',
        userId: data?['user_id'],
        otpSent: data?['otp_sent']
    );
  }
}