import 'package:equatable/equatable.dart';
import 'product_model.dart';
import 'customer_model.dart';

class TransactionModel extends Equatable {
  final String id;
  final DateTime transactionDate;
  final List<TransactionItem> items;
  final int subtotal;
  final int discount;
  final int otherCosts;
  final int totalPayment;
  final int totalProfit;      // ✅ Tambahkan field ini
  final int receivedAmount;
  final int changeAmount;
  final String paymentMethod;
  final Customer? customer;

  const TransactionModel({
    required this.id,
    required this.transactionDate,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.otherCosts,
    required this.totalPayment,
    required this.totalProfit,  // ✅ Required parameter
    required this.receivedAmount,
    required this.changeAmount,
    required this.paymentMethod,
    this.customer,
  });

  @override
  List<Object?> get props => [
    id,
    transactionDate,
    items,
    subtotal,
    discount,
    otherCosts,
    totalPayment,
    totalProfit,  // ✅ Tambahkan ke props
    receivedAmount,
    changeAmount,
    paymentMethod,
    customer,
  ];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transaction_date': transactionDate.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'discount': discount,
      'other_costs': otherCosts,
      'total_payment': totalPayment,
      'total_profit': totalProfit,  // ✅ Save profit
      'received_amount': receivedAmount,
      'change_amount': changeAmount,
      'payment_method': paymentMethod,
      'customer': customer?.toJson(),
    };
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      transactionDate: DateTime.parse(json['transaction_date']),
      items: (json['items'] as List)
          .map((item) => TransactionItem.fromJson(item))
          .toList(),
      subtotal: json['subtotal'],
      discount: json['discount'],
      otherCosts: json['other_costs'],
      totalPayment: json['total_payment'],
      totalProfit: json['total_profit'] ?? 0,  // ✅ Load profit (default 0 untuk backward compatibility)
      receivedAmount: json['received_amount'],
      changeAmount: json['change_amount'],
      paymentMethod: json['payment_method'],
      customer: json['customer'] != null
          ? Customer.fromJson(json['customer'])
          : null,
    );
  }
}

class TransactionItem extends Equatable {
  final String productId;
  final String productName;
  final int quantity;
  final double basePrice;
  final double sellingPrice;
  final int totalPrice;
  final int totalProfit;
  final double? discount;

  const TransactionItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.basePrice,
    required this.sellingPrice,
    required this.totalPrice,
    required this.totalProfit,
    this.discount
  });

  // Helper: Profit per item
  double get profitPerItem => sellingPrice - basePrice;

  @override
  List<Object?> get props => [
    productId,
    productName,
    quantity,
    basePrice,
    sellingPrice,
    totalPrice,
    totalProfit,
    discount
  ];

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'base_price': basePrice,
      'selling_price': sellingPrice,
      'total_price': totalPrice,
      'total_profit': totalProfit,
      'discount': discount
    };
  }

  factory TransactionItem.fromJson(Map<String, dynamic> json) {
    return TransactionItem(
      productId: json['product_id'],
      productName: json['product_name'],
      quantity: json['quantity'],
      basePrice: (json['base_price'] ?? 0).toDouble(),
      sellingPrice: (json['selling_price'] ?? 0).toDouble(),
      totalPrice: json['total_price'] is int
          ? json['total_price']
          : (json['total_price'] as double).toInt(),
      totalProfit: json['total_profit'] is int
          ? json['total_profit']
          : (json['total_profit'] ?? 0).toInt(),
      discount: (json['discount'] ?? 0).toDouble(),
    );
  }
}