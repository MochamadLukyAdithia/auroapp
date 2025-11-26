// Response untuk Verify OTP
class VerifyOtpResponse {
  final bool success;
  final String? message;
  final bool? verified;

  VerifyOtpResponse({
    required this.success,
    this.message,
    this.verified,
  });

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) {
    final meta = json['meta'];
    return VerifyOtpResponse(
      success: meta?['status'] == true,
      message: meta?['message'],
      verified: json['data']?['verified'] ?? false,
    );
  }
}

// Response untuk Resend OTP
class ResendOtpResponse {
  final bool success;
  final String? message;
  final int? userId;
  final bool? otpSent;

  ResendOtpResponse({
    required this.success,
    this.message,
    this.userId,
    this.otpSent,
  });

  factory ResendOtpResponse.fromJson(Map<String, dynamic> json) {
    final meta = json['meta'];
    final data = json['data'];

    return ResendOtpResponse(
      success: meta?['status'] == true,
      message: meta?['message'],
      userId: data?['user_id'],
      otpSent: data?['otp_sent'] ?? false,
    );
  }
}