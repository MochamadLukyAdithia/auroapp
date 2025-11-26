import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/utils/auth_service.dart';
import '../../data/models/cashier_model.dart';
import '../../data/repositories/cashier_repository.dart';
import 'cashier_event.dart';
import 'cashier_state.dart';

class CashierBloc extends Bloc<CashierEvent, CashierState> {
  final CashierRepository _cashierRepository;

  CashierBloc(this._cashierRepository) : super(CashierInitial()) {
    on<FetchCashiers>(_onFetchCashiers);
    on<AddCashier>(_onAddCashier);
    on<UpdateCashier>(_onUpdateCashier);
    on<DeleteCashier>(_onDeleteCashier);
    on<SearchCashier>(_onSearchCashier);
  }

  // ✅ FETCH - Load cashiers dari API dengan pagination dan search
  Future<void> _onFetchCashiers(
      FetchCashiers event,
      Emitter<CashierState> emit,
      ) async {
    emit(CashierLoading());
    try {
      final response = await _cashierRepository.getCashiers(
        limit: 100,
        search: event.searchQuery,
      );

      if (response.success && response.data != null) {
        final allUsers = response.data!['cashiers'] as List<Cashier>;
        final cashiers = allUsers.where((user) =>
        user.role == AuthService.ROLE_CASHIER
        ).toList();

        final pagination = {
          'current_page': response.data!['current_page'],
          'last_page': response.data!['last_page'],
          'per_page': response.data!['per_page'],
          'total': response.data!['total'],
        };

        emit(CashierLoaded(
          cashiers: cashiers,
          searchQuery: event.searchQuery,
          pagination: pagination,
        ));
      } else {
        emit(CashierError(response.message));
      }
    } catch (e) {
      emit(CashierError('Gagal memuat data kasir: ${e.toString()}'));
    }
  }

  // ✅ ADD - Create cashier baru via API
  Future<void> _onAddCashier(
      AddCashier event,
      Emitter<CashierState> emit,
      ) async {
    emit(CashierLoading());
    try {
      // Validasi password
      if (event.password.isEmpty || event.passwordConfirmation.isEmpty) {
        emit(const CashierError('Password tidak boleh kosong'));
        return;
      }

      if (event.password != event.passwordConfirmation) {
        emit(const CashierError('Konfirmasi password tidak sesuai'));
        return;
      }

      // Panggil API create cashier
      final response = await _cashierRepository.createCashier(
        cashier: event.cashier,
        password: event.password,
        passwordConfirmation: event.passwordConfirmation,
      );

      if (response.success) {
        // ✅ PERBAIKI: Refresh dulu, baru emit success
        final refreshResponse = await _cashierRepository.getCashiers(limit: 100);

        if (refreshResponse.success && refreshResponse.data != null) {
          final cashiers = refreshResponse.data!['cashiers'] as List<Cashier>;
          final pagination = {
            'current_page': refreshResponse.data!['current_page'],
            'last_page': refreshResponse.data!['last_page'],
            'per_page': refreshResponse.data!['per_page'],
            'total': refreshResponse.data!['total'],
          };

          emit(CashierLoaded(
            cashiers: cashiers,
            pagination: pagination,
            successMessage: 'Kasir berhasil ditambahkan',
          ));
        }
      } else {
        emit(CashierError(response.message));
      }
    } catch (e) {
      emit(CashierError('Gagal menambahkan kasir: ${e.toString()}'));
    }
  }

  // ✅ UPDATE - Update cashier via API
  Future<void> _onUpdateCashier(
      UpdateCashier event,
      Emitter<CashierState> emit,
      ) async {
    emit(CashierLoading());
    try {
      // Validasi ID
      if (event.cashier.id == null) {
        emit(const CashierError('ID kasir tidak valid'));
        return;
      }

      // Validasi password jika diisi
      if (event.password != null && event.password!.isNotEmpty) {
        if (event.passwordConfirmation == null ||
            event.password != event.passwordConfirmation) {
          emit(const CashierError('Konfirmasi password tidak sesuai'));
          return;
        }
      }

      // Panggil API update cashier
      final response = await _cashierRepository.updateCashier(
        id: event.cashier.id!,
        cashier: event.cashier,
      );

      if (response.success) {
        // ✅ Refresh dulu
        final refreshResponse = await _cashierRepository.getCashiers(limit: 100);

        if (refreshResponse.success && refreshResponse.data != null) {
          final cashiers = refreshResponse.data!['cashiers'] as List<Cashier>;
          final pagination = {
            'current_page': refreshResponse.data!['current_page'],
            'last_page': refreshResponse.data!['last_page'],
            'per_page': refreshResponse.data!['per_page'],
            'total': refreshResponse.data!['total'],
          };

          emit(CashierLoaded(
            cashiers: cashiers,
            pagination: pagination,
            successMessage: 'Kasir berhasil diperbarui',
          ));
        }
      } else {
        emit(CashierError(response.message));
      }
    } catch (e) {
      emit(CashierError('Gagal memperbarui kasir: ${e.toString()}'));
    }
  }

  // ✅ DELETE - Hapus cashier via API
  Future<void> _onDeleteCashier(
      DeleteCashier event,
      Emitter<CashierState> emit,
      ) async {
    emit(CashierLoading());
    try {
      final response = await _cashierRepository.deleteCashier(event.cashierId);

      if (response.success) {
        // ✅ Refresh dulu
        final refreshResponse = await _cashierRepository.getCashiers(limit: 100);

        if (refreshResponse.success && refreshResponse.data != null) {
          final cashiers = refreshResponse.data!['cashiers'] as List<Cashier>;
          final pagination = {
            'current_page': refreshResponse.data!['current_page'],
            'last_page': refreshResponse.data!['last_page'],
            'per_page': refreshResponse.data!['per_page'],
            'total': refreshResponse.data!['total'],
          };

          emit(CashierLoaded(
            cashiers: cashiers,
            pagination: pagination,
            successMessage: 'Kasir berhasil dihapus',
          ));
        }
      } else {
        emit(CashierError(response.message));
      }
    } catch (e) {
      emit(CashierError('Gagal menghapus kasir: ${e.toString()}'));
    }
  }

  // ✅ SEARCH - Trigger fetch dengan query (hit API)
  Future<void> _onSearchCashier(
      SearchCashier event,
      Emitter<CashierState> emit,
      ) async {
    // Trigger fetch dengan search query
    add(FetchCashiers(searchQuery: event.query));
  }
}