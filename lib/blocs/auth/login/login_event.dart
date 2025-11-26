import 'package:equatable/equatable.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object?> get props => [];
}

class LoginEmailChanged extends LoginEvent {
  final String email;

  const LoginEmailChanged(this.email);

  @override
  List<Object?> get props => [email];
}

class LoginPasswordChanged extends LoginEvent {
  final String password;

  const LoginPasswordChanged(this.password);

  @override
  List<Object?> get props => [password];
}

class LoginSubmitted extends LoginEvent {
  const LoginSubmitted();
}

class LoginCheckStatus extends LoginEvent {
  const LoginCheckStatus();
}

class LogoutRequested extends LoginEvent {
  const LogoutRequested();
}

class LoginResetStatus extends LoginEvent {
  const LoginResetStatus();
}

class LoginLoadCurrentUser extends LoginEvent {
  const LoginLoadCurrentUser();
}
