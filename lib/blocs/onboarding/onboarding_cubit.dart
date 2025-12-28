import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/repositories/company_repository.dart';
import 'onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  final CompanyRepository _companyRepository;
  final SharedPreferences _prefs;

  // Keys untuk local storage
  static const String _draftStoreNameKey = 'draft_store_name';
  static const String _draftStoreAddressKey = 'draft_store_address';
  static const String _draftStorePhoneKey = 'draft_store_phone';
  static const String _draftStoreLogoPathKey = 'draft_store_logo_path';

  OnboardingCubit(this._companyRepository, this._prefs)
      : super(const OnboardingState()) {
    _loadDraft(); // Load draft saat init
  }

  /// Load draft dari local storage saat cubit pertama kali dibuat
  Future<void> _loadDraft() async {
    final storeName = _prefs.getString(_draftStoreNameKey);
    final storeAddress = _prefs.getString(_draftStoreAddressKey);
    final storePhone = _prefs.getString(_draftStorePhoneKey);
    final storeLogoPath = _prefs.getString(_draftStoreLogoPathKey);

    // Cek apakah ada draft yang tersimpan
    if (storeName != null || storeAddress != null || storePhone != null) {
      File? logoFile;
      if (storeLogoPath != null && storeLogoPath.isNotEmpty) {
        final file = File(storeLogoPath);
        if (await file.exists()) {
          logoFile = file;
        }
      }

      emit(state.copyWith(
        storeName: storeName ?? '',
        storeAddress: storeAddress ?? '',
        storePhone: storePhone ?? '',
        storeLogo: logoFile,
      ));
    }
  }

  void storeNameChanged(String value) {
    String? error;
    if (value.isEmpty) {
      error = 'Nama toko tidak boleh kosong';
    } else if (value.length < 3) {
      error = 'Nama toko minimal 3 karakter';
    }

    // Save draft
    _prefs.setString(_draftStoreNameKey, value);

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

    // Save draft
    _prefs.setString(_draftStoreAddressKey, value);

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

    // Save draft
    _prefs.setString(_draftStorePhoneKey, value);

    emit(state.copyWith(
      storePhone: value,
      storePhoneError: error,
    ));
  }

  void storeLogoChanged(File? file) {
    // Save draft
    if (file != null) {
      _prefs.setString(_draftStoreLogoPathKey, file.path);
    } else {
      _prefs.remove(_draftStoreLogoPathKey);
    }

    emit(state.copyWith(storeLogo: file));
  }

  /// Clear semua draft setelah berhasil submit
  Future<void> _clearDraft() async {
    await _prefs.remove(_draftStoreNameKey);
    await _prefs.remove(_draftStoreAddressKey);
    await _prefs.remove(_draftStorePhoneKey);
    await _prefs.remove(_draftStoreLogoPathKey);
  }

  Future<void> submitCompany() async {
    if (!state.isValid) {
      emit(state.copyWith(
        status: OnboardingStatus.failure,
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
        await _clearDraft();
        await _prefs.setBool('onboarding_completed', true);
        await _prefs.reload();

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

  /// Method untuk clear draft secara manual (misal user mau logout)
  Future<void> clearDraftManually() async {
    await _clearDraft();
    emit(const OnboardingState());
  }
}