import 'package:equatable/equatable.dart';
import '../../data/models/finance_model.dart';

abstract class FinanceState extends Equatable {
  const FinanceState();

  @override
  List<Object?> get props => [];
}

class FinanceInitial extends FinanceState {}

class FinanceLoading extends FinanceState {}

class FinanceLoaded extends FinanceState {
  final List<Finance> finances;
  final String? searchQuery;
  final FinanceType? filterType;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? sortBy;
  final Set<String> selectedFinanceIds;
  final bool isSelectionMode;

  const FinanceLoaded({
    required this.finances,
    this.searchQuery,
    this.filterType,
    this.startDate,
    this.endDate,
    this.sortBy,
    this.selectedFinanceIds = const {},
    this.isSelectionMode = false,
  });

  FinanceLoaded copyWith({
    List<Finance>? finances,
    String? searchQuery,
    FinanceType? filterType,
    DateTime? startDate,
    DateTime? endDate,
    String? sortBy,
    Set<String>? selectedFinanceIds,
    bool? isSelectionMode,
  }) {
    return FinanceLoaded(
      finances: finances ?? this.finances,
      searchQuery: searchQuery ?? this.searchQuery,
      filterType: filterType ?? this.filterType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      sortBy: sortBy ?? this.sortBy,
      selectedFinanceIds: selectedFinanceIds ?? this.selectedFinanceIds,
      isSelectionMode: isSelectionMode ?? this.isSelectionMode,
    );
  }

  // Get filtered finances
  List<Finance> get filteredFinances {
    var result = List<Finance>.from(finances);

    // Filter by search query
    if (searchQuery != null && searchQuery!.isNotEmpty) {
      final query = searchQuery!.toLowerCase();
      result = result.where((f) {
        return f.name.toLowerCase().contains(query) ||
            (f.description?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // Filter by type
    if (filterType != null) {
      result = result.where((f) => f.type == filterType).toList();
    }

    // Filter by date range
    if (startDate != null && endDate != null) {
      result = result.where((f) {
        return f.date.isAfter(startDate!.subtract(const Duration(days: 1))) &&
            f.date.isBefore(endDate!.add(const Duration(days: 1)));
      }).toList();
    }

    // Sort
    if (sortBy != null) {
      switch (sortBy) {
        case 'date_desc':
          result.sort((a, b) => b.date.compareTo(a.date));
          break;
        case 'date_asc':
          result.sort((a, b) => a.date.compareTo(b.date));
          break;
        case 'amount_desc':
          result.sort((a, b) => b.amount.compareTo(a.amount));
          break;
        case 'amount_asc':
          result.sort((a, b) => a.amount.compareTo(b.amount));
          break;
      }
    } else {
      // Default: newest first
      result.sort((a, b) => b.date.compareTo(a.date));
    }

    return result;
  }

  // ✅ Calculate total income (sekarang double)
  double get totalIncome {
    return finances
        .where((f) => f.type == FinanceType.income)
        .fold(0.0, (sum, f) => sum + f.amount);
  }

  // ✅ Calculate total outcome (expense -> outcome)
  double get totalOutcome {
    return finances
        .where((f) => f.type == FinanceType.outcome)
        .fold(0.0, (sum, f) => sum + f.amount);
  }

  // ✅ Calculate balance
  double get balance => totalIncome - totalOutcome;

  @override
  List<Object?> get props => [
    finances,
    searchQuery,
    filterType,
    startDate,
    endDate,
    sortBy,
    selectedFinanceIds,
    isSelectionMode
  ];
}

class FinanceOperationSuccess extends FinanceState {
  final String message;

  const FinanceOperationSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class FinanceError extends FinanceState {
  final String message;

  const FinanceError(this.message);

  @override
  List<Object> get props => [message];
}