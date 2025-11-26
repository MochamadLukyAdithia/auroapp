class ChangePasswordRequest {
  final String currentPassword;
  final String newPassword;
  final String newPasswordConfirmation;

  ChangePasswordRequest({
    required this.currentPassword,
    required this.newPassword,
    required this.newPasswordConfirmation,
  });

  Map<String, dynamic> toJson() => {
    'current_password': currentPassword,
    'new_password': newPassword,
    'new_password_confirmation': newPasswordConfirmation,
  };
}

class ChangePasswordResponse {
  final Meta meta;
  final dynamic data;
  final int? totalRecords;

  ChangePasswordResponse({
    required this.meta,
    this.data,
    this.totalRecords,
  });

  factory ChangePasswordResponse.fromJson(Map<String, dynamic> json) {
    return ChangePasswordResponse(
      meta: Meta.fromJson(json['meta']),
      data: json['data'],
      totalRecords: json['totalRecords'],
    );
  }

  // Helper getter
  bool get success => meta.status;
  String get message => meta.message ?? '';
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
    'message': message,
  };
}