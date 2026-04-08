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
  final String? source;
  // ✅ FIX: pisahkan sourceError dari source agar tidak konflik
  final String? sourceError;
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
    this.source,
    this.sourceError,
    this.hasExistingOwner = false,
    this.existingOwnerEmail = '',
    this.userId,
  });

  bool get isNameValid => name.trim().isNotEmpty;
  bool get isEmailValid => email.contains('@') && email.contains('.');
  bool get isPasswordValid => password.length >= 8;
  bool get isConfirmPasswordValid =>
      confirmPassword == password && confirmPassword.isNotEmpty;
  bool get isPhoneValid => phone.trim().isNotEmpty && phone.length >= 10;
  bool get isSourceValid => source != null && source!.trim().isNotEmpty;

  bool get isFormValid =>
      isNameValid &&
          isEmailValid &&
          isPasswordValid &&
          isConfirmPasswordValid &&
          isPhoneValid &&
          isSourceValid;

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
    String? source,
    // ✅ FIX: sourceError sekarang field terpisah
    String? sourceError,
    bool? hasExistingOwner,
    String? existingOwnerEmail,
    int? userId,
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
      // ✅ source harus dipertahankan jika tidak diubah
      source: source ?? this.source,
      sourceError: sourceError,
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
    source,
    sourceError,
    hasExistingOwner,
    existingOwnerEmail,
    userId,
  ];
}