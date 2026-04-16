import 'package:equatable/equatable.dart';

enum LoginStatus {
  initial,
  loading,
  success,
  failure,
  authenticated,
  unauthenticated,
  needsVerification
}

class LoginState extends Equatable {
  final String email;
  final String password;
  final LoginStatus status;
  final String? errorMessage;
  final String? emailError;
  final String? passwordError;
  final int? userId;
  final String? userEmail;
  final String? role;

  const LoginState({
    this.email = '',
    this.password = '',
    this.status = LoginStatus.initial,
    this.errorMessage,
    this.emailError,
    this.passwordError,
    this.userId,
    this.userEmail,
    this.role,
  });

  // 🔹 Getter validasi
  bool get isEmailValid => email.contains('@') && email.contains('.');
  bool get isPasswordValid => password.length >= 6;
  bool get isFormValid => isEmailValid && isPasswordValid;

  LoginState copyWith({
    String? email,
    String? password,
    LoginStatus? status,
    String? errorMessage,
    String? emailError,
    String? passwordError,
    int? userId,
    String? userEmail,
    String? role, // 🔥 TAMBAHKAN INI
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      status: status ?? this.status,
      errorMessage: errorMessage,
      emailError: emailError,
      passwordError: passwordError,
      userId: userId ?? this.userId,
      userEmail: userEmail ?? this.userEmail,
      role: role ?? this.role, // 🔥 DAN INI
    );
  }

  @override
  List<Object?> get props => [
    email,
    password,
    status,
    errorMessage,
    emailError,
    passwordError,
    userId,
    userEmail,
    role,
  ];
}