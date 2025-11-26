// blocs/payment_method/payment_method_cubit.dart
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/payment_method_model.dart';
import 'payment_method_state.dart';

class PaymentMethodCubit extends Cubit<PaymentMethodState> {
  PaymentMethodCubit() : super(PaymentMethodInitial());

  List<PaymentMethod> _paymentMethods = [];

  // ======================================================
  // 🧩 Local Storage (SharedPreferences)
  // ======================================================

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _paymentMethods.map((p) => p.toJson()).toList();
    prefs.setString('payment_methods', jsonEncode(jsonList));
  }

  Future<List<PaymentMethod>> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('payment_methods');
    if (jsonString == null) return _getDefaultPaymentMethods();

    final decoded = jsonDecode(jsonString) as List;
    return decoded.map((e) => PaymentMethod.fromJson(e)).toList();
  }

  // ======================================================
  // 🧩 Default Payment Methods (FIX - tidak bisa tambah/hapus)
  // ======================================================

  List<PaymentMethod> _getDefaultPaymentMethods() {
    return [
      // QRIS
      const PaymentMethod(
        id: 'qris_1',
        type: PaymentType.qris,
        name: 'QRIS',
        isEnabled: true,
      ),

      // E-Wallet
      const PaymentMethod(
        id: 'ewallet_gopay',
        type: PaymentType.ewallet,
        name: 'GoPay',
        isEnabled: false,
        provider: 'gopay',
      ),
      const PaymentMethod(
        id: 'ewallet_ovo',
        type: PaymentType.ewallet,
        name: 'OVO',
        isEnabled: false,
        provider: 'ovo',
      ),
      const PaymentMethod(
        id: 'ewallet_shopeepay',
        type: PaymentType.ewallet,
        name: 'ShopeePay',
        isEnabled: false,
        provider: 'shopeepay',
      ),
      const PaymentMethod(
        id: 'ewallet_dana',
        type: PaymentType.ewallet,
        name: 'DANA',
        isEnabled: false,
        provider: 'dana',
      ),

      // Bank
      const PaymentMethod(
        id: 'bank_mandiri',
        type: PaymentType.bank,
        name: 'Bank Mandiri',
        isEnabled: false,
        provider: 'mandiri',
      ),
      const PaymentMethod(
        id: 'bank_bca',
        type: PaymentType.bank,
        name: 'Bank BCA',
        isEnabled: false,
        provider: 'bca',
      ),
      const PaymentMethod(
        id: 'bank_bri',
        type: PaymentType.bank,
        name: 'Bank BRI',
        isEnabled: false,
        provider: 'bri',
      ),
      const PaymentMethod(
        id: 'bank_bni',
        type: PaymentType.bank,
        name: 'Bank BNI',
        isEnabled: false,
        provider: 'bni',
      ),
    ];
  }

  // ======================================================
  // 🧩 Methods
  // ======================================================

  Future<void> loadPaymentMethods() async {
    emit(PaymentMethodLoading());
    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final loaded = await _loadFromPrefs();
      _paymentMethods = loaded;

      emit(PaymentMethodLoaded(paymentMethods: _paymentMethods));
    } catch (e) {
      emit(PaymentMethodError('Gagal memuat metode pembayaran: ${e.toString()}'));
    }
  }

  Future<void> togglePaymentMethod(String id) async {
    try {
      final index = _paymentMethods.indexWhere((p) => p.id == id);
      if (index != -1) {
        final current = _paymentMethods[index];
        _paymentMethods[index] = current.copyWith(isEnabled: !current.isEnabled);
        await _saveToPrefs();

        emit(PaymentMethodOperationSuccess(
          '${current.name} ${current.isEnabled ? "dinonaktifkan" : "diaktifkan"}',
        ));
        emit(PaymentMethodLoaded(paymentMethods: _paymentMethods));
      }
    } catch (e) {
      emit(PaymentMethodError('Gagal mengubah status: ${e.toString()}'));
      emit(PaymentMethodLoaded(paymentMethods: _paymentMethods));
    }
  }

  Future<void> updatePaymentMethodDetails({
    required String id,
    String? accountNumber,
    String? accountName,
  }) async {
    try {
      final index = _paymentMethods.indexWhere((p) => p.id == id);
      if (index != -1) {
        final current = _paymentMethods[index];
        _paymentMethods[index] = current.copyWith(
          accountNumber: accountNumber,
          accountName: accountName,
        );
        await _saveToPrefs();

        emit(const PaymentMethodOperationSuccess('Detail pembayaran berhasil diperbarui'));
        emit(PaymentMethodLoaded(paymentMethods: _paymentMethods));
      }
    } catch (e) {
      emit(PaymentMethodError('Gagal memperbarui detail: ${e.toString()}'));
      emit(PaymentMethodLoaded(paymentMethods: _paymentMethods));
    }
  }
}