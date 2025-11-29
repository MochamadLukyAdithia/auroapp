import 'package:equatable/equatable.dart';

// Status untuk Verification (dari register)
enum VerificationStatus { initial, loading, success, failure }

// Status untuk Resend OTP (dari login)
enum ResendOtpStatus { initial, loading, success, failure }

class VerificationState extends Equatable {
  // Fields untuk verification dari register
  final String otp;
  final int userId;
  final String email;
  final VerificationStatus status;
  final String? errorMessage;

  // Fields tambahan untuk resend OTP dari login
  final String? emailError;
  final ResendOtpStatus resendStatus;

  const VerificationState({
    this.otp = '',
    required this.userId,
    required this.email,
    this.status = VerificationStatus.initial,
    this.errorMessage,
    this.emailError,
    this.resendStatus = ResendOtpStatus.initial,
  });

  VerificationState copyWith({
    String? otp,
    int? userId,
    String? email,
    VerificationStatus? status,
    String? errorMessage,
    String? emailError,
    ResendOtpStatus? resendStatus,
  }) {
    return VerificationState(
      otp: otp ?? this.otp,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      status: status ?? this.status,
      errorMessage: errorMessage,
      emailError: emailError,
      resendStatus: resendStatus ?? this.resendStatus,
    );
  }

  @override
  List<Object?> get props => [
    otp,
    userId,
    email,
    status,
    errorMessage,
    emailError,
    resendStatus
  ];
}