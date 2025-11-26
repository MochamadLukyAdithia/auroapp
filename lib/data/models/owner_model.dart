import 'package:equatable/equatable.dart';

import '../../core/utils/auth_service.dart';

class Owner extends Equatable {
  final int id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String userAddress;
  final int? companyId;
  final String role;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Owner({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.userAddress,
    this.companyId,
    this.role = AuthService.ROLE_OWNER,
    this.createdAt,
    this.updatedAt
  });

  Owner copyWith({
    int? id,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? userAddress,
    String? role,
  }) {
    return Owner(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      userAddress: userAddress ?? this.userAddress,
      role: role ?? this.role,
    );
  }

  // FromJson untuk data dari API (response)
  factory Owner.fromJson(Map<String, dynamic> json) {
    return Owner(
      id: json['id'] ?? 0,
      fullName: json['name'] ?? json['full_name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phone'] ?? json['phone_number'] ?? json['noTelephone'] ?? '',
      userAddress: json['address'] ?? json['user_address'] ?? json['store_address'] ?? '',
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

  // ToJson untuk kirim data ke API (request register)
  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
      'user_address': userAddress,
    };
  }

  Map<String, dynamic> toRegisterJson(String password, String passwordConfirmation) {
    return {
      'name': fullName,
      'email': email,
      'password': password,
      'confirmPassword': passwordConfirmation,
      'noTelephone': phoneNumber,
      'address': userAddress,
    };
  }

  Map<String, dynamic> toStorageJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
      'user_address': userAddress,
      'company_id': companyId,
      'role': role,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, fullName, email, phoneNumber, userAddress, companyId, role, createdAt, updatedAt];
}

class RegisterResponse {
  final bool success;
  final String? message;
  final RegisterData? data;

  RegisterResponse({
    required this.success,
    this.message,
    this.data,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    final meta = json['meta'];
    return RegisterResponse(
      success: (meta?['code'] == 200) || (meta?['code'] == 201), // ✅ Cek code aja
      message: meta?['message'],
      data: json['data'] != null ? RegisterData.fromJson(json['data']) : null,
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
