import 'package:equatable/equatable.dart';
import '../../data/models/finance_model.dart';

abstract class FinanceEvent extends Equatable {
  const FinanceEvent();

  @override
  List<Object?> get props => [];
}

// Fetch all finances
class FetchFinances extends FinanceEvent {
  const FetchFinances();
}

// Add new finance
class AddFinance extends FinanceEvent {
  final Finance finance;
  const AddFinance(this.finance);
  @override
  List<Object> get props => [finance];
}

// Update finance
class UpdateFinance extends FinanceEvent {
  final Finance finance;
  const UpdateFinance(this.finance);
  @override
  List<Object> get props => [finance];
}

// Delete finance
class DeleteFinance extends FinanceEvent {
  final String financeId;
  const DeleteFinance(this.financeId);
  @override
  List<Object> get props => [financeId];
}

// Filter finances
class FilterFinances extends FinanceEvent {
  final FinanceType? type; // null = semua
  final DateTime? startDate;
  final DateTime? endDate;
  final String? sortBy; // 'date_desc', 'date_asc', 'amount_desc', 'amount_asc'

  const FilterFinances({
    this.type,
    this.startDate,
    this.endDate,
    this.sortBy,
  });

  @override
  List<Object?> get props => [type, startDate, endDate, sortBy];
}

// Search finances
class SearchFinances extends FinanceEvent {
  final String query;
  const SearchFinances(this.query);
  @override
  List<Object> get props => [query];
}

// 🆕 Toggle selection mode
class ToggleSelectionMode extends FinanceEvent {
  const ToggleSelectionMode();
}

// 🆕 Toggle finance selection
class ToggleFinanceSelection extends FinanceEvent {
  final String financeId;
  const ToggleFinanceSelection(this.financeId);
  @override
  List<Object> get props => [financeId];
}

// 🆕 Select all finances
class SelectAllFinances extends FinanceEvent {
  const SelectAllFinances();
}

// 🆕 Clear selection
class ClearSelection extends FinanceEvent {
  const ClearSelection();
}

// 🆕 Delete selected finances
class DeleteSelectedFinances extends FinanceEvent {
  const DeleteSelectedFinances();
}