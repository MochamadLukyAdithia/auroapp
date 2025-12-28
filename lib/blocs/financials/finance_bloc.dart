// blocs/finance/finance_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/finance_model.dart';
import '../../data/repositories/finance_repository.dart';
import '../../data/repositories/outcome_repository.dart';
import 'finance_event.dart';
import 'finance_state.dart';

class FinanceBloc extends Bloc<FinanceEvent, FinanceState> {
  final FinanceRepository _repository;
  final OutcomeRepository _outcomeRepository;

  FinanceBloc({
    required FinanceRepository repository,
    required OutcomeRepository outcomeRepository,
  })  : _repository = repository,
        _outcomeRepository = outcomeRepository,
        super(FinanceInitial()) {
    on<FetchFinances>(_onFetchFinances);
    on<FetchOutcomeReport>(_onFetchOutcomeReport); // TAMBAHKAN
    on<AddFinance>(_onAddFinance);
    on<UpdateFinance>(_onUpdateFinance);
    on<DeleteFinance>(_onDeleteFinance);
    on<FilterFinances>(_onFilterFinances);
    on<SearchFinances>(_onSearchFinances);
    on<ToggleSelectionMode>(_onToggleSelectionMode);
    on<ToggleFinanceSelection>(_onToggleFinanceSelection);
    on<SelectAllFinances>(_onSelectAllFinances);
    on<ClearSelection>(_onClearSelection);
    on<DeleteSelectedFinances>(_onDeleteSelectedFinances);
  }

  // ✅ Fetch dari API (untuk halaman finance umum)
  Future<void> _onFetchFinances(
      FetchFinances event,
      Emitter<FinanceState> emit,
      ) async {
    emit(FinanceLoading());
    try {
      final result = await _repository.getFinancials(
        limit: 100,
        page: 1,
      );

      if (result.success && result.data != null) {
        emit(FinanceLoaded(finances: result.data!));
      } else {
        emit(FinanceError(result.message));
      }
    } catch (e) {
      emit(FinanceError('Gagal memuat data keuangan: ${e.toString()}'));
    }
  }

  // ✅ Fetch Outcome Report (untuk expenditure report page)
  Future<void> _onFetchOutcomeReport(
      FetchOutcomeReport event,
      Emitter<FinanceState> emit,
      ) async {
    emit(FinanceLoading());
    try {
      final result = await _outcomeRepository.getOutcomeReport(
        limit: event.limit,
        page: event.page,
        month: event.month,
        year: event.year,
      );

      if (result.success && result.data != null) {
        final outcomeData = result.data!['outcome'];
        final List<Finance> outcomes = [];

        if (outcomeData != null && outcomeData['data'] != null) {
          for (var item in outcomeData['data']) {
            outcomes.add(Finance(
              id: item['id'],
              name: item['namaTransaksi'] ?? '',
              amount: double.parse(item['nominal'].toString()),
              type: FinanceType.outcome,
              date: DateTime.parse(item['tanggal']),
              description: item['catatan'],
            ));
          }
        }

        emit(FinanceLoaded(finances: outcomes));
      } else {
        emit(FinanceError(result.message));
      }
    } catch (e) {
      emit(FinanceError('Gagal memuat laporan pengeluaran: ${e.toString()}'));
    }
  }

  // ✅ Add finance via API
  Future<void> _onAddFinance(
      AddFinance event,
      Emitter<FinanceState> emit,
      ) async {
    emit(FinanceLoading());

    try {
      final result = await _repository.createFinance(event.finance);

      if (result.success && result.data != null) {
        emit(const FinanceOperationSuccess('Catatan keuangan berhasil ditambahkan'));

        // Fetch ulang data dari API
        add(const FetchFinances());
      } else {
        emit(FinanceError(result.message));
      }
    } catch (e) {
      emit(FinanceError('Gagal menambahkan catatan: ${e.toString()}'));
    }
  }

  // ✅ Update finance via API
  Future<void> _onUpdateFinance(
      UpdateFinance event,
      Emitter<FinanceState> emit,
      ) async {
    emit(FinanceLoading());

    try {
      emit(const FinanceOperationSuccess('Catatan keuangan berhasil diperbarui'));

      // Fetch ulang data dari API
      add(const FetchFinances());
    } catch (e) {
      emit(FinanceError('Gagal memperbarui catatan: ${e.toString()}'));
    }
  }

  // ✅ Delete finance via API
  Future<void> _onDeleteFinance(
      DeleteFinance event,
      Emitter<FinanceState> emit,
      ) async {
    emit(FinanceLoading());

    try {
      final id = int.tryParse(event.financeId);
      if (id == null) {
        emit(const FinanceError('ID tidak valid'));
        return;
      }

      final result = await _repository.deleteFinance(id);

      if (result.success) {
        emit(const FinanceOperationSuccess('Catatan keuangan berhasil dihapus'));

        // Fetch ulang data dari API
        add(const FetchFinances());
      } else {
        emit(FinanceError(result.message));
      }
    } catch (e) {
      emit(FinanceError('Gagal menghapus catatan: ${e.toString()}'));
    }
  }

  // Filter finances
  Future<void> _onFilterFinances(
      FilterFinances event,
      Emitter<FinanceState> emit,
      ) async {
    final currentState = state;
    if (currentState is FinanceLoaded) {
      emit(FinanceLoaded(
        finances: currentState.finances,
        searchQuery: currentState.searchQuery,
        filterType: event.type,
        startDate: event.startDate,
        endDate: event.endDate,
        sortBy: event.sortBy,
      ));
    }
  }

  // Search finances
  Future<void> _onSearchFinances(
      SearchFinances event,
      Emitter<FinanceState> emit,
      ) async {
    final currentState = state;
    if (currentState is FinanceLoaded) {
      emit(FinanceLoaded(
        finances: currentState.finances,
        searchQuery: event.query,
        filterType: currentState.filterType,
        startDate: currentState.startDate,
        endDate: currentState.endDate,
        sortBy: currentState.sortBy,
      ));
    }
  }

  // Toggle selection mode
  void _onToggleSelectionMode(
      ToggleSelectionMode event,
      Emitter<FinanceState> emit,
      ) {
    final currentState = state;
    if (currentState is FinanceLoaded) {
      emit(currentState.copyWith(
        isSelectionMode: !currentState.isSelectionMode,
        selectedFinanceIds: {},
      ));
    }
  }

  // Toggle finance selection
  void _onToggleFinanceSelection(
      ToggleFinanceSelection event,
      Emitter<FinanceState> emit,
      ) {
    final currentState = state;
    if (currentState is FinanceLoaded) {
      final updated = Set<String>.from(currentState.selectedFinanceIds);
      if (updated.contains(event.financeId)) {
        updated.remove(event.financeId);
      } else {
        updated.add(event.financeId);
      }
      emit(currentState.copyWith(selectedFinanceIds: updated));
    }
  }

  // Select all finances
  void _onSelectAllFinances(
      SelectAllFinances event,
      Emitter<FinanceState> emit,
      ) {
    final currentState = state;
    if (currentState is FinanceLoaded) {
      final allIds = currentState.filteredFinances
          .where((f) => f.id != null)
          .map((f) => f.id.toString())
          .toSet();
      emit(currentState.copyWith(selectedFinanceIds: allIds));
    }
  }

  // Clear selection
  void _onClearSelection(
      ClearSelection event,
      Emitter<FinanceState> emit,
      ) {
    final currentState = state;
    if (currentState is FinanceLoaded) {
      emit(currentState.copyWith(
        selectedFinanceIds: {},
        isSelectionMode: false,
      ));
    }
  }

  // ✅ Delete selected finances via API
  Future<void> _onDeleteSelectedFinances(
      DeleteSelectedFinances event,
      Emitter<FinanceState> emit,
      ) async {
    final currentState = state;
    if (currentState is FinanceLoaded) {
      emit(FinanceLoading());

      try {
        final selectedIds = currentState.selectedFinanceIds;
        int successCount = 0;
        int failCount = 0;

        // Delete satu per satu
        for (final idString in selectedIds) {
          final id = int.tryParse(idString);
          if (id != null) {
            final result = await _repository.deleteFinance(id);
            if (result.success) {
              successCount++;
            } else {
              failCount++;
            }
          }
        }

        if (failCount == 0) {
          emit(FinanceOperationSuccess(
            '$successCount catatan berhasil dihapus',
          ));
        } else {
          emit(FinanceOperationSuccess(
            '$successCount berhasil, $failCount gagal dihapus',
          ));
        }

        // Fetch ulang data dari API
        add(const FetchFinances());
      } catch (e) {
        emit(FinanceError('Gagal menghapus catatan: ${e.toString()}'));
      }
    }
  }
}