import 'package:equatable/equatable.dart';

abstract class VerificationEvent extends Equatable {
  const VerificationEvent();
}

// resend from regist
class VerificationOtpChanged extends VerificationEvent {
  final String otp;
  const VerificationOtpChanged(this.otp);

  @override
  List<Object> get props => [otp];
}

class VerificationSubmitted extends VerificationEvent {
  const VerificationSubmitted();

  @override
  List<Object> get props => [];
}

class VerificationResendOtp extends VerificationEvent {
  const VerificationResendOtp();

  @override
  List<Object> get props => [];
}

// resend from login
class ResendOtpEmailChanged extends VerificationEvent {
  final String email;
  const ResendOtpEmailChanged(this.email);

  @override
  List<Object> get props => [email];
}

class ResendOtpSubmitted extends VerificationEvent {
  const ResendOtpSubmitted();

  @override
  List<Object> get props => [];
}

class ResendOtpResetStatus extends VerificationEvent {
  const ResendOtpResetStatus();

  @override
  List<Object> get props => [];
}