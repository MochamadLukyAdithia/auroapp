// data/models/payment_method_model.dart
import 'package:equatable/equatable.dart';

enum PaymentType {
  qris,
  ewallet,
  bank,
}

enum EwalletProvider {
  gopay,
  ovo,
  shopeepay,
  dana,
}

enum BankProvider {
  mandiri,
  bca,
  bri,
  bni,
}

class PaymentMethod extends Equatable {
  final String id;
  final PaymentType type;
  final String name;
  final bool isEnabled;
  final String? provider; // untuk ewallet: 'gopay', 'ovo', dll | bank: 'mandiri', 'bca', dll
  // final String? accountNumber; // untuk bank/ewallet (opsional)
  // final String? accountName; // untuk bank (opsional)

  const PaymentMethod({
    required this.id,
    required this.type,
    required this.name,
    required this.isEnabled,
    this.provider,
    // this.accountNumber,
    // this.accountName,
  });

  PaymentMethod copyWith({
    String? id,
    PaymentType? type,
    String? name,
    bool? isEnabled,
    String? provider,
    String? accountNumber,
    String? accountName,
  }) {
    return PaymentMethod(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      isEnabled: isEnabled ?? this.isEnabled,
      provider: provider ?? this.provider,
      // accountNumber: accountNumber ?? this.accountNumber,
      // accountName: accountName ?? this.accountName,
    );
  }

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'] as String,
      type: PaymentType.values.firstWhere(
            (e) => e.name == json['type'],
        orElse: () => PaymentType.qris,
      ),
      name: json['name'] as String,
      isEnabled: json['is_enabled'] as bool? ?? false,
      provider: json['provider'] as String?,
      // accountNumber: json['account_number'] as String?,
      // accountName: json['account_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'name': name,
      'is_enabled': isEnabled,
      if (provider != null) 'provider': provider,
      // if (accountNumber != null) 'account_number': accountNumber,
      // if (accountName != null) 'account_name': accountName,
    };
  }

  @override
  List<Object?> get props => [
    id,
    type,
    name,
    isEnabled,
    provider,
    // accountNumber,
    // accountName,
  ];
}