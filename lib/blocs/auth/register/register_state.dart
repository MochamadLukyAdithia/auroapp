import 'package:equatable/equatable.dart';

enum RegisterStatus { initial, loading, success, failure }

class RegisterState extends Equatable {
  final String name;
  final String email;
  final String password;
  final String confirmPassword;
  final String phone;
  final RegisterStatus status;
  final String? errorMessage;
  final String? nameError;
  final String? emailError;
  final String? passwordError;
  final String? confirmPasswordError;
  final String? phoneError;
  final int? userId;
  final bool hasExistingOwner;
  final String existingOwnerEmail;

  const RegisterState({
    this.name = '',
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.phone = '',
    this.status = RegisterStatus.initial,
    this.errorMessage,
    this.nameError,
    this.emailError,
    this.passwordError,
    this.confirmPasswordError,
    this.phoneError,
    this.hasExistingOwner = false,
    this.existingOwnerEmail = '',
    this.userId,
  });

  // Getter untuk validasi
  bool get isNameValid => name.trim().isNotEmpty;
  bool get isEmailValid => email.contains('@') && email.contains('.');
  bool get isPasswordValid => password.length >= 6;
  bool get isConfirmPasswordValid => confirmPassword == password && confirmPassword.isNotEmpty;
  bool get isPhoneValid => phone.trim().isNotEmpty && phone.length >= 10;

  bool get isFormValid =>
      isNameValid &&
          isEmailValid &&
          isPasswordValid &&
          isConfirmPasswordValid &&
          isPhoneValid;

  RegisterState copyWith({
    String? name,
    String? email,
    String? password,
    String? confirmPassword,
    String? phone,
    RegisterStatus? status,
    String? errorMessage,
    String? nameError,
    String? emailError,
    String? passwordError,
    String? confirmPasswordError,
    String? phoneError,
    bool? hasExistingOwner,
    String? existingOwnerEmail,
    int? userId

  }) {
    return RegisterState(
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      phone: phone ?? this.phone,
      status: status ?? this.status,
      errorMessage: errorMessage,
      nameError: nameError,
      emailError: emailError,
      passwordError: passwordError,
      confirmPasswordError: confirmPasswordError,
      phoneError: phoneError,
      hasExistingOwner: hasExistingOwner ?? this.hasExistingOwner,
      existingOwnerEmail: existingOwnerEmail ?? this.existingOwnerEmail,
      userId: userId ?? this.userId,
    );
  }

  @override
  List<Object?> get props => [
    name,
    email,
    password,
    confirmPassword,
    phone,
    status,
    errorMessage,
    nameError,
    emailError,
    passwordError,
    confirmPasswordError,
    phoneError,
    hasExistingOwner,
    existingOwnerEmail,
  ];
}