import 'package:equatable/equatable.dart';
import '../../data/models/cashier_model.dart';

abstract class CashierEvent extends Equatable {
  const CashierEvent();

  @override
  List<Object?> get props => [];
}

// Fetch all cashiers
class FetchCashiers extends CashierEvent {
  final String? searchQuery;

  const FetchCashiers({this.searchQuery});

  @override
  List<Object?> get props => [searchQuery];
}

// Add new cashier
class AddCashier extends CashierEvent {
  final Cashier cashier;
  final String password;
  final String passwordConfirmation;

  const AddCashier({
    required this.cashier,
    required this.password,
    required this.passwordConfirmation,
  });

  @override
  List<Object> get props => [cashier, password, passwordConfirmation];
}

// Update cashier
class UpdateCashier extends CashierEvent {
  final Cashier cashier;
  final String? password; // Optional untuk update
  final String? passwordConfirmation; // Optional untuk update

  const UpdateCashier({
    required this.cashier,
    this.password,
    this.passwordConfirmation,
  });

  @override
  List<Object?> get props => [cashier, password, passwordConfirmation];
}

// Delete cashier
class DeleteCashier extends CashierEvent {
  final int cashierId;

  const DeleteCashier(this.cashierId);

  @override
  List<Object> get props => [cashierId];
}

// Search cashier (will trigger API call)
class SearchCashier extends CashierEvent {
  final String query;

  const SearchCashier(this.query);

  @override
  List<Object> get props => [query];
}