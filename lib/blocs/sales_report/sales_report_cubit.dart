import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/transaction_sales_report_model.dart';
import '../../data/repositories/transaction_sales_repository.dart';

enum ReportPeriod { today, week, month, year, custom }

extension ReportPeriodExtension on ReportPeriod {
  String get displayName {
    switch (this) {
      case ReportPeriod.today:
        return 'Hari Ini';
      case ReportPeriod.week:
        return 'Minggu Ini';
      case ReportPeriod.month:
        return 'Bulan Ini';
      case ReportPeriod.year:
        return 'Tahun Ini';
      case ReportPeriod.custom:
        return 'Custom';
    }
  }
}

class SalesReportState extends Equatable {
  final List<TransactionReport> transactions;
  final TransactionReportSummary? summary;
  final PaginationMeta? meta;
  final ReportPeriod selectedPeriod;
  final bool isLoading;
  final String? errorMessage;
  final DateTime? startDate;
  final DateTime? endDate;
  final String searchQuery;
  final int currentPage;

  const SalesReportState({
    this.transactions = const [],
    this.summary,
    this.meta,
    this.selectedPeriod = ReportPeriod.today,
    this.isLoading = false,
    this.errorMessage,
    this.startDate,
    this.endDate,
    this.searchQuery = '',
    this.currentPage = 1,
  });

  // Total penjualan dari summary
  double get totalSales => summary?.jumlahPendapatan ?? 0;

  // Total transaksi dari summary
  int get totalTransactions => summary?.jumlahTransaksi ?? 0;

  // Total keuntungan dari summary
  double get totalProfit => summary?.jumlahKeuntungan ?? 0;

  // Margin keuntungan (dalam persen)
  double get profitMargin {
    if (totalSales == 0) return 0;
    return (totalProfit / totalSales) * 100;
  }

  // Total item terjual (dihitung dari transaksi yang ada)
  double get totalItemsSold {
    return transactions.fold<double>(0, (sum, t) => sum + t.totalItem);
  }

  // Data untuk grafik berdasarkan transaksi
  Map<DateTime, double> get chartData {
    final Map<DateTime, double> data = {};
    final now = DateTime.now();

    if (selectedPeriod == ReportPeriod.today) {
      // Per jam untuk hari ini
      for (int i = 0; i < 24; i++) {
        final hour = DateTime(now.year, now.month, now.day, i);
        data[hour] = 0;
      }

      for (var transaction in transactions) {
        try {
          final transDate = DateTime.parse(transaction.tanggal);
          final hour = DateTime(
            transDate.year,
            transDate.month,
            transDate.day,
            transDate.hour,
          );
          data[hour] = (data[hour] ?? 0) + transaction.totalPenjualan;
        } catch (e) {
          // Skip invalid date
        }
      }
    } else if (selectedPeriod == ReportPeriod.week) {
      // 7 hari terakhir
      for (int i = 6; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        final day = DateTime(date.year, date.month, date.day);
        data[day] = 0;
      }

      for (var transaction in transactions) {
        try {
          final transDate = DateTime.parse(transaction.tanggal);
          final day = DateTime(transDate.year, transDate.month, transDate.day);
          if (data.containsKey(day)) {
            data[day] = (data[day] ?? 0) + transaction.totalPenjualan;
          }
        } catch (e) {
          // Skip invalid date
        }
      }
    } else if (selectedPeriod == ReportPeriod.month) {
      // Hari dalam bulan ini
      final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
      for (int i = 1; i <= daysInMonth; i++) {
        final day = DateTime(now.year, now.month, i);
        data[day] = 0;
      }

      for (var transaction in transactions) {
        try {
          final transDate = DateTime.parse(transaction.tanggal);
          final day = DateTime(transDate.year, transDate.month, transDate.day);
          if (data.containsKey(day)) {
            data[day] = (data[day] ?? 0) + transaction.totalPenjualan;
          }
        } catch (e) {
          // Skip invalid date
        }
      }
    } else if (selectedPeriod == ReportPeriod.year) {
      // Per bulan dalam tahun ini
      for (int i = 1; i <= 12; i++) {
        final month = DateTime(now.year, i, 1);
        data[month] = 0;
      }

      for (var transaction in transactions) {
        try {
          final transDate = DateTime.parse(transaction.tanggal);
          final month = DateTime(transDate.year, transDate.month, 1);
          if (data.containsKey(month)) {
            data[month] = (data[month] ?? 0) + transaction.totalPenjualan;
          }
        } catch (e) {
          // Skip invalid date
        }
      }
    } else if (selectedPeriod == ReportPeriod.custom && startDate != null && endDate != null) {
      // Custom date range
      final daysDiff = endDate!.difference(startDate!).inDays;

      if (daysDiff > 31) {
        // Per bulan
        DateTime current = DateTime(startDate!.year, startDate!.month, 1);
        final end = DateTime(endDate!.year, endDate!.month, 1);

        while (current.isBefore(end) || current.isAtSameMomentAs(end)) {
          data[current] = 0;
          current = DateTime(current.year, current.month + 1, 1);
        }

        for (var transaction in transactions) {
          try {
            final transDate = DateTime.parse(transaction.tanggal);
            final month = DateTime(transDate.year, transDate.month, 1);
            if (data.containsKey(month)) {
              data[month] = (data[month] ?? 0) + transaction.totalPenjualan;
            }
          } catch (e) {
            // Skip invalid date
          }
        }
      } else {
        // Per hari
        for (int i = 0; i <= daysDiff; i++) {
          final day = DateTime(
            startDate!.year,
            startDate!.month,
            startDate!.day + i,
          );
          data[day] = 0;
        }

        for (var transaction in transactions) {
          try {
            final transDate = DateTime.parse(transaction.tanggal);
            final day = DateTime(transDate.year, transDate.month, transDate.day);
            if (data.containsKey(day)) {
              data[day] = (data[day] ?? 0) + transaction.totalPenjualan;
            }
          } catch (e) {
            // Skip invalid date
          }
        }
      }
    }

    return data;
  }

  SalesReportState copyWith({
    List<TransactionReport>? transactions,
    TransactionReportSummary? summary,
    PaginationMeta? meta,
    ReportPeriod? selectedPeriod,
    bool? isLoading,
    String? errorMessage,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
    int? currentPage,
    bool clearDates = false,
    bool clearError = false,
  }) {
    return SalesReportState(
      transactions: transactions ?? this.transactions,
      summary: summary ?? this.summary,
      meta: meta ?? this.meta,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      startDate: clearDates ? null : (startDate ?? this.startDate),
      endDate: clearDates ? null : (endDate ?? this.endDate),
      searchQuery: searchQuery ?? this.searchQuery,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object?> get props => [
    transactions,
    summary,
    meta,
    selectedPeriod,
    isLoading,
    errorMessage,
    startDate,
    endDate,
    searchQuery,
    currentPage,
  ];
}

class SalesReportCubit extends Cubit<SalesReportState> {
  final TransactionReportRepository _repository;

  SalesReportCubit(this._repository) : super(const SalesReportState());

  /// Load transactions dari API (untuk admin/owner)
  Future<void> loadTransactions({
    int? page,
    int limit = 999999999,
  }) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      // Tentukan date range berdasarkan period
      String? startDate;
      String? endDate;

      if (state.selectedPeriod != ReportPeriod.custom) {
        final dates = _getDateRangeFromPeriod(state.selectedPeriod);
        startDate = dates['start'];
        endDate = dates['end'];
      } else if (state.startDate != null && state.endDate != null) {
        startDate = _formatDate(state.startDate!);
        endDate = _formatDate(state.endDate!);
      }

      final response = await _repository.getTransactionReports(
        limit: limit,
        page: page ?? state.currentPage,
        search: state.searchQuery.isEmpty ? null : state.searchQuery,
        startDate: startDate,
        endDate: endDate,
      );

      if (response.success && response.data != null) {
        emit(state.copyWith(
          transactions: response.data!.transactions,
          summary: response.data!.summary,
          meta: response.data!.meta,
          currentPage: page ?? state.currentPage,
          isLoading: false,
        ));
      } else {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: response.message,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Terjadi kesalahan: $e',
      ));
    }
  }

  /// ===== NEW METHOD FOR CASHIER =====
  /// Load cashier transactions (hanya transaksi kasir yang login)
  Future<void> loadCashierTransactions({
    int? page,
    int limit = 999999999,
  }) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      // Tentukan date range berdasarkan period
      String? startDate;
      String? endDate;

      if (state.selectedPeriod != ReportPeriod.custom) {
        final dates = _getDateRangeFromPeriod(state.selectedPeriod);
        startDate = dates['start'];
        endDate = dates['end'];
      } else if (state.startDate != null && state.endDate != null) {
        startDate = _formatDate(state.startDate!);
        endDate = _formatDate(state.endDate!);
      }

      final response = await _repository.getCashierTransactionReports(
        limit: limit,
        page: page ?? state.currentPage,
        search: state.searchQuery.isEmpty ? null : state.searchQuery,
        startDate: startDate,
        endDate: endDate,
      );

      if (response.success && response.data != null) {
        emit(state.copyWith(
          transactions: response.data!.transactions,
          summary: response.data!.summary,
          meta: response.data!.meta,
          currentPage: page ?? state.currentPage,
          isLoading: false,
        ));
      } else {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: response.message,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Terjadi kesalahan: $e',
      ));
    }
  }

  /// Set period dan auto reload
  Future<void> setPeriod(ReportPeriod period, {bool isCashier = false}) async {
    emit(state.copyWith(
      selectedPeriod: period,
      currentPage: 1,
      clearDates: period != ReportPeriod.custom,
    ));

    if (isCashier) {
      await loadCashierTransactions();
    } else {
      await loadTransactions();
    }
  }

  /// Set custom date range
  Future<void> setDateRange(DateTime? start, DateTime? end, {bool isCashier = false}) async {
    if (start == null && end == null) {
      emit(state.copyWith(
        selectedPeriod: ReportPeriod.today,
        clearDates: true,
        currentPage: 1,
      ));
    } else {
      emit(state.copyWith(
        selectedPeriod: ReportPeriod.custom,
        startDate: start,
        endDate: end,
        currentPage: 1,
      ));
    }

    if (isCashier) {
      await loadCashierTransactions();
    } else {
      await loadTransactions();
    }
  }

  /// Set search query
  Future<void> setSearchQuery(String query, {bool isCashier = false}) async {
    emit(state.copyWith(
      searchQuery: query,
      currentPage: 1,
    ));

    if (isCashier) {
      await loadCashierTransactions();
    } else {
      await loadTransactions();
    }
  }

  /// Load next page
  Future<void> loadNextPage({bool isCashier = false}) async {
    if (state.meta != null && state.currentPage < state.meta!.lastPage) {
      if (isCashier) {
        await loadCashierTransactions(page: state.currentPage + 1);
      } else {
        await loadTransactions(page: state.currentPage + 1);
      }
    }
  }

  /// Load previous page
  Future<void> loadPreviousPage({bool isCashier = false}) async {
    if (state.currentPage > 1) {
      if (isCashier) {
        await loadCashierTransactions(page: state.currentPage - 1);
      } else {
        await loadTransactions(page: state.currentPage - 1);
      }
    }
  }

  /// Refresh data
  Future<void> refresh({bool isCashier = false}) async {
    emit(state.copyWith(currentPage: 1));

    if (isCashier) {
      await loadCashierTransactions();
    } else {
      await loadTransactions();
    }
  }

  /// Helper: Get date range dari period
  Map<String, String> _getDateRangeFromPeriod(ReportPeriod period) {
    final now = DateTime.now();
    DateTime start;
    DateTime end;

    switch (period) {
      case ReportPeriod.today:
        start = DateTime(now.year, now.month, now.day);
        end = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;

      case ReportPeriod.week:
        start = now.subtract(const Duration(days: 7));
        end = now;
        break;

      case ReportPeriod.month:
        start = DateTime(now.year, now.month, 1);
        end = DateTime(now.year, now.month + 1, 0);
        break;

      case ReportPeriod.year:
        start = DateTime(now.year, 1, 1);
        end = DateTime(now.year, 12, 31);
        break;

      case ReportPeriod.custom:
        return {};
    }

    return {
      'start': _formatDate(start),
      'end': _formatDate(end),
    };
  }

  /// Helper: Format date ke YYYY-MM-DD
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}