// blocs/customer/customer_event.dart
import 'package:equatable/equatable.dart';
import '../../data/models/customer_model.dart';

abstract class CustomerEvent extends Equatable {
  const CustomerEvent();

  @override
  List<Object?> get props => [];
}

// Fetch all customers with pagination
class FetchCustomers extends CustomerEvent {
  final String? searchQuery;
  final int? page;
  final int? limit;

  const FetchCustomers({
    this.searchQuery,
    this.page,
    this.limit,
  });

  @override
  List<Object?> get props => [searchQuery, page, limit];
}

// Add new customer
class AddCustomer extends CustomerEvent {
  final Customer customer;

  const AddCustomer(this.customer);

  @override
  List<Object> get props => [customer];
}

// Update customer
class UpdateCustomer extends CustomerEvent {
  final Customer customer;

  const UpdateCustomer(this.customer);

  @override
  List<Object> get props => [customer];
}

// Delete customer
class DeleteCustomer extends CustomerEvent {
  final int customerId;

  const DeleteCustomer(this.customerId);

  @override
  List<Object> get props => [customerId];
}

// Search customer
class SearchCustomer extends CustomerEvent {
  final String query;

  const SearchCustomer(this.query);

  @override
  List<Object> get props => [query];
}

// Load more customers (for pagination)
class LoadMoreCustomers extends CustomerEvent {
  const LoadMoreCustomers();
}

// Tambah event baru
class FetchCustomerById extends CustomerEvent {
  final int customerId;

  const FetchCustomerById(this.customerId);

  @override
  List<Object?> get props => [customerId];
}