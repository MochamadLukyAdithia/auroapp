import 'package:equatable/equatable.dart';

abstract class VerificationEvent extends Equatable {
  const VerificationEvent();
}

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