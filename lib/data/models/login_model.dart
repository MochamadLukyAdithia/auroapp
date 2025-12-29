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
  final String? loginType;
  final String? accessToken;
  final String? tokenType;
  final UserData? user;
  final String? role;
  final bool requiresVerification;
  final int? userId;
  final String? email;

  LoginData({
    this.loginType,
    this.accessToken,
    this.tokenType,
    this.user,
    this.role,
    this.requiresVerification = false,
    this.userId,
    this.email,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      loginType: json['login_type'],
      accessToken: json['access_token'],
      tokenType: json['token_type'],
      user: json['user'] != null ? UserData.fromJson(json['user']) : null,
      role: json['role'],
      requiresVerification: json['requires_verification'] ?? false,
      userId: json['user_id'],
      email: json['email'],
    );
  }

  // 🆕 Helper untuk cek apakah login sukses penuh
  bool get isFullLogin => accessToken != null && accessToken!.isNotEmpty;
}

class UserData {
  final int id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String userAddress;
  final int? companyId;
  final String? otpCode;
  final DateTime? otpExpiresAt;
  final DateTime? emailVerifiedAt;
  final List<RoleData>? roles;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserData({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.userAddress,
    this.companyId,
    this.otpCode,
    this.otpExpiresAt,
    this.emailVerifiedAt,
    this.roles,
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
      companyId: json['company_id'],
      otpCode: json['otp_code'],
      otpExpiresAt: json['otp_expires_at'] != null
          ? DateTime.tryParse(json['otp_expires_at'])
          : null,
      emailVerifiedAt: json['email_verified_at'] != null
          ? DateTime.tryParse(json['email_verified_at'])
          : null,
      roles: json['roles'] != null
          ? (json['roles'] as List)
          .map((role) => RoleData.fromJson(role))
          .toList()
          : null,
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
    if (companyId != null) 'company_id': companyId,
    if (otpCode != null) 'otp_code': otpCode,
    if (otpExpiresAt != null) 'otp_expires_at': otpExpiresAt!.toIso8601String(),
    if (emailVerifiedAt != null) 'email_verified_at': emailVerifiedAt!.toIso8601String(),
    if (roles != null) 'roles': roles!.map((r) => r.toJson()).toList(),
    if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
  };
}

class RoleData {
  final int id;
  final String name;
  final String guardName;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final RolePivot? pivot;

  RoleData({
    required this.id,
    required this.name,
    required this.guardName,
    this.createdAt,
    this.updatedAt,
    this.pivot,
  });

  factory RoleData.fromJson(Map<String, dynamic> json) {
    return RoleData(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      guardName: json['guard_name'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
      pivot: json['pivot'] != null
          ? RolePivot.fromJson(json['pivot'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'guard_name': guardName,
    if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    if (pivot != null) 'pivot': pivot!.toJson(),
  };
}

class RolePivot {
  final String modelType;
  final int modelId;
  final int roleId;

  RolePivot({
    required this.modelType,
    required this.modelId,
    required this.roleId,
  });

  factory RolePivot.fromJson(Map<String, dynamic> json) {
    return RolePivot(
      modelType: json['model_type'] ?? '',
      modelId: json['model_id'] ?? 0,
      roleId: json['role_id'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'model_type': modelType,
    'model_id': modelId,
    'role_id': roleId,
  };
}

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
    if (message != null) 'message': message,
  };
}