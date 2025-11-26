import 'package:equatable/equatable.dart';
import '../../core/utils/auth_service.dart';

class Cashier extends Equatable {
  final int? id;
  final String fullName;
  final String email;
  final String password;
  final String passwordConfirmation;
  final String phoneNumber;
  final String? userAddress;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String role;
  final int? companyId;

  const Cashier({
    this.id,
    required this.fullName,
    required this.email,
    required this.password,
    required this.passwordConfirmation,
    required this.phoneNumber,
    this.userAddress,
    this.createdAt,
    this.updatedAt,
    this.companyId,
    this.role = AuthService.ROLE_CASHIER,
  });

  // copyWith untuk update sebagian data
  Cashier copyWith({
    int? id,
    String? fullName,
    String? email,
    String? password,
    String? phoneNumber,
    String? userAddress,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? companyId,
    String? role,
  }) {
    return Cashier(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      password: password ?? this.password,
      passwordConfirmation: passwordConfirmation ?? this.passwordConfirmation,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      userAddress: userAddress ?? this.userAddress,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      companyId: companyId ?? this.companyId,
      role: role ?? this.role,
    );
  }

  // fromJson untuk parsing dari API
  factory Cashier.fromJson(Map<String, dynamic> json) {
    return Cashier(
      id: json['id'] as int?,
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      password: '',
      passwordConfirmation: '',
      phoneNumber: json['phone_number'] ?? '',
      userAddress: json['user_address'],
      companyId: json['company_id'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
      role: json['role_name'] ?? AuthService.ROLE_CASHIER,
    );
  }

  // toJson untuk kirim ke API (untuk update)
  Map<String, dynamic> toJson({
    String? password,
    String? passwordConfirmation,
  }) {
    final data = {
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
      if (userAddress != null) 'user_address': userAddress,
    };

    // Tambahkan password jika disediakan
    if (password != null && password.isNotEmpty) {
      data['password'] = password;
      data['password_confirmation'] = passwordConfirmation ?? password;
    }

    return data;
  }

  // toCreateJson untuk create cashier baru
  Map<String, dynamic> toCreateJson({
    required String password,
    required String passwordConfirmation,
  }) {
    return {
      'full_name': fullName,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
      'phone_number': phoneNumber,
      if (userAddress != null) 'user_address': userAddress,
    };
  }

  // toUpdateJson untuk update cashier (password opsional)
  Map<String, dynamic> toUpdateJson({
    String? password,
    String? passwordConfirmation,
  }) {
    return toJson(
      password: password,
      passwordConfirmation: passwordConfirmation,
    );
  }

  // toStorageJson untuk local storage
  Map<String, dynamic> toStorageJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
      'user_address': userAddress,
      'company_id': companyId,
      'role': role,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  // fromStorageJson untuk parsing dari local storage
  factory Cashier.fromStorageJson(Map<String, dynamic> json) {
    return Cashier(
      id: json['id'] as int?,
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      password: '',
      passwordConfirmation: '',
      phoneNumber: json['phone_number'] ?? '',
      userAddress: json['user_address'],
      companyId: json['company_id'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
      role: json['role'] ?? AuthService.ROLE_CASHIER,
    );
  }

  // Helper untuk cek apakah cashier valid
  bool get isValid {
    return fullName.isNotEmpty &&
        email.isNotEmpty &&
        phoneNumber.isNotEmpty &&
        role == AuthService.ROLE_CASHIER;
  }

  String get displayName => fullName.isEmpty ? email : fullName;

  String get formattedPhone {
    if (phoneNumber.startsWith('0')) {
      return '+62${phoneNumber.substring(1)}';
    }
    return phoneNumber;
  }

  @override
  List<Object?> get props => [
    id,
    fullName,
    email,
    password,
    phoneNumber,
    userAddress,
    createdAt,
    updatedAt,
    role,
    companyId,
  ];

  @override
  String toString() {
    return 'Cashier(id: $id, fullName: $fullName, email: $email, role: $role)';
  }
}