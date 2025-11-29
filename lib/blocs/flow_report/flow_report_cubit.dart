import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../data/models/transaction_model.dart';
import '../../data/models/finance_model.dart';

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
  final List<TransactionModel> transactions;
  final List<Finance> finances;
  final ReportPeriod selectedPeriod;
  final bool isLoading;
  final DateTime? startDate;
  final DateTime? endDate;


  const FinancialReportState({
    this.transactions = const [],
    this.finances = const [],
    this.selectedPeriod = ReportPeriod.today,
    this.isLoading = false,
    this.startDate,
    this.endDate,
  });

  // Filter transactions berdasarkan periode
  List<TransactionModel> get filteredTransactions {
    var result = List<TransactionModel>.from(transactions);

    if (startDate != null && endDate != null) {
      result = result.where((t) {
        return t.transactionDate.isAfter(startDate!.subtract(const Duration(days: 1))) &&
            t.transactionDate.isBefore(endDate!.add(const Duration(days: 1)));
      }).toList();
    } else {
      final now = DateTime.now();
      result = result.where((t) {
        switch (selectedPeriod) {
          case ReportPeriod.today:
            return _isSameDay(t.transactionDate, now);
          case ReportPeriod.week:
            return t.transactionDate.isAfter(now.subtract(const Duration(days: 7)));
          case ReportPeriod.month:
            return t.transactionDate.month == now.month &&
                t.transactionDate.year == now.year;
          case ReportPeriod.year:
            return t.transactionDate.year == now.year;
        }
      }).toList();
    }

    return result..sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
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
    }

    return result..sort((a, b) => b.date.compareTo(a.date));
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // Total penjualan dari transaksi
  double get totalSales {
    return filteredTransactions.fold<double>(
      0,
          (sum, t) => sum + t.totalPayment,
    );
  }

  // Total pemasukan lain dari finance
  int get totalIncome {
    return filteredFinances
        .where((f) => f.type == FinanceType.income)
        .fold(0, (sum, f) => sum + f.amount.toInt());
  }

  // Total pengeluaran dari finance
  int get totalExpense {
    return filteredFinances
        .where((f) => f.type == FinanceType.outcome)
        .fold(0, (sum, f) => sum + f.amount.toInt());
  }

  // ✅ Total Pemasukan = Pemasukan dari penjualan + Pemasukan lain
  double get totalRevenue {
    return totalSales + totalIncome;
  }

  // ✅ Pendapatan Neto = Total Pemasukan - Total Pengeluaran
  double get netIncome {
    return totalRevenue - totalExpense;
  }

  // Total keuntungan dari penjualan
  double get totalProfit {
    return filteredTransactions.fold<double>(
      0,
          (sum, t) => sum + t.totalProfit,
    );
  }

  FinancialReportState copyWith({
    List<TransactionModel>? transactions,
    List<Finance>? finances,
    ReportPeriod? selectedPeriod,
    bool? isLoading,
    DateTime? startDate,
    DateTime? endDate,
    bool clearDates = false
  }) {
    return FinancialReportState(
      transactions: transactions ?? this.transactions,
      finances: finances ?? this.finances,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      isLoading: isLoading ?? this.isLoading,
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
    startDate,
    endDate,
  ];
}

class FinancialReportCubit extends Cubit<FinancialReportState> {
  static const String _financeKey = 'finances_data';

  FinancialReportCubit() : super(const FinancialReportState());

  Future<void> loadData() async {
    emit(state.copyWith(isLoading: true));

    try {
      final prefs = await SharedPreferences.getInstance();

      // Load transactions
      final savedTransactions = prefs.getStringList('transactions') ?? [];
      final transactions = savedTransactions
          .map((json) => TransactionModel.fromJson(jsonDecode(json)))
          .toList();

      // ✅ Load finances dengan key yang benar
      final financeJsonString = prefs.getString(_financeKey);
      List<Finance> finances = [];

      if (financeJsonString != null) {
        final jsonList = jsonDecode(financeJsonString) as List;
        finances = jsonList.map((json) => Finance.fromJson(json)).toList();
      }

      emit(state.copyWith(
        transactions: transactions,
        finances: finances,
        isLoading: false,
      ));

    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  void setPeriod(ReportPeriod period) {
    emit(state.copyWith(
      selectedPeriod: period,
      startDate: null,
      endDate: null,
    ));
  }

  void setDateRange(DateTime? start, DateTime? end) {
    if (start == null && end == null) {
      emit(state.copyWith(clearDates: true));
    } else {
      emit(state.copyWith(startDate: start, endDate: end));
    }
  }
}