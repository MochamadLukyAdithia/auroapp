import 'package:equatable/equatable.dart';

abstract class RegisterEvent extends Equatable {
  const RegisterEvent();

  @override
  List<Object?> get props => [];
}

class RegisterNameChanged extends RegisterEvent {
  final String name;

  const RegisterNameChanged(this.name);

  @override
  List<Object?> get props => [name];
}

class RegisterEmailChanged extends RegisterEvent {
  final String email;

  const RegisterEmailChanged(this.email);

  @override
  List<Object?> get props => [email];
}

class RegisterPasswordChanged extends RegisterEvent {
  final String password;

  const RegisterPasswordChanged(this.password);

  @override
  List<Object?> get props => [password];
}

class RegisterConfirmPasswordChanged extends RegisterEvent {
  final String confirmPassword;

  const RegisterConfirmPasswordChanged(this.confirmPassword);

  @override
  List<Object?> get props => [confirmPassword];
}

class RegisterPhoneChanged extends RegisterEvent {
  final String phone;

  const RegisterPhoneChanged(this.phone);

  @override
  List<Object?> get props => [phone];
}
class RegisterSourceChanged extends RegisterEvent {
  final String source;

  const RegisterSourceChanged(this.source);

  @override
  List<Object?> get props => [source];
}

class RegisterSubmitted extends RegisterEvent {
  const RegisterSubmitted();
}
class RegisterReset extends RegisterEvent {
  const RegisterReset();
}
