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
    on<RegisterSubmitted>(_onSubmitted);
  }

  final AuthRepository _authRepository;

  void _onNameChanged(RegisterNameChanged event, Emitter<RegisterState> emit) {
    final name = event.name;
    String? error;

    if (name.trim().isEmpty) {
      error = 'Nama lengkap tidak boleh kosong';
    } else if (name.trim().length < 3) {
      error = 'Nama minimal 3 karakter';
    }

    emit(state.copyWith(
      name: name,
      nameError: error,
    ));
  }

  void _onEmailChanged(RegisterEmailChanged event, Emitter<RegisterState> emit) {
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

  void _onPasswordChanged(
      RegisterPasswordChanged event, Emitter<RegisterState> emit) {
    final password = event.password;
    String? error;

    if (password.isEmpty) {
      error = 'Password tidak boleh kosong';
    } else if (password.length < 6) {
      error = 'Password minimal 6 karakter';
    }

    // Clear confirm password error jika sekarang sudah match
    String? confirmError = state.confirmPasswordError;
    if (state.confirmPassword.isNotEmpty) {
      if (password == state.confirmPassword) {
        confirmError = null;
      } else {
        confirmError = 'Password tidak cocok';
      }
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
      confirmPassword: confirmPassword,
      confirmPasswordError: error,
    ));
  }

  void _onPhoneChanged(RegisterPhoneChanged event, Emitter<RegisterState> emit) {
    final phone = event.phone;
    String? error;

    if (phone.trim().isEmpty) {
      error = 'Nomor telepon tidak boleh kosong';
    } else if (phone.length < 10) {
      error = 'Nomor telepon minimal 10 digit';
    } else if (!RegExp(r'^[0-9]+$').hasMatch(phone)) {
      error = 'Nomor telepon hanya boleh angka';
    }

    emit(state.copyWith(
      phone: phone,
      phoneError: error,
    ));
  }
  // Future<void> _onSubmitted(
  //     RegisterSubmitted event, Emitter<RegisterState> emit) async {
  //
  //   // Validasi manual untuk field yang belum diisi
  //   String? nameError = state.nameError;
  //   if (state.name.trim().isEmpty && nameError == null) {
  //     nameError = 'Nama lengkap tidak boleh kosong';
  //   }
  //
  //   String? emailError = state.emailError;
  //   if (state.email.trim().isEmpty && emailError == null) {
  //     emailError = 'Email tidak boleh kosong';
  //   }
  //
  //   String? passwordError = state.passwordError;
  //   if (state.password.isEmpty && passwordError == null) {
  //     passwordError = 'Password tidak boleh kosong';
  //   }
  //
  //   String? confirmPasswordError = state.confirmPasswordError;
  //   if (state.confirmPassword.isEmpty && confirmPasswordError == null) {
  //     confirmPasswordError = 'Konfirmasi password tidak boleh kosong';
  //   }
  //
  //   String? phoneError = state.phoneError;
  //   if (state.phone.trim().isEmpty && phoneError == null) {
  //     phoneError = 'Nomor telepon tidak boleh kosong';
  //   }
  //
  //   // Jika ada error, tampilkan semua error
  //   if (nameError != null || emailError != null || passwordError != null ||
  //       confirmPasswordError != null || phoneError != null) {
  //     emit(state.copyWith(
  //       status: RegisterStatus.failure,
  //       errorMessage: 'Mohon lengkapi semua field dengan benar',
  //       nameError: nameError,
  //       emailError: emailError,
  //       passwordError: passwordError,
  //       confirmPasswordError: confirmPasswordError,
  //       phoneError: phoneError,
  //     ));
  //     return;
  //   }
  //
  //   emit(state.copyWith(status: RegisterStatus.loading));
  //
  //   try {
  //     final owner = Owner(
  //       id: 0,
  //       fullName: state.name.trim(),
  //       email: state.email.trim(),
  //       phoneNumber: state.phone.trim(),
  //       userAddress: '',
  //     );
  //
  //     // ✅ Gunakan toRegisterJson
  //     final requestData = owner.toRegisterJson(
  //       state.password,
  //       state.confirmPassword,
  //     );
  //
  //     final response = await _authRepository.registerOwner(requestData);
  //
  //     if (response.success) {
  //       emit(state.copyWith(
  //         status: RegisterStatus.success,
  //         userId: response.data?.userId,
  //       ));
  //     }else {
  //       emit(state.copyWith(
  //         status: RegisterStatus.failure,
  //         errorMessage: response.message,
  //       ));
  //     }
  //   } catch (e) {
  //     emit(state.copyWith(
  //       status: RegisterStatus.failure,
  //       errorMessage: 'Gagal melakukan registrasi: ${e.toString()}',
  //     ));
  //   }
  // }

  Future<void> _onSubmitted(
      RegisterSubmitted event, Emitter<RegisterState> emit) async {


    // Validasi manual untuk field yang belum diisi
    String? nameError = state.nameError;
    if (state.name.trim().isEmpty && nameError == null) {
      nameError = 'Nama lengkap tidak boleh kosong';
    }

    String? emailError = state.emailError;
    if (state.email.trim().isEmpty && emailError == null) {
      emailError = 'Email tidak boleh kosong';
    }

    String? passwordError = state.passwordError;
    if (state.password.isEmpty && passwordError == null) {
      passwordError = 'Password tidak boleh kosong';
    }

    String? confirmPasswordError = state.confirmPasswordError;
    if (state.confirmPassword.isEmpty && confirmPasswordError == null) {
      confirmPasswordError = 'Konfirmasi password tidak boleh kosong';
    }

    String? phoneError = state.phoneError;
    if (state.phone.trim().isEmpty && phoneError == null) {
      phoneError = 'Nomor telepon tidak boleh kosong';
    }

    // Jika ada error, tampilkan semua error
    if (nameError != null || emailError != null || passwordError != null ||
        confirmPasswordError != null || phoneError != null) {

      emit(state.copyWith(
        status: RegisterStatus.failure,
        errorMessage: 'Mohon lengkapi semua field dengan benar',
        nameError: nameError,
        emailError: emailError,
        passwordError: passwordError,
        confirmPasswordError: confirmPasswordError,
        phoneError: phoneError,
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
        userAddress: '',
        role: AuthService.ROLE_OWNER,
      );

      final requestData = owner.toRegisterJson(
        state.password,
        state.confirmPassword,
      );


      final response = await _authRepository.registerOwner(requestData);


      if (response.success) {

        emit(state.copyWith(
          status: RegisterStatus.success,
          userId: response.data?.userId,
        ));
      } else {
        emit(state.copyWith(
          status: RegisterStatus.failure,
          errorMessage: response.message ?? 'Registrasi gagal',
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