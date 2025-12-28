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

  // FETCH
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
        final cashiers = allUsers
            .where((user) => user.role == AuthService.ROLE_CASHIER)
            .toList();

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
      emit(CashierError('Gagal memuat data kasir: $e'));
    }
  }

  // ADD
  Future<void> _onAddCashier(
      AddCashier event,
      Emitter<CashierState> emit,
      ) async {
    emit(CashierLoading());
    try {
      if (event.password.isEmpty || event.passwordConfirmation.isEmpty) {
        emit(const CashierError('Password tidak boleh kosong'));
        return;
      }

      if (event.password != event.passwordConfirmation) {
        emit(const CashierError('Konfirmasi password tidak sesuai'));
        return;
      }

      final response = await _cashierRepository.createCashier(
        cashier: event.cashier,
        password: event.password,
        passwordConfirmation: event.passwordConfirmation,
      );

      if (response.success) {
        final refreshResponse =
        await _cashierRepository.getCashiers(limit: 100);

        if (refreshResponse.success && refreshResponse.data != null) {
          final cashiers =
          refreshResponse.data!['cashiers'] as List<Cashier>;
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
      emit(CashierError('Gagal menambahkan kasir: $e'));
    }
  }

  // UPDATE (Password boleh kosong)
  Future<void> _onUpdateCashier(
      UpdateCashier event,
      Emitter<CashierState> emit,
      ) async {
    emit(CashierLoading());
    try {
      if (event.cashier.id == null) {
        emit(const CashierError('ID kasir tidak valid'));
        return;
      }

      // Password optional
      bool includePassword = false;

      if (event.password != null && event.password!.isNotEmpty) {
        if (event.passwordConfirmation == null ||
            event.password != event.passwordConfirmation) {
          emit(const CashierError('Konfirmasi password tidak sesuai'));
          return;
        }
        includePassword = true;
      }

      final response = await _cashierRepository.updateCashier(
        id: event.cashier.id!,
        cashier: event.cashier,
        password: includePassword ? event.password : null,
        passwordConfirmation:
        includePassword ? event.passwordConfirmation : null,
      );

      if (response.success) {
        final refreshResponse =
        await _cashierRepository.getCashiers(limit: 100);

        if (refreshResponse.success && refreshResponse.data != null) {
          final cashiers =
          refreshResponse.data!['cashiers'] as List<Cashier>;
          final pagination = {
            'current_page': refreshResponse.data!['current_page'],
            'last_page': refreshResponse.data!['last_page'],
            'per_page': refreshResponse.data!['per_page'],
            'total': refreshResponse.data!['total'],
          };

          emit(CashierLoaded(
            cashiers: cashiers,
            pagination: pagination,
            successMessage: includePassword
                ? 'Kasir diperbarui (termasuk password)'
                : 'Profil kasir diperbarui',
          ));
        }
      } else {
        emit(CashierError(response.message));
      }
    } catch (e) {
      emit(CashierError('Gagal memperbarui kasir: $e'));
    }
  }

  // DELETE
  Future<void> _onDeleteCashier(
      DeleteCashier event,
      Emitter<CashierState> emit,
      ) async {
    emit(CashierLoading());
    try {
      final response =
      await _cashierRepository.deleteCashier(event.cashierId);

      if (response.success) {
        final refreshResponse =
        await _cashierRepository.getCashiers(limit: 100);

        if (refreshResponse.success && refreshResponse.data != null) {
          final cashiers =
          refreshResponse.data!['cashiers'] as List<Cashier>;
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
      emit(CashierError('Gagal menghapus kasir: $e'));
    }
  }

  // SEARCH
  Future<void> _onSearchCashier(
      SearchCashier event,
      Emitter<CashierState> emit,
      ) async {
    add(FetchCashiers(searchQuery: event.query));
  }
}
