import 'package:pos_mobile/blocs/auth/verification/verification_event.dart';
import 'package:pos_mobile/blocs/auth/verification/verification_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/auth_repository.dart';

class VerificationBloc extends Bloc<VerificationEvent, VerificationState> {
  final AuthRepository _authRepository;

  VerificationBloc({
    required AuthRepository authRepository,
    required int userId,
    required String email,
  })  : _authRepository = authRepository,
        super(VerificationState(userId: userId, email: email)) {

    // Events dari register
    on<VerificationOtpChanged>(_onOtpChanged);
    on<VerificationSubmitted>(_onVerificationSubmitted);
    on<VerificationResendOtp>(_onResendOtpFromRegister);

    // Events dari login (resend OTP page)
    on<ResendOtpEmailChanged>(_onEmailChanged);
    on<ResendOtpSubmitted>(_onResendOtpSubmitted);
    on<ResendOtpResetStatus>(_onResetStatus);
  }

  // ========== Handlers untuk Verification dari Register ==========

  void _onOtpChanged(
      VerificationOtpChanged event,
      Emitter<VerificationState> emit,
      ) {
    emit(state.copyWith(otp: event.otp));
  }

  Future<void> _onVerificationSubmitted(
      VerificationSubmitted event,
      Emitter<VerificationState> emit,
      ) async {
    if (state.otp.length != 6) {
      emit(state.copyWith(
        status: VerificationStatus.failure,
        errorMessage: 'Kode OTP harus 6 digit',
      ));
      return;
    }

    emit(state.copyWith(status: VerificationStatus.loading));

    try {
      final response = await _authRepository.verifyOtp(
        userId: state.userId,
        otpCode: state.otp,
      );

      if (response.success) {
        emit(state.copyWith(status: VerificationStatus.success));
      } else {
        emit(state.copyWith(
          status: VerificationStatus.failure,
          errorMessage: response.message,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: VerificationStatus.failure,
        errorMessage: 'Gagal verifikasi: ${e.toString()}',
      ));
    }
  }

  Future<void> _onResendOtpFromRegister(
      VerificationResendOtp event,
      Emitter<VerificationState> emit,
      ) async {
    emit(state.copyWith(status: VerificationStatus.loading));

    try {
      final response = await _authRepository.resendOtpFromRegister(state.userId);

      if (response.success) {
        emit(state.copyWith(
          status: VerificationStatus.initial,
          errorMessage: null,
        ));
      } else {
        emit(state.copyWith(
          status: VerificationStatus.failure,
          errorMessage: response.message,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: VerificationStatus.failure,
        errorMessage: 'Gagal kirim ulang OTP: ${e.toString()}',
      ));
    }
  }

  // ========== Handlers untuk Resend OTP dari Login ==========

  void _onEmailChanged(
      ResendOtpEmailChanged event,
      Emitter<VerificationState> emit
      ) {
    emit(state.copyWith(
      email: event.email,
      emailError: null,
    ));
  }

  Future<void> _onResendOtpSubmitted(
      ResendOtpSubmitted event,
      Emitter<VerificationState> emit
      ) async {
    // Validasi email
    if (state.email.trim().isEmpty) {
      emit(state.copyWith(emailError: 'Email tidak boleh kosong'));
      return;
    }

    if (!_isValidEmail(state.email)) {
      emit(state.copyWith(emailError: 'Format email tidak valid'));
      return;
    }

    emit(state.copyWith(resendStatus: ResendOtpStatus.loading));

    try {
      final response = await _authRepository.resendOtp(email: state.email.trim());

      if (response.success) {
        emit(state.copyWith(
          resendStatus: ResendOtpStatus.success,
          userId: response.userId,
        ));
      } else {
        emit(state.copyWith(
          resendStatus: ResendOtpStatus.failure,
          errorMessage: response.message,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        resendStatus: ResendOtpStatus.failure,
        errorMessage: 'Terjadi kesalahan: ${e.toString()}',
      ));
    }
  }

  void _onResetStatus(
      ResendOtpResetStatus event,
      Emitter<VerificationState> emit
      ) {
    emit(state.copyWith(resendStatus: ResendOtpStatus.initial));
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}