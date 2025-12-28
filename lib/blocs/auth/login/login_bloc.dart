import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/models/login_model.dart';
import '../../../data/repositories/auth_repository.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc(this._authRepository) : super(const LoginState()) {
    on<LoginEmailChanged>(_onEmailChanged);
    on<LoginPasswordChanged>(_onPasswordChanged);
    on<LoginSubmitted>(_onSubmitted);
    on<LoginCheckStatus>(_onCheckStatus);
    on<LogoutRequested>(_onLogoutRequested);
    on<LoginResetStatus>(_onResetStatus);
    on<LoginLoadCurrentUser>(_onLoadCurrentUser);
  }

  final AuthRepository _authRepository;

  // ==================== LOAD CURRENT USER ====================
  Future<void> _onLoadCurrentUser(
      LoginLoadCurrentUser event,
      Emitter<LoginState> emit,
      ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('is_logged_in') ?? false;

      emit(state.copyWith(
        status: isLoggedIn ? LoginStatus.authenticated : LoginStatus.unauthenticated,
      ));
    } catch (e) {
      emit(state.copyWith(status: LoginStatus.unauthenticated));
    }
  }

  // ==================== RESET STATUS ====================
  void _onResetStatus(LoginResetStatus event, Emitter<LoginState> emit) {
    emit(state.copyWith(
      status: LoginStatus.initial,
      errorMessage: null,
      emailError: null,
      passwordError: null,
    ));
  }

  // ==================== EMAIL VALIDATION ====================
  void _onEmailChanged(LoginEmailChanged event, Emitter<LoginState> emit) {
    emit(state.copyWith(
      email: event.email,
      emailError: _validateEmail(event.email),
    ));
  }

  String? _validateEmail(String email) {
    final trimmedEmail = email.trim();

    if (trimmedEmail.isEmpty) {
      return 'Email tidak boleh kosong';
    }

    // Basic email regex
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(trimmedEmail)) {
      return 'Format email tidak valid';
    }

    return null;
  }

  // ==================== PASSWORD VALIDATION ====================
  void _onPasswordChanged(LoginPasswordChanged event, Emitter<LoginState> emit) {
    emit(state.copyWith(
      password: event.password,
      passwordError: _validatePassword(event.password),
    ));
  }

  String? _validatePassword(String password) {
    if (password.isEmpty) {
      return 'Password tidak boleh kosong';
    }

    if (password.length < 8) {
      return 'Password minimal 8 karakter';
    }

    return null;
  }

  // ==================== LOGIN SUBMISSION ====================
  Future<void> _onSubmitted(LoginSubmitted event, Emitter<LoginState> emit) async {
    // Validate before submission
    final emailError = _validateEmail(state.email);
    final passwordError = _validatePassword(state.password);

    if (emailError != null || passwordError != null) {
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: 'Mohon lengkapi email dan password dengan benar',
        emailError: emailError,
        passwordError: passwordError,
      ));
      return;
    }

    emit(state.copyWith(status: LoginStatus.loading));

    try {
      final request = LoginRequest(
        email: state.email.trim(),
        password: state.password,
        deviceToken: 'mobile',
      );

      final response = await _authRepository.login(request);

      await _handleLoginResponse(response, emit);

    } on Exception catch (e) {
      _handleLoginException(e, emit);
    }
  }

  // ==================== HANDLE LOGIN RESPONSE ====================
  Future<void> _handleLoginResponse(
      LoginResponse response,
      Emitter<LoginState> emit,
      ) async {
    // ✅ SUCCESS - Login berhasil
    if (response.success && response.data != null) {
      // Check if owner needs verification
      if (response.data!.requiresVerification == true) {
        emit(state.copyWith(
          status: LoginStatus.needsVerification,
          userId: response.data!.userId,
          userEmail: response.data!.email,
        ));
        return;
      }

      // Normal login - validate data
      if (!_isLoginDataComplete(response.data!)) {
        emit(state.copyWith(
          status: LoginStatus.failure,
          errorMessage: 'Data login tidak lengkap dari server',
        ));
        return;
      }

      // Save login data
      await _saveLoginData(response.data!);

      emit(state.copyWith(status: LoginStatus.success));
    }
    // ❌ FAILURE - Parse error dari backend
    else {
      _handleLoginError(response.message ?? 'Login gagal', emit);
    }
  }

  // ==================== VALIDATE LOGIN DATA ====================
  bool _isLoginDataComplete(LoginData data) {
    return data.user != null &&
        data.role != null &&
        data.accessToken != null &&
        data.tokenType != null;
  }

  // ==================== SAVE LOGIN DATA ====================
  Future<void> _saveLoginData(LoginData data) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('access_token', data.accessToken!);
    await prefs.setString('token_type', data.tokenType!);

    final userData = data.user!;
    final userDataToSave = {
      'id': userData.id,
      'full_name': userData.fullName,
      'email': userData.email,
      'phone_number': userData.phoneNumber,
      'user_address': userData.userAddress,
      'company_id': userData.companyId,
      'role': data.role!,
      if (userData.createdAt != null)
        'created_at': userData.createdAt!.toIso8601String(),
      if (userData.updatedAt != null)
        'updated_at': userData.updatedAt!.toIso8601String(),
    };

    await prefs.setString('current_user_data', jsonEncode(userDataToSave));
    await prefs.setBool('is_logged_in', true);
    await prefs.setString('logged_in_email', userData.email);
  }

  // ==================== HANDLE LOGIN ERROR ====================
  void _handleLoginError(String errorMsg, Emitter<LoginState> emit) {
    final lowerMsg = errorMsg.toLowerCase();

    // Email tidak ditemukan
    if (lowerMsg.contains('email tidak ditemukan') ||
        lowerMsg.contains('tidak terdaftar') ||
        lowerMsg.contains('tidak dikenali')) {
      emit(state.copyWith(
        status: LoginStatus.failure,
        emailError: 'Email tidak terdaftar',
      ));
      return;
    }

    // Password salah
    if (lowerMsg.contains('password salah')) {
      emit(state.copyWith(
        status: LoginStatus.failure,
        passwordError: 'Password salah',
      ));
      return;
    }

    // Email belum diverifikasi
    if (lowerMsg.contains('email belum diverifikasi')) {
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: 'Email belum diverifikasi. Silakan verifikasi terlebih dahulu.',
      ));
      return;
    }

    // Error umum lainnya
    emit(state.copyWith(
      status: LoginStatus.failure,
      errorMessage: errorMsg,
    ));
  }

  // ==================== HANDLE EXCEPTION ====================
  void _handleLoginException(Exception e, Emitter<LoginState> emit) {
    final errorString = e.toString();

    String errorMessage;
    if (errorString.contains('Network error')) {
      errorMessage = 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';
    } else if (errorString.contains('SocketException')) {
      errorMessage = 'Koneksi terputus. Periksa koneksi internet Anda.';
    } else if (errorString.contains('TimeoutException')) {
      errorMessage = 'Permintaan timeout. Silakan coba lagi.';
    } else {
      errorMessage = 'Terjadi kesalahan. Silakan coba lagi.';
    }

    emit(state.copyWith(
      status: LoginStatus.failure,
      errorMessage: errorMessage,
    ));
  }

  // ==================== CHECK LOGIN STATUS ====================
  Future<void> _onCheckStatus(LoginCheckStatus event, Emitter<LoginState> emit) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('is_logged_in') ?? false;

      emit(state.copyWith(
        status: isLoggedIn ? LoginStatus.authenticated : LoginStatus.unauthenticated,
      ));
    } catch (e) {
      emit(state.copyWith(status: LoginStatus.unauthenticated));
    }
  }

  // ==================== LOGOUT ====================
  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<LoginState> emit) async {
    try {
      emit(state.copyWith(status: LoginStatus.loading));
      await _authRepository.logout();
      emit(const LoginState(status: LoginStatus.unauthenticated));
    } catch (e) {
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: 'Gagal logout. Silakan coba lagi.',
      ));
    }
  }
}