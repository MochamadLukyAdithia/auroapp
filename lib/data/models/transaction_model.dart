import 'package:equatable/equatable.dart';
import 'package:pos_mobile/data/models/product_model.dart';

import 'customer_model.dart';

class TransactionModel extends Equatable {
  final int id;
  final String transactionNumber;
  final DateTime transactionDate;
  final double subtotal;
  final double? transactionDiscount;
  final double transactionTax;
  final double totalTransaction;
  final String? nameOtherCost;
  final double otherCost;
  final double totalPayment;
  final double changeAmount;
  final String? transactionDescription;
  final double totalProfit;
  final Customer? customer;
  final UserModel user;
  final List<DetailTransactionModel> detailTransaction;
  final CompanyPaymentMethodModel companyPaymentMethod;

  const TransactionModel({
    required this.id,
    required this.transactionNumber,
    required this.transactionDate,
    required this.subtotal,
    required this.transactionDiscount,
    required this.transactionTax,
    required this.totalTransaction,
    this.nameOtherCost,
    required this.otherCost,
    required this.totalPayment,
    required this.changeAmount,
    this.transactionDescription,
    required this.totalProfit,
    this.customer,
    required this.user,
    required this.detailTransaction,
    required this.companyPaymentMethod,
  });

  @override
  List<Object?> get props => [
    id,
    transactionNumber,
    transactionDate,
    subtotal,
    transactionDiscount,
    transactionTax,
    totalTransaction,
    nameOtherCost,
    otherCost,
    totalPayment,
    changeAmount,
    transactionDescription,
    totalProfit,
    customer,
    user,
    detailTransaction,
    companyPaymentMethod,
  ];

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      transactionNumber: json['transaction_number'],
      transactionDate: DateTime.parse(json['transaction_date']),
      subtotal: _parseDouble(json['subtotal']),
      transactionDiscount: _parseDouble(json['transaction_discount']),
      transactionTax: _parseDouble(json['transaction_tax']),
      totalTransaction: _parseDouble(json['total_transaction']),
      nameOtherCost: json['name_other_cost'],
      otherCost: _parseDouble(json['other_cost']),
      totalPayment: _parseDouble(json['total_payment']),
      changeAmount: _parseDouble(json['change_amount']),
      transactionDescription: json['transaction_description'],
      totalProfit: _parseDouble(json['total_profit']),
      customer: json['customer'] != null
          ? Customer.fromJson(json['customer'])
          : null,
      user: UserModel.fromJson(json['user']),
      detailTransaction: (json['detail_transaction'] as List)
          .map((item) => DetailTransactionModel.fromJson(item))
          .toList(),
      companyPaymentMethod:
      CompanyPaymentMethodModel.fromJson(json['company_payment_method']),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transaction_number': transactionNumber,
      'transaction_date': transactionDate.toIso8601String(),
      'subtotal': subtotal,
      'transaction_discount': transactionDiscount,
      'transaction_tax': transactionTax,
      'total_transaction': totalTransaction,
      'name_other_cost': nameOtherCost,
      'other_cost': otherCost,
      'total_payment': totalPayment,
      'change_amount': changeAmount,
      'transaction_description': transactionDescription,
      'total_profit': totalProfit,
      'customer': customer?.toJson(),
      'user': user.toJson(),
      'detail_transaction':
      detailTransaction.map((item) => item.toJson()).toList(),
      'company_payment_method': companyPaymentMethod.toJson(),
    };
  }
}

class DetailTransactionModel extends Equatable {
  final int id;
  final int transactionId;
  final int productId;
  final int quantity;
  final double unitPrice;
  final double costPrice;
  final double discount;
  final double subtotal;
  final double itemProfit;
  final ProductModel product;

  const DetailTransactionModel({
    required this.id,
    required this.transactionId,
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    required this.costPrice,
    required this.discount,
    required this.subtotal,
    required this.itemProfit,
    required this.product,
  });

  @override
  List<Object?> get props => [
    id,
    transactionId,
    productId,
    quantity,
    unitPrice,
    costPrice,
    discount,
    subtotal,
    itemProfit,
    product,
  ];

  factory DetailTransactionModel.fromJson(Map<String, dynamic> json) {
    return DetailTransactionModel(
      id: json['id'],
      transactionId: json['transaction_id'],
      productId: json['product_id'],
      quantity: json['quantity'],
      unitPrice: _parseDouble(json['unit_price']),
      costPrice: _parseDouble(json['cost_price']),
      discount: _parseDouble(json['discount']),
      subtotal: _parseDouble(json['subtotal']),
      itemProfit: _parseDouble(json['item_profit']),
      product: ProductModel.fromJson(json['product']),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transaction_id': transactionId,
      'product_id': productId,
      'quantity': quantity,
      'unit_price': unitPrice,
      'cost_price': costPrice,
      'discount': discount,
      'subtotal': subtotal,
      'item_profit': itemProfit,
      'product': product.toJson(),
    };
  }
}

class UserModel extends Equatable {
  final int id;
  final String fullname;
  final String email;

  const UserModel({
    required this.id,
    required this.fullname,
    required this.email,
  });

  @override
  List<Object?> get props => [id, fullname, email];

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      fullname: json['full_name'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullname,
      'email': email,
    };
  }
}

class CompanyPaymentMethodModel extends Equatable {
  final int id;
  final PaymentMethodModel paymentMethod;

  const CompanyPaymentMethodModel({
    required this.id,
    required this.paymentMethod,
  });

  @override
  List<Object?> get props => [id, paymentMethod];

  factory CompanyPaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return CompanyPaymentMethodModel(
      id: json['id'],
      paymentMethod: PaymentMethodModel.fromJson(json['payment_method']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'payment_method': paymentMethod.toJson(),
    };
  }
}

class PaymentMethodModel extends Equatable {
  final int id;
  final String paymentMethodName;

  const PaymentMethodModel({
    required this.id,
    required this.paymentMethodName,
  });

  @override
  List<Object?> get props => [id, paymentMethodName];

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      id: json['id'],
      paymentMethodName: json['payment_methods_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'payment_methods_name': paymentMethodName,
    };
  }
}