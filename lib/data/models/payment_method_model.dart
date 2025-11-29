import 'package:equatable/equatable.dart';

enum PaymentType {
  cash,
  qris,
  ewallet,
  bank,
}

class PaymentMethod extends Equatable {
  final int id;
  final String name;
  final PaymentType type;
  final bool isEnabled;

  const PaymentMethod({
    required this.id,
    required this.name,
    required this.type,
    required this.isEnabled,
  });

  // ✅ From JSON (dari API)
  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'],
      name: json['payment_methods_name'],
      type: _parsePaymentType(json['type_payment_method']),
      isEnabled: json['status_payment_methods'].toString() == '1', // ✅ Handle string
    );
  }

  // ✅ To JSON (untuk update ke API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'payment_methods_name': name,
      'type_payment_method': _paymentTypeToString(type),
      'status_payment_methods': isEnabled ? 1 : 0,
    };
  }

  // ✅ Copy with
  PaymentMethod copyWith({
    int? id,
    String? name,
    PaymentType? type,
    bool? isEnabled,
  }) {
    return PaymentMethod(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  // ✅ Helper: String to PaymentType
  static PaymentType _parsePaymentType(String type) {
    switch (type.toLowerCase().replaceAll('-', '').replaceAll(' ', '')) {
      case 'cash':
        return PaymentType.cash;
      case 'qris':
        return PaymentType.qris;
      case 'ewallet':
        return PaymentType.ewallet;
      case 'banktransfer':
      case 'bank':
        return PaymentType.bank;
      default:
        return PaymentType.cash;
    }
  }

  // ✅ Helper: PaymentType to String
  static String _paymentTypeToString(PaymentType type) {
    switch (type) {
      case PaymentType.cash:
        return 'cash';
      case PaymentType.qris:
        return 'QRIS';
      case PaymentType.ewallet:
        return 'E-Wallet';
      case PaymentType.bank:
        return 'Bank Transfer';
    }
  }

  @override
  List<Object?> get props => [id, name, type, isEnabled];
}

// ✅ Response wrapper untuk grouped data
class PaymentMethodsGrouped {
  final List<PaymentMethod> cash;
  final List<PaymentMethod> qris;
  final List<PaymentMethod> ewallet;
  final List<PaymentMethod> bank;

  PaymentMethodsGrouped({
    required this.cash,
    required this.qris,
    required this.ewallet,
    required this.bank,
  });

  factory PaymentMethodsGrouped.fromJson(Map<String, dynamic> json) {
    return PaymentMethodsGrouped(
      cash: (json['cash'] as List?)
          ?.map((e) => PaymentMethod.fromJson(e))
          .toList() ??
          [],
      qris: (json['QRIS'] as List?)  // ✅ Sesuai response API
          ?.map((e) => PaymentMethod.fromJson(e))
          .toList() ??
          [],
      ewallet: (json['E-Wallet'] as List?)  // ✅ Sesuai response API
          ?.map((e) => PaymentMethod.fromJson(e))
          .toList() ??
          [],
      bank: (json['Bank Transfer'] as List?)  // ✅ Sesuai response API
          ?.map((e) => PaymentMethod.fromJson(e))
          .toList() ??
          [],
    );
  }

  List<PaymentMethod> get allMethods => [...cash, ...qris, ...ewallet, ...bank];
}