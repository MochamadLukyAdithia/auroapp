import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_mobile/core/utils/auth_service.dart';
import 'package:pos_mobile/data/repositories/auth_repository.dart';
import '../../../data/models/owner_model.dart';
import 'register_event.dart';
import 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  RegisterBloc(this._authRepository) : super(const RegisterState()) {
    on<RegisterNameChanged>(_onNameChanged);
    on<RegisterEmailChanged>(_onEmailChanged);
    on<RegisterPasswordChanged>(_onPasswordChanged);
    on<RegisterConfirmPasswordChanged>(_onConfirmPasswordChanged);
    on<RegisterPhoneChanged>(_onPhoneChanged);
    // ✅ FIX: daftarkan handler untuk RegisterSourceChanged
    on<RegisterSourceChanged>(_onSourceChanged);
    on<RegisterSubmitted>(_onSubmitted);
    on<RegisterReset>(_onReset);
  }

  final AuthRepository _authRepository;
  void _onReset(RegisterReset event, Emitter<RegisterState> emit) {
    emit(const RegisterState());
  }
  void _onNameChanged(RegisterNameChanged event, Emitter<RegisterState> emit) {
    final name = event.name;
    String? error;
    if (name.trim().isEmpty) {
      error = 'Nama lengkap tidak boleh kosong';
    } else if (name.trim().length < 3) {
      error = 'Nama minimal 3 karakter';
    }
    emit(state.copyWith(name: name, nameError: error));
  }

  void _onEmailChanged(
      RegisterEmailChanged event, Emitter<RegisterState> emit) {
    final email = event.email;
    String? error;
    if (email.trim().isEmpty) {
      error = 'Email tidak boleh kosong';
    } else if (!email.contains('@') || !email.contains('.')) {
      error = 'Format email tidak valid';
    }
    emit(state.copyWith(email: email, emailError: error));
  }

  void _onPasswordChanged(
      RegisterPasswordChanged event, Emitter<RegisterState> emit) {
    final password = event.password;
    String? error;
    if (password.isEmpty) {
      error = 'Password tidak boleh kosong';
    } else if (password.length < 8) {
      error = 'Password minimal 8 karakter';
    }

    String? confirmError = state.confirmPasswordError;
    if (state.confirmPassword.isNotEmpty) {
      confirmError = password == state.confirmPassword ? null : 'Password tidak cocok';
    }

    emit(state.copyWith(
      password: password,
      passwordError: error,
      confirmPasswordError: confirmError,
    ));
  }

  void _onConfirmPasswordChanged(
      RegisterConfirmPasswordChanged event, Emitter<RegisterState> emit) {
    final confirmPassword = event.confirmPassword;
    String? error;
    if (confirmPassword.isEmpty) {
      error = 'Konfirmasi password tidak boleh kosong';
    } else if (confirmPassword != state.password) {
      error = 'Password tidak cocok';
    }
    emit(state.copyWith(
        confirmPassword: confirmPassword, confirmPasswordError: error));
  }

  void _onPhoneChanged(
      RegisterPhoneChanged event, Emitter<RegisterState> emit) {
    final phone = event.phone;
    String? error;
    if (phone.trim().isEmpty) {
      error = 'Nomor telepon tidak boleh kosong';
    } else if (phone.length < 10) {
      error = 'Nomor telepon minimal 10 digit';
    } else if (!RegExp(r'^[0-9]+$').hasMatch(phone)) {
      error = 'Nomor telepon hanya boleh angka';
    }
    emit(state.copyWith(phone: phone, phoneError: error));
  }

  // ✅ FIX: handler baru untuk source dropdown
  void _onSourceChanged(
      RegisterSourceChanged event, Emitter<RegisterState> emit) {
    final source = event.source;
    emit(state.copyWith(
      source: source,
      // hapus error saat user sudah memilih
      sourceError: source.trim().isEmpty ? 'Sumber pendaftaran tidak boleh kosong' : null,
    ));
  }

  Future<void> _onSubmitted(
      RegisterSubmitted event, Emitter<RegisterState> emit) async {
    // Validasi semua field
    String? nameError =
        state.nameError ?? (state.name.trim().isEmpty ? 'Nama lengkap tidak boleh kosong' : null);
    String? emailError =
        state.emailError ?? (state.email.trim().isEmpty ? 'Email tidak boleh kosong' : null);
    String? passwordError =
        state.passwordError ?? (state.password.isEmpty ? 'Password tidak boleh kosong' : null);
    String? confirmPasswordError = state.confirmPasswordError ??
        (state.confirmPassword.isEmpty ? 'Konfirmasi password tidak boleh kosong' : null);
    String? phoneError =
        state.phoneError ?? (state.phone.trim().isEmpty ? 'Nomor telepon tidak boleh kosong' : null);

    // ✅ FIX: validasi source menggunakan sourceError (bukan source field)
    String? sourceError = (state.source == null || state.source!.trim().isEmpty)
        ? 'Sumber pendaftaran tidak boleh kosong'
        : null;

    if (nameError != null ||
        emailError != null ||
        passwordError != null ||
        confirmPasswordError != null ||
        phoneError != null ||
        sourceError != null) {
      emit(state.copyWith(
        status: RegisterStatus.failure,
        errorMessage: 'Mohon lengkapi semua field dengan benar',
        nameError: nameError,
        emailError: emailError,
        passwordError: passwordError,
        confirmPasswordError: confirmPasswordError,
        phoneError: phoneError,
        sourceError: sourceError,
      ));
      return;
    }

    emit(state.copyWith(status: RegisterStatus.loading));

    try {
      final owner = Owner(
        id: 0,
        fullName: state.name.trim(),
        email: state.email.trim(),
        phoneNumber: state.phone.trim(),
        password: state.password,
        confirmPassword: state.confirmPassword,
        role: AuthService.ROLE_OWNER,
      );

      // ✅ FIX: kirim source ke backend
      final requestData = owner.toRegisterJson(
        state.password,
        state.confirmPassword,
        source: state.source,
      );

      final response = await _authRepository.registerOwner(requestData);

      if (response.success) {
        emit(state.copyWith(
          status: RegisterStatus.success,
          userId: response.data?.userId,
          // ✅ simpan email agar bisa diteruskan ke halaman verifikasi
          email: state.email.trim(),
        ));
      } else {
        String? emailErr;
        String? phoneErr;
        String? generalErr;

        if (response.errors != null) {
          emailErr = response.errors!['email'];
          phoneErr = response.errors!['phone'];
        }

        if (emailErr == null && phoneErr == null) {
          final msg = response.message ?? 'Registrasi gagal';
          if (msg.toLowerCase().contains('email')) {
            emailErr = msg;
          } else if (msg.toLowerCase().contains('telepon') ||
              msg.toLowerCase().contains('phone')) {
            phoneErr = msg;
          } else {
            generalErr = msg;
          }
        }

        emit(state.copyWith(
          status: RegisterStatus.failure,
          emailError: emailErr,
          phoneError: phoneErr,
          errorMessage: generalErr,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: RegisterStatus.failure,
        errorMessage: 'Gagal melakukan registrasi: ${e.toString()}',
      ));
    }
  }
}