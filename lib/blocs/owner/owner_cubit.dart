import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/owner_model.dart';
import '../../data/repositories/profile_repository.dart';
import 'owner_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository _profileRepository;

  ProfileCubit(this._profileRepository) : super(ProfileInitial());

  // Load profile dari API
  Future<void> loadProfile() async {
    try {
      emit(ProfileLoading());

      final response = await _profileRepository.getProfile();

      if (response.success && response.data != null) {
        emit(ProfileLoaded(response.data!));
      } else {
        emit(ProfileError(response.message, code: response.code));
      }
    } catch (e) {
      emit(ProfileError('Gagal memuat profil: ${e.toString()}'));
    }
  }

  // Update profile
  Future<void> updateProfile({
    required String name,
    required String phone,
  }) async {
    try {
      emit(ProfileUpdating());

      final response = await _profileRepository.updateProfile(
        fullName: name,
        phoneNumber: phone,
      );

      if (response.success) {
        // Load ulang data terbaru dari API
        await loadProfile();

        // Emit ProfileUpdated dengan data yang baru
        final currentOwner = getCurrentOwner();
        if (currentOwner != null) {
          emit(ProfileUpdated(currentOwner, response.message));
        }
      } else {
        emit(ProfileUpdateError(response.message, code: response.code));
      }
    } catch (e) {
      emit(ProfileUpdateError('Gagal memperbarui profil: ${e.toString()}'));
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      emit(ProfileUpdating());

      final response = await _profileRepository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      if (response.success) {
        emit(PasswordChanged(response.message));
      } else {
        emit(ProfileUpdateError(response.message, code: response.code));
      }
    } catch (e) {
      emit(ProfileUpdateError('Gagal mengubah password: ${e.toString()}'));
    }
  }

  // Get current owner synchronously
  Owner? getCurrentOwner() {
    final currentState = state;
    if (currentState is ProfileLoaded) {
      return currentState.owner;
    } else if (currentState is ProfileUpdated) {
      return currentState.owner;
    }
    return null;
  }

  // Check apakah owner sudah ada (dari API)
  Future<bool> hasProfile() async {
    try {
      final response = await _profileRepository.getProfile();
      return response.success && response.data != null;
    } catch (e) {
      return false;
    }
  }

  // Clear profile data (untuk logout)
  void clearProfile() {
    emit(ProfileInitial());
  }
}