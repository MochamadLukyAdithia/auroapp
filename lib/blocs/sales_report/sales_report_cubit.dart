import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../data/models/transaction_model.dart';

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

class SalesReportState extends Equatable {
  final List<TransactionModel> transactions;
  final ReportPeriod selectedPeriod;
  final bool isLoading;
  final DateTime? startDate;
  final DateTime? endDate;


  const SalesReportState({
    this.transactions = const [],
    this.selectedPeriod = ReportPeriod.today,
    this.isLoading = false,
    this.startDate,
    this.endDate
  });

  // Filter transactions berdasarkan periode
  // Di SalesReportState
  List<TransactionModel> get filteredTransactions {
    var result = List<TransactionModel>.from(transactions);

    // Jika ada custom date range, filter by date
    if (startDate != null && endDate != null) {
      result = result.where((t) {
        return t.transactionDate.isAfter(startDate!.subtract(const Duration(days: 1))) &&
            t.transactionDate.isBefore(endDate!.add(const Duration(days: 1)));
      }).toList();
    } else {
      // Jika tidak, filter by period
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

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // Total penjualan
  int get totalSales {
    return filteredTransactions.fold<int>(
      0,
          (sum, t) => sum + t.totalPayment,
    );
  }

  // Total transaksi
  int get totalTransactions => filteredTransactions.length;

  // Total item terjual
  int get totalItemsSold {
    return filteredTransactions.fold<int>(
      0,
          (sum, t) => sum + t.items.fold<int>(0, (s, item) => s + item.quantity),
    );
  }

  // ✅ Total keuntungan
  int get totalProfit {
    return filteredTransactions.fold<int>(
      0,
          (sum, t) => sum + t.totalProfit,
    );
  }

  // ✅ Margin keuntungan (dalam persen)
  double get profitMargin {
    if (totalSales == 0) return 0;
    return (totalProfit / totalSales) * 100;
  }

  // Data untuk grafik (7 hari terakhir atau sesuai periode)
  Map<DateTime, int> get chartData {
    final Map<DateTime, int> data = {};
    final now = DateTime.now();

    // ✅ Jika ada custom date range
    if (startDate != null && endDate != null) {
      final daysDiff = endDate!.difference(startDate!).inDays;

      // Kalau lebih dari 31 hari, tampilkan per bulan
      if (daysDiff > 31) {
        DateTime current = DateTime(startDate!.year, startDate!.month, 1);
        final end = DateTime(endDate!.year, endDate!.month, 1);

        while (current.isBefore(end) || current.isAtSameMomentAs(end)) {
          data[current] = 0;
          current = DateTime(current.year, current.month + 1, 1);
        }

        for (var transaction in filteredTransactions) {
          final month = DateTime(
              transaction.transactionDate.year,
              transaction.transactionDate.month,
              1
          );
          data[month] = (data[month] ?? 0) + transaction.totalPayment;
        }
      }
      // Kalau 31 hari atau kurang, tampilkan per hari
      else {
        for (int i = 0; i <= daysDiff; i++) {
          final day = DateTime(
            startDate!.year,
            startDate!.month,
            startDate!.day + i,
          );
          data[day] = 0;
        }

        for (var transaction in filteredTransactions) {
          final day = DateTime(
            transaction.transactionDate.year,
            transaction.transactionDate.month,
            transaction.transactionDate.day,
          );
          if (data.containsKey(day)) {
            data[day] = (data[day] ?? 0) + transaction.totalPayment;
          }
        }
      }

      return data;
    }

    // ✅ Filter by period (existing code)
    if (selectedPeriod == ReportPeriod.today) {
      // Per jam untuk hari ini
      for (int i = 0; i < 24; i++) {
        final hour = DateTime(now.year, now.month, now.day, i);
        data[hour] = 0;
      }

      for (var transaction in filteredTransactions) {
        final hour = DateTime(
          transaction.transactionDate.year,
          transaction.transactionDate.month,
          transaction.transactionDate.day,
          transaction.transactionDate.hour,
        );
        data[hour] = (data[hour] ?? 0) + transaction.totalPayment;
      }
    } else if (selectedPeriod == ReportPeriod.week) {
      // ... existing code week
      for (int i = 6; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        final day = DateTime(date.year, date.month, date.day);
        data[day] = 0;
      }

      for (var transaction in filteredTransactions) {
        final day = DateTime(
          transaction.transactionDate.year,
          transaction.transactionDate.month,
          transaction.transactionDate.day,
        );
        data[day] = (data[day] ?? 0) + transaction.totalPayment;
      }
    } else if (selectedPeriod == ReportPeriod.month) {
      // ... existing code month
      final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
      for (int i = 1; i <= daysInMonth; i++) {
        final day = DateTime(now.year, now.month, i);
        data[day] = 0;
      }

      for (var transaction in filteredTransactions) {
        final day = DateTime(
          transaction.transactionDate.year,
          transaction.transactionDate.month,
          transaction.transactionDate.day,
        );
        data[day] = (data[day] ?? 0) + transaction.totalPayment;
      }
    } else {
      // ... existing code year
      for (int i = 1; i <= 12; i++) {
        final month = DateTime(now.year, i, 1);
        data[month] = 0;
      }

      for (var transaction in filteredTransactions) {
        final month = DateTime(
            transaction.transactionDate.year,
            transaction.transactionDate.month,
            1
        );
        data[month] = (data[month] ?? 0) + transaction.totalPayment;
      }
    }

    return data;
  }

  SalesReportState copyWith({
    List<TransactionModel>? transactions,
    ReportPeriod? selectedPeriod,
    bool? isLoading,
    DateTime? startDate,
    DateTime? endDate,
    bool clearDates = false,
  }) {
    return SalesReportState(
      transactions: transactions ?? this.transactions,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      isLoading: isLoading ?? this.isLoading,
      startDate: clearDates ? null : (startDate ?? this.startDate),
      endDate: clearDates ? null : (endDate ?? this.endDate),
    );
  }

  @override
  List<Object?> get props => [transactions, selectedPeriod, isLoading, startDate, endDate];
}

class SalesReportCubit extends Cubit<SalesReportState> {
  SalesReportCubit() : super(const SalesReportState());

  Future<void> loadTransactions() async {
    emit(state.copyWith(isLoading: true));

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTransactions = prefs.getStringList('transactions') ?? [];

      final transactions = savedTransactions
          .map((json) => TransactionModel.fromJson(jsonDecode(json)))
          .toList();

      emit(state.copyWith(
        transactions: transactions,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  void setPeriod(ReportPeriod period) {
    emit(state.copyWith(selectedPeriod: period));
  }

  void setDateRange(DateTime? start, DateTime? end) {
    if (start == null && end == null) {
      emit(state.copyWith(clearDates: true));
    } else {
      emit(state.copyWith(startDate: start, endDate: end));
    }
  }

  Future<void> clearAllTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('transactions');
    emit(state.copyWith(transactions: []));
  }
}