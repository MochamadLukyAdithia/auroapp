import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/company_repository.dart';
import 'onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  final CompanyRepository _companyRepository;

  OnboardingCubit(this._companyRepository) : super(const OnboardingState());

  void storeNameChanged(String value) {
    String? error;
    if (value.isEmpty) {
      error = 'Nama toko tidak boleh kosong';
    } else if (value.length < 3) {
      error = 'Nama toko minimal 3 karakter';
    }

    emit(state.copyWith(
      storeName: value,
      storeNameError: error,
    ));
  }

  void storeAddressChanged(String value) {
    String? error;
    if (value.isEmpty) {
      error = 'Alamat toko tidak boleh kosong';
    } else if (value.length < 10) {
      error = 'Alamat toko minimal 10 karakter';
    }

    emit(state.copyWith(
      storeAddress: value,
      storeAddressError: error,
    ));
  }

  void storePhoneChanged(String value) {
    String? error;
    if (value.isEmpty) {
      error = 'Nomor telepon tidak boleh kosong';
    } else if (!RegExp(r'^[0-9+]+$').hasMatch(value)) {
      error = 'Nomor telepon hanya boleh berisi angka';
    } else if (value.length < 10) {
      error = 'Nomor telepon minimal 10 digit';
    }

    emit(state.copyWith(
      storePhone: value,
      storePhoneError: error,
    ));
  }

  void storeLogoChanged(File? file) {
    emit(state.copyWith(storeLogo: file));
  }

  Future<void> submitCompany() async {
    if (!state.isValid) {
      emit(state.copyWith(
        errorMessage: 'Mohon lengkapi semua data dengan benar',
      ));
      return;
    }

    emit(state.copyWith(status: OnboardingStatus.loading));

    try {
      final result = await _companyRepository.updateCompany(
        name: state.storeName,
        address: state.storeAddress,
        phone: state.storePhone,
        logo: state.storeLogo,
      );

      if (result.success) {
        emit(state.copyWith(
          status: OnboardingStatus.success,
          errorMessage: null,
        ));
      } else {
        emit(state.copyWith(
          status: OnboardingStatus.failure,
          errorMessage: result.message,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: OnboardingStatus.failure,
        errorMessage: 'Terjadi kesalahan: ${e.toString()}',
      ));
    }
  }

  void resetStatus() {
    emit(state.copyWith(
      status: OnboardingStatus.initial,
      errorMessage: null,
    ));
  }
}