import 'package:equatable/equatable.dart';

enum VerificationStatus { initial, loading, success, failure }

class VerificationState extends Equatable {
  final String otp;
  final int userId;
  final String email;
  final VerificationStatus status;
  final String? errorMessage;

  const VerificationState({
    this.otp = '',
    required this.userId,
    required this.email,
    this.status = VerificationStatus.initial,
    this.errorMessage,
  });

  VerificationState copyWith({
    String? otp,
    int? userId,
    String? email,
    VerificationStatus? status,
    String? errorMessage,
  }) {
    return VerificationState(
      otp: otp ?? this.otp,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [otp, userId, email, status, errorMessage];
}