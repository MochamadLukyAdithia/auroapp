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
    on<VerificationOtpChanged>(_onOtpChanged);
    on<VerificationSubmitted>(_onSubmitted);
    on<VerificationResendOtp>(_onResendOtp);
  }

  void _onOtpChanged(
      VerificationOtpChanged event,
      Emitter<VerificationState> emit,
      ) {
    emit(state.copyWith(otp: event.otp));
  }

  Future<void> _onSubmitted(
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

  Future<void> _onResendOtp(
      VerificationResendOtp event,
      Emitter<VerificationState> emit,
      ) async {
    emit(state.copyWith(status: VerificationStatus.loading));

    try {
      final response = await _authRepository.resendOtp(state.userId);

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
}