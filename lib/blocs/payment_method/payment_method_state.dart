// blocs/payment_method/payment_method_state.dart
import 'package:equatable/equatable.dart';
import '../../data/models/payment_method_model.dart';

abstract class PaymentMethodState extends Equatable {
  const PaymentMethodState();

  @override
  List<Object?> get props => [];
}

class PaymentMethodInitial extends PaymentMethodState {}

class PaymentMethodLoading extends PaymentMethodState {}

class PaymentMethodLoaded extends PaymentMethodState {
  final List<PaymentMethod> paymentMethods;

  const PaymentMethodLoaded({required this.paymentMethods});

  // Filter by type
  List<PaymentMethod> get qrisMethods =>
      paymentMethods.where((p) => p.type == PaymentType.qris).toList();

  List<PaymentMethod> get ewalletMethods =>
      paymentMethods.where((p) => p.type == PaymentType.ewallet).toList();

  List<PaymentMethod> get bankMethods =>
      paymentMethods.where((p) => p.type == PaymentType.bank).toList();

  // Filter enabled methods (untuk transaksi)
  List<PaymentMethod> get enabledMethods =>
      paymentMethods.where((p) => p.isEnabled).toList();

  @override
  List<Object?> get props => [paymentMethods];
}

class PaymentMethodError extends PaymentMethodState {
  final String message;

  const PaymentMethodError(this.message);

  @override
  List<Object> get props => [message];
}

class PaymentMethodOperationSuccess extends PaymentMethodState {
  final String message;

  const PaymentMethodOperationSuccess(this.message);

  @override
  List<Object> get props => [message];
}