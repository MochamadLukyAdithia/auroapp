// lib/core/cubit/transaction/transaction_state.dart

import 'package:equatable/equatable.dart';
import '../../data/models/customer_model.dart';
import '../../data/models/product_model.dart';
import '../../data/models/payment_method_model.dart' as pm;
import '../../data/models/transaction_model.dart';


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
  final Customer? selectedCustomer;
  final List<pm.PaymentMethod> availablePaymentMethods;
  final pm.PaymentMethod? selectedPaymentMethod;
  final String notes;
  final Set<String> selectedProductIds;
  final bool isSelectionMode;
  final bool isLoading;
  final String? errorMessage;
  final TransactionModel? completedTransaction;
  final bool shouldReloadProducts;

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
    this.selectedCustomer,
    this.availablePaymentMethods = const [],
    this.selectedPaymentMethod,
    this.notes = '',
    this.selectedProductIds = const {},
    this.isSelectionMode = false,
    this.isLoading = false,
    this.errorMessage,
    this.completedTransaction,
    this.shouldReloadProducts = false,
  });

  List<ProductModel> get selectedItems =>
      availableProducts.where((p) => (productQuantities[p.id.toString()] ?? 0) > 0).toList();

  int getQuantity(String productId) => productQuantities[productId] ?? 0;

  int get totalBasePrice => availableProducts.fold(0, (sum, product) {
    final qty = productQuantities[product.id.toString()] ?? 0;
    return sum + (product.costPrice * qty).toInt();
  });

  // int get subtotal => availableProducts.fold(0, (sum, product) {
  //   final qty = productQuantities[product.id.toString()] ?? 0;
  //   return sum + (product.sellingPrice * qty).toInt();
  // });

  int get subtotal => totalAfterProductDiscount;

  int get totalAfterProductDiscount => availableProducts.fold(0, (sum, product) {
    final qty = productQuantities[product.id.toString()] ?? 0;
    final priceAfterDiscount = product.sellingPrice * (1 - product.productDiscount !/ 100);
    return sum + (priceAfterDiscount * qty).toInt();
  });

  int get totalGrossProfit => totalAfterProductDiscount - totalBasePrice;

  // ✅ FIXED: Diskon boleh sampai harga jual (tidak dibatasi profit saja)
  int get maxDiscount => totalAfterProductDiscount;

  // ✅ FIXED: Diskon langsung dipakai tanpa validasi ketat
  int get validatedDiscount => discount;

  // ✅ FIXED: Rumus finalTotal yang benar
  int get finalTotal {
    final total = totalAfterProductDiscount - discount + otherCosts;
    return total < 0 ? 0 : total;
  }

  // ✅ FIXED: netProfit dihitung dari profit dikurangi diskon
  int get netProfit {
    final profit = totalGrossProfit - discount;
    return profit < 0 ? 0 : profit;
  }

  int get totalPayment => totalAfterProductDiscount;

  bool get isPaymentSufficient {
    if (selectedPaymentMethod == null) return false;
    // Kalau Cash, cek uang diterima
    if (selectedPaymentMethod!.type == pm.PaymentType.cash) {
      return receivedAmount != null && receivedAmount! >= finalTotal;
    }
    // Kalau digital payment (QRIS, eWallet, Bank), langsung true
    return true;
  }

  int get changeAmount {
    if (selectedPaymentMethod?.type == pm.PaymentType.cash && isPaymentSufficient) {
      return receivedAmount! - finalTotal;
    }
    return 0;
  }

  bool get isPaymentSelected => selectedPaymentMethod != null;

  bool get isCashPayment => selectedPaymentMethod?.type == pm.PaymentType.cash;

  bool get isDigitalPayment =>
      selectedPaymentMethod != null &&
          selectedPaymentMethod!.type != pm.PaymentType.cash;

  String get paymentMethodName => selectedPaymentMethod?.name ?? 'Belum dipilih';

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
      return product.productStock !> 0;
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
    Customer? selectedCustomer,
    bool clearCustomer = false,
    List<pm.PaymentMethod>? availablePaymentMethods,
    pm.PaymentMethod? selectedPaymentMethod,
    bool clearPaymentMethod = false,
    String? notes,
    Set<String>? selectedProductIds,
    bool? isSelectionMode,
    bool? isLoading,
    String? errorMessage,
    TransactionModel? completedTransaction,
    bool clearError = false,
    bool clearCompletedTransaction = false,
    bool? shouldReloadProducts,
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
      selectedCustomer:
      clearCustomer ? null : (selectedCustomer ?? this.selectedCustomer),
      availablePaymentMethods:
      availablePaymentMethods ?? this.availablePaymentMethods,
      selectedPaymentMethod: clearPaymentMethod
          ? null
          : (selectedPaymentMethod ?? this.selectedPaymentMethod),
      notes: notes ?? this.notes,
      selectedProductIds: selectedProductIds ?? this.selectedProductIds,
      isSelectionMode: isSelectionMode ?? this.isSelectionMode,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      completedTransaction: clearCompletedTransaction
          ? null
          : (completedTransaction ?? this.completedTransaction),
      shouldReloadProducts: shouldReloadProducts ?? this.shouldReloadProducts,
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
    selectedCustomer,
    availablePaymentMethods,
    selectedPaymentMethod,
    notes,
    selectedProductIds,
    isSelectionMode,
    isLoading,
    errorMessage,
    completedTransaction,
    shouldReloadProducts,
  ];
}