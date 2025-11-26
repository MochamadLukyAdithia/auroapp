import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/owner_model.dart';
import '../../data/repositories/profile_repository.dart';
import 'owner_state.dart';


class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository _profileRepository;
  static const String _ownerKey = 'owner_data';

  ProfileCubit(this._profileRepository) : super(ProfileInitial());

  // Load profile dari API dan sync ke SharedPreferences
  Future<void> loadProfile() async {
    try {
      emit(ProfileLoading());

      final response = await _profileRepository.getProfile();

      if (response.success && response.data != null) {
        final owner = response.data!;

        // Simpan ke SharedPreferences
        await _saveToLocalStorage(owner);

        emit(ProfileLoaded(owner));
      } else {
        // Jika gagal dari API, coba load dari local storage
        final localOwner = await _loadFromLocalStorage();

        if (localOwner != null) {
          emit(ProfileLoaded(localOwner));
        } else {
          emit(ProfileError(response.message, code: response.code));
        }
      }
    } catch (e) {
      // Jika error, coba load dari local storage
      final localOwner = await _loadFromLocalStorage();

      if (localOwner != null) {
        emit(ProfileLoaded(localOwner));
      } else {
        emit(ProfileError('Gagal memuat profil: ${e.toString()}'));
      }
    }
  }

  // Update profile
  Future<void> updateProfile({
    required String name,
    required String phone,
    required String address,
    String? email,
  }) async {
    try {
      emit(ProfileUpdating());

      final response = await _profileRepository.updateProfile(
        fullName: name,
        phoneNumber: phone,
        userAddress: address,
        email: email,
      );

      if (response.success && response.data != null) {
        final owner = response.data!;

        // Simpan ke SharedPreferences
        await _saveToLocalStorage(owner);

        emit(ProfileUpdated(owner, response.message));

        // Setelah update, emit ProfileLoaded agar UI konsisten
        await Future.delayed(const Duration(milliseconds: 500));
        emit(ProfileLoaded(owner));
      } else {
        emit(ProfileUpdateError(response.message, code: response.code));
      }
    } catch (e) {
      emit(ProfileUpdateError('Gagal memperbarui profil: ${e.toString()}'));
    }
  }

  // Update profile dengan foto
  Future<void> updateProfileWithPhoto({
    required String name,
    required String phone,
    required String address,
    String? email,
    String? photoPath,
  }) async {
    try {
      emit(ProfileUpdating());

      final response = await _profileRepository.updateProfileWithPhoto(
        name: name,
        phone: phone,
        address: address,
        email: email,
        photoPath: photoPath,
      );

      if (response.success && response.data != null) {
        final owner = response.data!;

        // Simpan ke SharedPreferences
        await _saveToLocalStorage(owner);

        emit(ProfileUpdated(owner, response.message));

        // Setelah update, emit ProfileLoaded agar UI konsisten
        await Future.delayed(const Duration(milliseconds: 500));
        emit(ProfileLoaded(owner));
      } else {
        emit(ProfileUpdateError(response.message, code: response.code));
      }
    } catch (e) {
      emit(ProfileUpdateError('Gagal memperbarui profil: ${e.toString()}'));
    }
  }

  // Load profile dari local storage saja (offline mode)
  Future<void> loadProfileFromLocal() async {
    try {
      emit(ProfileLoading());

      final owner = await _loadFromLocalStorage();

      if (owner != null) {
        emit(ProfileLoaded(owner));
      } else {
        emit(const ProfileError('Profil tidak ditemukan'));
      }
    } catch (e) {
      emit(ProfileError('Gagal memuat profil: ${e.toString()}'));
    }
  }

  // Check apakah owner sudah ada
  Future<bool> hasProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ownerJson = prefs.getString(_ownerKey);
      return ownerJson != null && ownerJson.isNotEmpty;
    } catch (e) {
      return false;
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

  // Clear profile data (untuk logout)
  Future<void> clearProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_ownerKey);
      emit(ProfileInitial());
    } catch (e) {
      emit(ProfileError('Gagal menghapus profil: ${e.toString()}'));
    }
  }

  // Private helper: Save to SharedPreferences
  Future<void> _saveToLocalStorage(Owner owner) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ownerJson = jsonEncode(owner.toJson());
      await prefs.setString(_ownerKey, ownerJson);
    } catch (e) {
      // Silent fail - tidak perlu throw error
      print('Failed to save to local storage: $e');
    }
  }

  // Private helper: Load from SharedPreferences
  Future<Owner?> _loadFromLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ownerJson = prefs.getString(_ownerKey);

      if (ownerJson == null || ownerJson.isEmpty) {
        return null;
      }

      final ownerMap = jsonDecode(ownerJson) as Map<String, dynamic>;
      return Owner.fromJson(ownerMap);
    } catch (e) {
      print('Failed to load from local storage: $e');
      return null;
    }
  }
}