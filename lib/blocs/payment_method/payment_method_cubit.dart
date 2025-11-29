import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/payment_method_repository.dart';
import '../../data/models/payment_method_model.dart';
import 'payment_method_state.dart';

class PaymentMethodCubit extends Cubit<PaymentMethodState> {
  final PaymentMethodRepository _repository;

  PaymentMethodCubit(this._repository) : super(PaymentMethodInitial());

  List<PaymentMethod> _paymentMethods = [];

  List<PaymentMethod> get paymentMethods => List.unmodifiable(_paymentMethods);

  Future<void> loadPaymentMethods() async {
    emit(PaymentMethodLoading());

    try {
      final response = await _repository.getPaymentMethods();

      if (response.success && response.data != null) {
        // Flatten grouped data ke single list
        _paymentMethods = response.data!.allMethods;

        emit(PaymentMethodLoaded(paymentMethods: _paymentMethods));
      } else {
        emit(PaymentMethodError(response.message));
      }
    } catch (e) {
      emit(PaymentMethodError('Gagal memuat metode pembayaran: ${e.toString()}'));
    }
  }

  Future<void> togglePaymentMethod(int id) async {
    // Find current payment method
    final index = _paymentMethods.indexWhere((p) => p.id == id);
    if (index == -1) {
      emit(const PaymentMethodError('Metode pembayaran tidak ditemukan'));
      return;
    }

    final current = _paymentMethods[index];
    final newStatus = !current.isEnabled;

    // Store original state untuk rollback jika gagal
    final originalMethod = current;

    try {
      // ✅ Optimistic update - update UI dulu
      _paymentMethods[index] = current.copyWith(isEnabled: newStatus);
      emit(PaymentMethodLoaded(paymentMethods: _paymentMethods));

      // Update ke API
      final response = await _repository.updatePaymentMethodStatus(
        paymentMethodId: id,
        isEnabled: newStatus,
      );

      if (response.success) {
        // ✅ Emit success message
        emit(PaymentMethodOperationSuccess(
          '${current.name} ${newStatus ? "diaktifkan" : "dinonaktifkan"}',
        ));
        // ✅ Re-emit loaded state agar UI tetap menampilkan data
        emit(PaymentMethodLoaded(paymentMethods: _paymentMethods));
      } else {
        // ✅ Rollback jika API gagal
        _paymentMethods[index] = originalMethod;
        emit(PaymentMethodError(response.message));
        emit(PaymentMethodLoaded(paymentMethods: _paymentMethods));
      }
    } catch (e) {
      // ✅ Rollback jika error
      _paymentMethods[index] = originalMethod;
      emit(PaymentMethodError('Gagal mengubah status: ${e.toString()}'));
      emit(PaymentMethodLoaded(paymentMethods: _paymentMethods));
    }
  }

  // ✅ Get Enabled Payment Methods
  List<PaymentMethod> getEnabledPaymentMethods() {
    return _paymentMethods.where((p) => p.isEnabled).toList();
  }

  // ✅ Get Payment Methods By Type
  List<PaymentMethod> getPaymentMethodsByType(PaymentType type) {
    return _paymentMethods.where((p) => p.type == type).toList();
  }
}