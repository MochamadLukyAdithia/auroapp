import 'package:equatable/equatable.dart';
import '../../data/models/cashier_model.dart';

abstract class CashierState extends Equatable {
  const CashierState();

  @override
  List<Object?> get props => [];
}

// Initial state
class CashierInitial extends CashierState {}

// Loading state
class CashierLoading extends CashierState {}

// Success load cashiers
class CashierLoaded extends CashierState {
  final List<Cashier> cashiers;
  final String? searchQuery;
  final Map<String, dynamic>? pagination;
  final String? successMessage;

  const CashierLoaded({
    required this.cashiers,
    this.searchQuery,
    this.pagination,
    this.successMessage
  });

  // Get pagination info
  int get currentPage => pagination?['current_page'] ?? 1;
  int get lastPage => pagination?['last_page'] ?? 1;
  int get perPage => pagination?['per_page'] ?? 10;
  int get total => pagination?['total'] ?? 0;

  // Check if has more pages
  bool get hasMorePages => currentPage < lastPage;

  // Filtered cashiers based on search (untuk local filter jika diperlukan)
  List<Cashier> get filteredCashiers {
    if (searchQuery == null || searchQuery!.isEmpty) {
      return cashiers;
    }

    final query = searchQuery!.toLowerCase();
    return cashiers.where((cashier) {
      return cashier.fullName.toLowerCase().contains(query) ||
          cashier.phoneNumber.toLowerCase().contains(query) ||
          cashier.email.toLowerCase().contains(query);
    }).toList();
  }

  // Helper untuk display info
  String get paginationInfo {
    if (pagination == null) return '';
    return 'Showing ${cashiers.length} of $total cashiers';
  }

  @override
  List<Object?> get props => [cashiers, searchQuery, pagination, successMessage];
}

// Success operation (add/update/delete)
class CashierOperationSuccess extends CashierState {
  final String message;

  const CashierOperationSuccess(this.message);

  @override
  List<Object> get props => [message];
}

// Error state
class CashierError extends CashierState {
  final String message;

  const CashierError(this.message);

  @override
  List<Object> get props => [message];
}