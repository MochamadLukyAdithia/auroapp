// blocs/customer/customer_state.dart
import 'package:equatable/equatable.dart';
import '../../data/models/customer_model.dart';

abstract class CustomerState extends Equatable {
  const CustomerState();

  @override
  List<Object?> get props => [];
}

// Initial state
class CustomerInitial extends CustomerState {}

// Loading state
class CustomerLoading extends CustomerState {}

// Success load customers
class CustomerLoaded extends CustomerState {
  final List<Customer> customers;
  final String? searchQuery;
  final int currentPage;
  final int lastPage;
  final int total;

  const CustomerLoaded({
    required this.customers,
    this.searchQuery,
    this.currentPage = 1,
    this.lastPage = 1,
    this.total = 0,
  });

  // Check if has more data
  bool get hasMore => currentPage < lastPage;

  // Check if empty
  bool get isEmpty => customers.isEmpty;

  @override
  List<Object?> get props => [
    customers,
    searchQuery,
    currentPage,
    lastPage,
    total,
  ];
}

// Success operation (add/update/delete)
class CustomerOperationSuccess extends CustomerState {
  final String message;
  final Customer? customer; // Optional: untuk show customer yang baru ditambah/diupdate

  const CustomerOperationSuccess(
      this.message, {
        this.customer,
      });

  @override
  List<Object?> get props => [message, customer];
}

// Error state
class CustomerError extends CustomerState {
  final String message;

  const CustomerError(this.message);

  @override
  List<Object> get props => [message];
}

// Tambah state baru untuk single customer
class CustomerDetailLoaded extends CustomerState {
  final Customer customer;

  const CustomerDetailLoaded(this.customer);

  @override
  List<Object?> get props => [customer];
}