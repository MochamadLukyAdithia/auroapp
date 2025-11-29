import 'dart:io';

enum OnboardingStatus {
  initial,
  loading,
  success,
  failure,
}

class OnboardingState {
  final OnboardingStatus status;
  final String storeName;
  final String storeAddress;
  final String storePhone;
  final File? storeLogo;
  final String? storeNameError;
  final String? storeAddressError;
  final String? storePhoneError;
  final String? errorMessage;

  const OnboardingState({
    this.status = OnboardingStatus.initial,
    this.storeName = '',
    this.storeAddress = '',
    this.storePhone = '',
    this.storeLogo,
    this.storeNameError,
    this.storeAddressError,
    this.storePhoneError,
    this.errorMessage,
  });

  OnboardingState copyWith({
    OnboardingStatus? status,
    String? storeName,
    String? storeAddress,
    String? storePhone,
    File? storeLogo,
    String? storeNameError,
    String? storeAddressError,
    String? storePhoneError,
    String? errorMessage,
  }) {
    return OnboardingState(
      status: status ?? this.status,
      storeName: storeName ?? this.storeName,
      storeAddress: storeAddress ?? this.storeAddress,
      storePhone: storePhone ?? this.storePhone,
      storeLogo: storeLogo ?? this.storeLogo,
      storeNameError: storeNameError,
      storeAddressError: storeAddressError,
      storePhoneError: storePhoneError,
      errorMessage: errorMessage,
    );
  }

  bool get isValid {
    return storeName.isNotEmpty &&
        storeAddress.isNotEmpty &&
        storePhone.isNotEmpty &&
        storeNameError == null &&
        storeAddressError == null &&
        storePhoneError == null;
  }
}