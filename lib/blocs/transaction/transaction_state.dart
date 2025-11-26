// lib/core/cubit/transaction/transaction_state.dart

import 'package:equatable/equatable.dart';
import '../../data/models/customer_model.dart';
import '../../data/models/product_model.dart';
import '../../data/models/payment_method_model.dart' as pm;

enum PaymentMethod {
  none,
  cash,
  qris,
  bankTransfer,
  ewallet,
}

extension PaymentMethodExtension on PaymentMethod {
  bool get needsAmountInput => this == PaymentMethod.cash;

  bool get isDigitalPayment =>
      this == PaymentMethod.qris ||
          this == PaymentMethod.bankTransfer ||
          this == PaymentMethod.ewallet;

  String get displayName {
    switch (this) {
      case PaymentMethod.cash:
        return 'Tunai';
      case PaymentMethod.qris:
        return 'QRIS';
      case PaymentMethod.bankTransfer:
        return 'Transfer Bank';
      case PaymentMethod.ewallet:
        return 'E-Wallet';
      case PaymentMethod.none:
        return '';
    }
  }
}

extension ProductTransactionExtension on ProductModel {
  int get transactionQuantity => 0;
  int get sellingPriceInt => sellingPrice.toInt();
}


// state
class TransactionState extends Equatable {
  final List<ProductModel> availableProducts;
  final Map<String, int> productQuantities;
  final String searchQuery;
  final int? receivedAmount;
  final int discount;
  final int otherCosts;
  final String otherCostsName;
  final DateTime? transactionDate;
  final PaymentMethod paymentMethod;
  final Customer? selectedCustomer;
  final List<pm.PaymentMethod> availablePaymentMethods;
  final pm.PaymentMethod? selectedPaymentMethodDetail;
  final String notes;
  final Set<String> selectedProductIds;
  final bool isSelectionMode;

  static const _undefined = Object();

  const TransactionState({
    this.availableProducts = const [],
    this.productQuantities = const {},
    this.searchQuery = '',
    this.receivedAmount,
    this.discount = 0,
    this.otherCosts = 0,
    this.otherCostsName = '',
    this.transactionDate,
    this.paymentMethod = PaymentMethod.none,
    this.selectedCustomer,
    this.availablePaymentMethods = const [],
    this.selectedPaymentMethodDetail,
    this.notes = '',
    this.selectedProductIds = const {},
    this.isSelectionMode = false,
  });

  List<ProductModel> get selectedItems =>
      availableProducts.where((p) => (productQuantities[p.id] ?? 0) > 0).toList();

  int getQuantity(String productId) => productQuantities[productId] ?? 0;

  // int get totalPayment => availableProducts.fold(0, (sum, product) {
  //   final qty = productQuantities[product.id] ?? 0;
  //   final priceAfterDiscount = product.sellingPrice * (1 - product.discount / 100);
  //   return sum + (priceAfterDiscount * qty).toInt();
  // });
  //
  // int get subtotal => totalPayment;
  //
  // int get finalTotal {
  //   final total = totalPayment - discount + otherCosts;
  //   return total < 0 ? 0 : total;
  // }

  int get totalBasePrice => availableProducts.fold(0, (sum, product) {
    final qty = productQuantities[product.id] ?? 0;
    return sum + (product.costPrice * qty).toInt();
  });

  int get subtotal => availableProducts.fold(0, (sum, product) {
    final qty = productQuantities[product.id] ?? 0;
    return sum + (product.sellingPrice * qty).toInt();
  });

  int get totalAfterProductDiscount => availableProducts.fold(0, (sum, product) {
    final qty = productQuantities[product.id] ?? 0;
    final priceAfterDiscount = product.sellingPrice * (1 - product.productDiscount !/ 100);
    return sum + (priceAfterDiscount * qty).toInt();
  });

  int get totalGrossProfit => totalAfterProductDiscount - totalBasePrice;

  int get maxDiscount => totalGrossProfit > 0 ? totalGrossProfit : 0;

  int get validatedDiscount {
    if (discount > maxDiscount) return maxDiscount;
    return discount;
  }

  int get finalTotal {
    final remainingProfit = totalGrossProfit - validatedDiscount;
    final total = totalBasePrice + remainingProfit + otherCosts;
    return total < 0 ? 0 : total;
  }

  int get netProfit {
    final profit = totalGrossProfit - validatedDiscount;
    return profit < 0 ? 0 : profit;
  }

  int get totalPayment => totalAfterProductDiscount;

  bool get isPaymentSufficient {
    if (paymentMethod.isDigitalPayment) return true;
    if (paymentMethod == PaymentMethod.cash) {
      return receivedAmount != null && receivedAmount! >= finalTotal;
    }
    return false;
  }

  int get changeAmount {
    if (paymentMethod == PaymentMethod.cash && isPaymentSufficient) {
      return receivedAmount! - finalTotal;
    }
    return 0;
  }

  List<ProductModel> get filteredProducts {
    if (searchQuery.isEmpty) return availableProducts;
    final query = searchQuery.toLowerCase();
    return availableProducts
        .where((p) =>
    p.productName.toLowerCase().contains(query) ||
        p.productCode.toLowerCase().contains(query))
        .toList();
  }

  List<ProductModel> get availableProductsWithStock {
    return availableProducts.where((product) {
      return product.productStock > 0;
    }).toList();
  }

  List<ProductModel> get filteredProductsWithStock {
    var products = availableProductsWithStock;
    if (searchQuery.isEmpty) return products;
    final query = searchQuery.toLowerCase();
    return products
        .where((p) =>
    p.productName.toLowerCase().contains(query) ||
        p.productCode.toLowerCase().contains(query))
        .toList();
  }

  List<pm.PaymentMethod> get enabledPaymentMethods =>
      availablePaymentMethods.where((p) => p.isEnabled).toList();

  List<pm.PaymentMethod> get enabledQRIS =>
      enabledPaymentMethods.where((p) => p.type == pm.PaymentType.qris).toList();

  List<pm.PaymentMethod> get enabledEwallet =>
      enabledPaymentMethods.where((p) => p.type == pm.PaymentType.ewallet).toList();

  List<pm.PaymentMethod> get enabledBank =>
      enabledPaymentMethods.where((p) => p.type == pm.PaymentType.bank).toList();

  TransactionState copyWith({
    List<ProductModel>? availableProducts,
    Map<String, int>? productQuantities,
    String? searchQuery,
    Object? receivedAmount = _undefined,
    bool clearReceivedAmount = false,
    int? discount,
    int? otherCosts,
    String? otherCostsName,
    DateTime? transactionDate,
    PaymentMethod? paymentMethod,
    Customer? selectedCustomer,
    bool clearCustomer = false,
    List<pm.PaymentMethod>? availablePaymentMethods,
    pm.PaymentMethod? selectedPaymentMethodDetail,
    bool clearPaymentMethodDetail = false,
    String? notes,
    Set<String>? selectedProductIds,
    bool? isSelectionMode,
  }) {
    return TransactionState(
      availableProducts: availableProducts ?? this.availableProducts,
      productQuantities: productQuantities ?? this.productQuantities,
      searchQuery: searchQuery ?? this.searchQuery,
      receivedAmount: receivedAmount == _undefined
          ? this.receivedAmount
          : receivedAmount as int?,
      discount: discount ?? this.discount,
      otherCosts: otherCosts ?? this.otherCosts,
      otherCostsName: otherCostsName ?? this.otherCostsName,
      transactionDate: transactionDate ?? this.transactionDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      selectedCustomer:
      clearCustomer ? null : (selectedCustomer ?? this.selectedCustomer),
      availablePaymentMethods:
      availablePaymentMethods ?? this.availablePaymentMethods,
      selectedPaymentMethodDetail: clearPaymentMethodDetail
          ? null
          : (selectedPaymentMethodDetail ?? this.selectedPaymentMethodDetail),
      notes: notes ?? this.notes,
      selectedProductIds: selectedProductIds ?? this.selectedProductIds,
      isSelectionMode: isSelectionMode ?? this.isSelectionMode,
    );
  }

  @override
  List<Object?> get props => [
    availableProducts,
    productQuantities,
    searchQuery,
    receivedAmount,
    discount,
    otherCosts,
    otherCostsName,
    transactionDate,
    paymentMethod,
    selectedCustomer,
    availablePaymentMethods,
    selectedPaymentMethodDetail,
    notes,
    selectedProductIds,
    isSelectionMode,
  ];
}