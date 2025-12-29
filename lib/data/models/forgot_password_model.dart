// lib/models/forget_password_model.dart
class ForgetPasswordRequest {
  final String email;

  ForgetPasswordRequest({required this.email});

  Map<String, dynamic> toJson() => {
    'email': email,
  };
}

class ForgetPasswordResponse {
  final String email;
  final bool sent;

  ForgetPasswordResponse({
    required this.email,
    required this.sent,
  });

  factory ForgetPasswordResponse.fromJson(Map<String, dynamic> json) {
    return ForgetPasswordResponse(
      email: json['email'] ?? '',
      sent: json['sent'] ?? false,
    );
  }
}

