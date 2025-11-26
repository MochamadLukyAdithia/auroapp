class LoginRequest {
  final String email;
  final String password;
  final String deviceToken;

  LoginRequest({
    required this.email,
    required this.password,
    this.deviceToken = 'mobile',
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
    'device_token': deviceToken,
  };
}

class LoginResponse {
  final Meta meta;
  final LoginData? data;
  final int? totalRecords;

  LoginResponse({
    required this.meta,
    this.data,
    this.totalRecords,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      meta: Meta.fromJson(json['meta']),
      data: json['data'] != null ? LoginData.fromJson(json['data']) : null,
      totalRecords: json['totalRecords'],
    );
  }

  // Helper getters
  bool get success => meta.status;
  String get message => meta.message ?? '';
}

class LoginData {
  final String loginType;
  final String accessToken;
  final String tokenType;
  final UserData user;
  final String role;

  LoginData({
    required this.loginType,
    required this.accessToken,
    required this.tokenType,
    required this.user,
    required this.role,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      loginType: json['login_type'] ?? '',
      accessToken: json['access_token'] ?? '',
      tokenType: json['token_type'] ?? 'Bearer',
      user: UserData.fromJson(json['user']),
      role: json['role'] ?? '',
    );
  }
}

class UserData {
  final int id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String userAddress;
  final int? companyId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserData({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.userAddress,
    this.companyId,
    this.createdAt,
    this.updatedAt,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'] ?? 0,
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      userAddress: json['user_address'] ?? '',
      companyId: json['company_id'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }


  Map<String, dynamic> toJson() => {
    'id': id,
    'full_name': fullName,
    'email': email,
    'phone_number': phoneNumber,
    'user_address': userAddress,
    'company_id': companyId,
    if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
  };
}

// Meta class (sama seperti di change_password_model.dart)
class Meta {
  final int code;
  final bool status;
  final String? message;

  Meta({
    required this.code,
    required this.status,
    this.message,
  });

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      code: json['code'],
      status: json['status'],
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() => {
    'code': code,
    'status': status,
    'message': message,
  };
}