// lib/core/cubit/transaction/transaction_cubit.dart

import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/customer_model.dart';
import '../../data/models/product_model.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/payment_method_model.dart' as pm;
import '../../data/repositories/transaction_repository.dart';
import '../history_stock/stock_bloc.dart';
import '../history_stock/stock_event.dart';
import 'transaction_state.dart';

class TransactionCubit extends Cubit<TransactionState> {
  final StockBloc? stockBloc;
  final TransactionRepository _repository;

  TransactionCubit({
    required TransactionRepository repository,
    this.stockBloc,
  })  : _repository = repository,
        super(const TransactionState());

  void loadProducts(List<ProductModel> products) {
    emit(state.copyWith(availableProducts: products));
  }

  void loadPaymentMethods(List<pm.PaymentMethod> paymentMethods) {
    emit(state.copyWith(availablePaymentMethods: paymentMethods));
  }

  void addProduct(ProductModel product) {
    final updated = Map<String, int>.from(state.productQuantities);
    updated[product.id.toString()] = (updated[product.id] ?? 0) + 1;
    emit(state.copyWith(productQuantities: updated));
  }

  void addQuantity(ProductModel product) {
    final current = state.productQuantities[product.id] ?? 0;
    final stock = product.productStock;
    if (current < stock) {
      final updated = Map<String, int>.from(state.productQuantities)
        ..[product.id.toString()] = current + 1;
      emit(state.copyWith(productQuantities: updated));
    }
  }

  void removeQuantity(ProductModel product) {
    final current = state.productQuantities[product.id] ?? 0;
    if (current > 0) {
      final updated = Map<String, int>.from(state.productQuantities);
      if (current == 1) {
        updated.remove(product.id);
      } else {
        updated[product.id.toString()] = current - 1;
      }
      emit(state.copyWith(productQuantities: updated));
    }
  }

  void setReceivedAmount(int? amount) {
    emit(state.copyWith(receivedAmount: amount));
  }

  void setPaymentMethod(PaymentMethod method) {
    emit(state.copyWith(
      paymentMethod: method,
      clearPaymentMethodDetail: true,
    ));
  }

  void setPaymentMethodWithDetail(PaymentMethod method, pm.PaymentMethod? detail) {
    emit(state.copyWith(
      paymentMethod: method,
      selectedPaymentMethodDetail: detail,
    ));
  }

  void completeDigitalPayment(PaymentMethod method) {
    emit(state.copyWith(
      transactionDate: DateTime.now(),
      paymentMethod: method,
      receivedAmount: state.finalTotal,
    ));
  }

  void completeCashPayment() {
    emit(state.copyWith(
      transactionDate: DateTime.now(),
      paymentMethod: PaymentMethod.cash,
    ));
  }

  void completeTransaction() {
    if (state.paymentMethod.isDigitalPayment) {
      completeDigitalPayment(state.paymentMethod);
    } else if (state.paymentMethod == PaymentMethod.cash) {
      completeCashPayment();
    }
  }

  void toggleSelectionMode() {
    emit(state.copyWith(
      isSelectionMode: !state.isSelectionMode,
      selectedProductIds: {},
    ));
  }

  void toggleProductSelection(String productId) {
    final updated = Set<String>.from(state.selectedProductIds);
    if (updated.contains(productId)) {
      updated.remove(productId);
    } else {
      updated.add(productId);
    }
    emit(state.copyWith(selectedProductIds: updated));
  }

  void selectAllProducts() {
    final allIds = state.selectedItems
        .map((p) => p.id.toString())
        .toSet();
    emit(state.copyWith(selectedProductIds: allIds));
  }

  void clearSelection() {
    emit(state.copyWith(
      selectedProductIds: {},
      isSelectionMode: false,
    ));
  }

  void deleteSelectedProducts() {
    final updated = Map<String, int>.from(state.productQuantities);
    for (var productId in state.selectedProductIds) {
      updated.remove(productId);
    }
    emit(state.copyWith(
      productQuantities: updated,
      selectedProductIds: {},
      isSelectionMode: false,
    ));
  }

  // TransactionModel getCurrentTransaction() {
  //   final transactionId = 'TRX${DateTime.now().millisecondsSinceEpoch}';
  //
  //   final items = state.selectedItems.map((product) {
  //     final qty = state.getQuantity(product.id.toString());
  //     final priceAfterDiscount = product.sellingPrice * (1 - product.productDiscount !/ 100);
  //     final totalPrice = (priceAfterDiscount * qty).toInt();
  //     final profitPerItem = priceAfterDiscount - product.costPrice;
  //     final totalProfit = (profitPerItem * qty).toInt();
  //
  //     return TransactionItem(
  //       productId: product.id.toString(),
  //       productName: product.productName,
  //       quantity: qty,
  //       basePrice: product.costPrice,
  //       sellingPrice: product.sellingPrice,
  //       totalPrice: totalPrice,
  //       totalProfit: totalProfit,
  //       discount: product.productDiscount,
  //     );
  //   }).toList();
  //
  //   final totalProfit = state.netProfit;
  //
  //   String paymentMethodName = state.paymentMethod.displayName;
  //   if (state.selectedPaymentMethodDetail != null) {
  //     paymentMethodName = state.selectedPaymentMethodDetail!.name;
  //   }
  //
  //   return TransactionModel(
  //     id: transactionId,
  //     transactionDate: state.transactionDate ?? DateTime.now(),
  //     items: items,
  //     subtotal: state.subtotal,
  //     discount: state.discount,
  //     otherCosts: state.otherCosts,
  //     totalPayment: state.finalTotal,
  //     totalProfit: totalProfit,
  //     receivedAmount: state.receivedAmount ?? 0,
  //     changeAmount: state.changeAmount,
  //     paymentMethod: paymentMethodName,
  //     customer: state.selectedCustomer,
  //   );
  // }

  Future<void> completeAndSaveTransaction() async {
    try {
      emit(state.copyWith(isLoading: true, clearError: true));

      // Prepare details untuk API
      final details = state.selectedItems.map((product) {
        final qty = state.getQuantity(product.id.toString());
        final priceAfterDiscount = product.sellingPrice * (1 - product.productDiscount !/ 100);
        final subtotal = (priceAfterDiscount * qty);

        return {
          'product_id': product.id,
          'quantity': qty,
          'selling_price': product.sellingPrice,
          'cost_price': product.costPrice,
          'discount': product.productDiscount,
          'subtotal': subtotal,
        };
      }).toList();

      // Call API
      final response = await _repository.createTransaction(
        transactionDate: state.transactionDate ?? DateTime.now(),
        subtotal: state.subtotal,
        transactionDiscount: state.discount,
        transactionTax: 0, // Sesuaikan jika ada tax
        totalTransaction: state.finalTotal,
        nameOtherCost: state.otherCostsName.isEmpty ? null : state.otherCostsName,
        otherCost: state.otherCosts,
        totalPayment: state.receivedAmount ?? state.finalTotal,
        changeAmount: state.changeAmount,
        transactionDescription: state.notes.isEmpty ? null : state.notes,
        totalProfit: state.netProfit,
        customerId: state.selectedCustomer?.id,
        companyPaymentMethodId: state.selectedPaymentMethodDetail?.id ?? 1, // Default ID
        details: details,
      );

      if (response.success && response.data != null) {
        emit(state.copyWith(
          isLoading: false,
          completedTransaction: response.data,
        ));

        // Reset transaction setelah berhasil
        resetTransaction();
      } else {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: response.message,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Terjadi kesalahan: ${e.toString()}',
      ));
    }
  }

  Future<void> fetchTransactions({
    String? startDate,
    String? endDate,
    int? customerId,
    String? search,
    int page = 1,
  }) async {
    try {
      emit(state.copyWith(isLoading: true, clearError: true));

      final response = await _repository.getTransactions(
        startDate: startDate,
        endDate: endDate,
        customerId: customerId,
        search: search,
        page: page,
      );

      if (response.success) {
        // Handle success - bisa tambah field di state untuk list transactions
        emit(state.copyWith(isLoading: false));
      } else {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: response.message,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal memuat transaksi: ${e.toString()}',
      ));
    }
  }

  void clearError() {
    emit(state.copyWith(clearError: true));
  }


  // List<Map<String, dynamic>> getStockReductionData() {
  //   final transactionId = getCurrentTransaction().id;
  //   return state.selectedItems.map((item) {
  //     final quantity = state.getQuantity(item.id.toString());
  //     return {
  //       'productId': item.id,
  //       'quantity': quantity,
  //       'hasStock': item.productStock,
  //       'transactionId': transactionId,
  //     };
  //   }).where((data) => data['hasStock'] == true).toList();
  // }

  void setSelectedCustomer(Customer? customer) {
    emit(state.copyWith(selectedCustomer: customer));
  }

  void clearSelectedCustomer() {
    emit(state.copyWith(clearCustomer: true));
  }

  void resetTransaction() {
    emit(TransactionState(
      availableProducts: state.availableProducts,
      availablePaymentMethods: state.availablePaymentMethods,
    ));
  }

  void setSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  void clearSearch() {
    emit(state.copyWith(searchQuery: ''));
  }

  void setDiscountAmount(int amount) {
    if (amount < 0) return;
    final maxAllowed = state.maxDiscount;
    final adjusted = amount > maxAllowed ? maxAllowed : amount;
    emit(state.copyWith(discount: adjusted));
  }

  void setDiscountPercent(int percent) {
    if (percent < 0) return;
    if (percent > 100) percent = 100;
    final discountAmount = (state.totalGrossProfit * percent / 100).round();
    emit(state.copyWith(discount: discountAmount));
  }

  void clearDiscount() {
    emit(state.copyWith(discount: 0));
  }

  void setOtherCosts({required int amount, required String name}) {
    emit(state.copyWith(
      otherCosts: amount,
      otherCostsName: name,
    ));
  }

  void clearOtherCosts() {
    emit(state.copyWith(
      otherCosts: 0,
      otherCostsName: '',
    ));
  }

  void setNotes(String notes) {
    emit(state.copyWith(notes: notes));
  }
}