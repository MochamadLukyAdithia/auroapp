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

  Future<void> _onLoadCurrentUser(
      LoginLoadCurrentUser event,
      Emitter<LoginState> emit,
      ) async {

    final prefs = await SharedPreferences.getInstance();

    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    if (!isLoggedIn) {
      emit(state.copyWith(status: LoginStatus.unauthenticated));
      return;
    }

    emit(state.copyWith(status: LoginStatus.authenticated));
  }

  void _onResetStatus(LoginResetStatus event, Emitter<LoginState> emit) {
    emit(state.copyWith(
      status: LoginStatus.initial,
      errorMessage: null,
      emailError: null,
      passwordError: null,
    ));
  }

  void _onEmailChanged(LoginEmailChanged event, Emitter<LoginState> emit) {
    final email = event.email;
    String? error;

    if (email.trim().isEmpty) {
      error = 'Email tidak boleh kosong';
    } else if (!email.contains('@')) {
      error = 'Format email tidak valid';
    } else if (!email.contains('.')) {
      error = 'Format email tidak valid';
    }

    emit(state.copyWith(
      email: email,
      emailError: error,
    ));
  }

  void _onPasswordChanged(LoginPasswordChanged event, Emitter<LoginState> emit) {
    final password = event.password;
    String? error;

    if (password.isEmpty) {
      error = 'Password tidak boleh kosong';
    } else if (password.length < 6) {
      error = 'Password minimal 6 karakter';
    }

    emit(state.copyWith(
      password: password,
      passwordError: error,
    ));
  }

  Future<void> _onSubmitted(LoginSubmitted event, Emitter<LoginState> emit) async {
    if (!state.isFormValid) {
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: 'Mohon lengkapi email dan password dengan benar',
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

      if (response.success && response.data != null) {
        final prefs = await SharedPreferences.getInstance();

        // simpan token
        await prefs.setString('access_token', response.data!.accessToken);
        await prefs.setString('token_type', response.data!.tokenType);

        // simpan role
        final role = response.data!.role;
        final userData = response.data!.user;


        final userDataToSave = {
          'id': userData.id,
          'full_name': userData.fullName,
          'email': userData.email,
          'phone_number': userData.phoneNumber,
          'user_address': userData.userAddress,
          'company_id': userData.companyId,
          'role': role, // ⭐ Dari data.role, bukan user.roles[0].name
          if (userData.createdAt != null)
            'created_at': userData.createdAt!.toIso8601String(),
          if (userData.updatedAt != null)
            'updated_at': userData.updatedAt!.toIso8601String(),
        };

        await prefs.setString('current_user_data', jsonEncode(userDataToSave));
        await prefs.setBool('is_logged_in', true);
        await prefs.setString('logged_in_email', userData.email);


        emit(state.copyWith(status: LoginStatus.success));
      } else {
        emit(state.copyWith(
          status: LoginStatus.failure,
          errorMessage: response.message,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: 'Gagal melakukan login: ${e.toString()}',
      ));
    }
  }


  Future<void> _onCheckStatus(LoginCheckStatus event, Emitter<LoginState> emit) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('is_logged_in') ?? false;

      if (isLoggedIn) {
        emit(state.copyWith(status: LoginStatus.authenticated));
      } else {
        emit(state.copyWith(status: LoginStatus.unauthenticated));
      }
    } catch (e) {
      emit(state.copyWith(status: LoginStatus.unauthenticated));
    }
  }

  // Future<void> _onLogoutRequested(LogoutRequested event, Emitter<LoginState> emit) async {
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     await prefs.setBool('is_logged_in', false);
  //     await prefs.remove('logged_in_email');
  //     await prefs.remove('current_user_data');
  //
  //     emit(const LoginState(status: LoginStatus.unauthenticated));
  //   } catch (e) {
  //     emit(state.copyWith(
  //       status: LoginStatus.failure,
  //       errorMessage: 'Gagal logout: ${e.toString()}',
  //     ));
  //   }
  // }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<LoginState> emit) async {
    try {
      await _authRepository.logout();
      emit(const LoginState(status: LoginStatus.unauthenticated));
    } catch (e) {
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: 'Gagal logout: ${e.toString()}',
      ));
    }
  }
}