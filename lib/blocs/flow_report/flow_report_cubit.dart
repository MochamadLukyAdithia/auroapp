import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/transaction_sales_report_model.dart'; // Import TransactionReport
import '../../data/models/finance_model.dart';
import '../../data/repositories/flow_repository.dart';
import '../../data/repositories/transaction_sales_repository.dart';

enum ReportPeriod { today, week, month, year }

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
    }
  }
}

class FinancialReportState extends Equatable {
  final List<TransactionReport> transactions; // ✅ Ganti ke TransactionReport
  final List<Finance> finances;
  final ReportPeriod selectedPeriod;
  final bool isLoading;
  final String? errorMessage;
  final DateTime? startDate;
  final DateTime? endDate;

  const FinancialReportState({
    this.transactions = const [],
    this.finances = const [],
    this.selectedPeriod = ReportPeriod.today,
    this.isLoading = false,
    this.errorMessage,
    this.startDate,
    this.endDate,
  });

  // Filter transactions berdasarkan periode
  List<TransactionReport> get filteredTransactions {
    var result = List<TransactionReport>.from(transactions);

    if (startDate != null && endDate != null) {
      result = result.where((t) {
        final transactionDate = DateTime.parse(t.tanggal);
        return transactionDate.isAfter(startDate!.subtract(const Duration(days: 1))) &&
            transactionDate.isBefore(endDate!.add(const Duration(days: 1)));
      }).toList();
    } else {
      final now = DateTime.now();
      result = result.where((t) {
        final transactionDate = DateTime.parse(t.tanggal);
        switch (selectedPeriod) {
          case ReportPeriod.today:
            return _isSameDay(transactionDate, now);
          case ReportPeriod.week:
            return transactionDate.isAfter(now.subtract(const Duration(days: 7)));
          case ReportPeriod.month:
            return transactionDate.month == now.month &&
                transactionDate.year == now.year;
          case ReportPeriod.year:
            return transactionDate.year == now.year;
        }
      }).toList();

      return result..sort((a, b) {
        final dateA = DateTime.parse(a.tanggal);
        final dateB = DateTime.parse(b.tanggal);
        return dateB.compareTo(dateA);
      });
    }

    return result..sort((a, b) {
      final dateA = DateTime.parse(a.tanggal);
      final dateB = DateTime.parse(b.tanggal);
      return dateB.compareTo(dateA);

    });

  }

  // Filter finances berdasarkan periode
  List<Finance> get filteredFinances {
    var result = List<Finance>.from(finances);

    if (startDate != null && endDate != null) {
      result = result.where((f) {
        return f.date.isAfter(startDate!.subtract(const Duration(days: 1))) &&
            f.date.isBefore(endDate!.add(const Duration(days: 1)));
      }).toList();
    } else {
      final now = DateTime.now();
      result = result.where((f) {
        switch (selectedPeriod) {
          case ReportPeriod.today:
            return _isSameDay(f.date, now);
          case ReportPeriod.week:
            return f.date.isAfter(now.subtract(const Duration(days: 7)));
          case ReportPeriod.month:
            return f.date.month == now.month && f.date.year == now.year;
          case ReportPeriod.year:
            return f.date.year == now.year;
        }
      }).toList();
      return result..sort((a, b) => b.date.compareTo(a.date));
    }



    return result..sort((a, b) => b.date.compareTo(a.date));
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // Total penjualan dari transaksi (gunakan field dari TransactionReport)
  double get totalSales {
    return filteredTransactions.fold<double>(
      0,
          (sum, t) => sum + t.bayar, // ✅ Gunakan field 'bayar' dari TransactionReport
    );
  }

  // Total pemasukan lain dari finance
  double get totalIncome {
    return filteredFinances
        .where((f) => f.type == FinanceType.income)
        .fold(0.0, (sum, f) => sum + f.amount);
  }

  // Total pengeluaran dari finance
  double get totalExpense {
    return filteredFinances
        .where((f) => f.type == FinanceType.outcome)
        .fold(0.0, (sum, f) => sum + f.amount);
  }

  // ✅ Total Pemasukan = Pemasukan dari penjualan + Pemasukan lain
  double get totalRevenue {
    return totalSales + totalIncome;
  }

  // ✅ Pendapatan Neto = Total Pemasukan - Total Pengeluaran
  double get netIncome {
    return totalRevenue - totalExpense;
  }

  // Total keuntungan dari penjualan (gunakan field dari TransactionReport)
  double get totalProfit {
    return filteredTransactions.fold<double>(
      0,
          (sum, t) => sum + t.keuntungan, // ✅ Gunakan field 'keuntungan'
    );
  }

  FinancialReportState copyWith({
    List<TransactionReport>? transactions,
    List<Finance>? finances,
    ReportPeriod? selectedPeriod,
    bool? isLoading,
    String? errorMessage,
    DateTime? startDate,
    DateTime? endDate,
    bool clearDates = false,
  }) {
    return FinancialReportState(
      transactions: transactions ?? this.transactions,
      finances: finances ?? this.finances,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      startDate: clearDates ? null : (startDate ?? this.startDate),
      endDate: clearDates ? null : (endDate ?? this.endDate),
    );
  }

  @override
  List<Object?> get props => [
    transactions,
    finances,
    selectedPeriod,
    isLoading,
    errorMessage,
    startDate,
    endDate,
  ];
}

class FinancialReportCubit extends Cubit<FinancialReportState> {
  final CashFlowRepository _cashFlowRepository;
  final TransactionReportRepository _transactionReportRepository;

  FinancialReportCubit({
    required CashFlowRepository cashFlowRepository,
    required TransactionReportRepository transactionReportRepository,
  })  : _cashFlowRepository = cashFlowRepository,
        _transactionReportRepository = transactionReportRepository,
        super(const FinancialReportState());

  /// Load data dari API
  Future<void> loadData() async {
    // emit(state.copyWith(isLoading: true));

    try {
      final now = DateTime.now();
      int? month;
      int? year;
      String? startDate;
      String? endDate;

      // Set filter berdasarkan custom date range atau periode
      if (state.startDate != null && state.endDate != null) {
        startDate = state.startDate!.toIso8601String().split('T')[0];
        endDate = state.endDate!.toIso8601String().split('T')[0];
      } else {
        switch (state.selectedPeriod) {
          case ReportPeriod.today:
            startDate = now.toIso8601String().split('T')[0];
            endDate = now.toIso8601String().split('T')[0];
            month = now.month;
            year = now.year;
            break;
          case ReportPeriod.week:
            startDate = now.subtract(const Duration(days: 7)).toIso8601String().split('T')[0];
            endDate = now.toIso8601String().split('T')[0];
            month = now.month;
            year = now.year;
            break;
          case ReportPeriod.month:
            month = now.month;
            year = now.year;
            break;
          case ReportPeriod.year:
            year = now.year;
            break;
        }
      }

      // Fetch cash flow data (finances)
      final cashFlowResult = await _cashFlowRepository.getCashFlowReport(
        month: month,
        year: year,
      );

      // Fetch transaction reports
      final transactionResult = await _transactionReportRepository.getTransactionReports(
        startDate: startDate,
        endDate: endDate,
      );

      List<Finance> finances = [];
      List<TransactionReport> transactions = [];

      // Parse finances
      if (cashFlowResult.success && cashFlowResult.data != null) {
        final cashFlowData = cashFlowResult.data!;

        if (cashFlowData['cashflow'] != null) {
          for (var item in cashFlowData['cashflow']) {
            if (item['sumber'] == 'Keuangan') {
              try {
                String tanggalStr = item['tanggal'].toString().replaceAll('  ', ' ').trim();

                finances.add(Finance(
                  id: item['id'],
                  name: item['namaTransaksi'] ?? '',
                  amount: double.parse(item['nominal']?.toString() ?? '0'),
                  type: item['jenisTransaksi'] == 'Pemasukan'  // ✅ FIX TYPO
                      ? FinanceType.income
                      : FinanceType.outcome,
                  date: DateTime.parse(tanggalStr),
                  description: item['catatan'] ?? '',
                ));
              } catch (e) {
              }
            }
          }
        }
      }

      // Parse transactions
      if (transactionResult.success && transactionResult.data != null) {
        transactions = transactionResult.data!.transactions;
      }

      // ✅ EMIT DI SINI - PINDAHKAN KELUAR DARI IF BLOCK
      emit(state.copyWith(
        finances: finances,
        transactions: transactions,
      ));

    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Gagal memuat data: ${e.toString()}',
      ));
    }
  }

  void setPeriod(ReportPeriod period) {
    emit(state.copyWith(
      selectedPeriod: period,
      clearDates: true,
    ));
    loadData();
  }

  void setDateRange(DateTime? start, DateTime? end) {
    if (start == null && end == null) {
      emit(state.copyWith(clearDates: true));
    } else {
      emit(state.copyWith(startDate: start, endDate: end));
    }
    loadData();
  }
}