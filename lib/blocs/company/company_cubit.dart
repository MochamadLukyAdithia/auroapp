// company_cubit.dart
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/company_model.dart';
import '../../data/repositories/company_repository.dart';

part 'company_state.dart';

class CompanyCubit extends Cubit<CompanyState> {
  final CompanyRepository _repository;

  CompanyCubit(this._repository) : super(CompanyInitial());

  // ✅ Load Company dari API
  Future<void> loadCompany() async {
    emit(CompanyLoading());

    try {
      final response = await _repository.getCompany();

      if (response.success) {
        if (response.data != null) {
          emit(CompanyLoaded(response.data!));
        } else {
          emit(CompanyEmpty()); // User belum setup company
        }
      } else {
        emit(CompanyError(response.message));
      }
    } catch (e) {
      emit(CompanyError('Failed to load company: ${e.toString()}'));
    }
  }

  // ✅ Save/Update Company ke API
  Future<void> saveCompany({
    required String name,
    required String address,
    required String phone,
    File? logo,
  }) async {
    emit(CompanyLoading());

    try {
      final response = await _repository.updateCompany(
        name: name,
        address: address,
        phone: phone,
        logo: logo,
      );

      if (response.success) {
        // Buat object company temporary untuk state
        final tempCompany = Company(
          name: name,
          address: address,
          phone: phone,
          logo: logo?.path, // Path lokal sementara
        );

        emit(CompanySaved(tempCompany));

        // Reload data dari server untuk dapat URL logo yang benar
        await Future.delayed(const Duration(milliseconds: 500));
        await loadCompany();
      } else {
        emit(CompanyError(response.message));
      }
    } catch (e) {
      emit(CompanyError('Failed to save company: ${e.toString()}'));
    }
  }

  // ✅ Refresh company data
  Future<void> refreshCompany() async {
    await loadCompany();
  }
}