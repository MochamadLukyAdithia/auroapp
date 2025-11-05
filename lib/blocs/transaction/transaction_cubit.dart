import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Model produk
class Product extends Equatable {
  final String id;
  final String name;
  final int price;
  final int quantity;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    this.quantity = 0,
  });

  Product copyWith({int? quantity}) {
    return Product(
      id: id,
      name: name,
      price: price,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  List<Object?> get props => [id, name, price, quantity];
}

/// State transaksi
class TransactionState extends Equatable {
  final List<Product> products;      // Semua produk yang tersedia
  final List<Product> selectedItems; // Produk yang dipilih oleh user
  final int totalPayment;         // Total harga dari selectedItems
  final int? receivedAmount;      // Uang yang diterima dari customer

  const TransactionState({
    this.products = const [],
    this.selectedItems = const [],
    this.totalPayment = 0,
    this.receivedAmount,
  });

  TransactionState copyWith({
    List<Product>? products,
    List<Product>? selectedItems,
    int? totalPayment,
    int? receivedAmount,
  }) {
    return TransactionState(
      products: products ?? this.products,
      selectedItems: selectedItems ?? this.selectedItems,
      totalPayment: totalPayment ?? this.totalPayment,
      receivedAmount: receivedAmount ?? this.receivedAmount,
    );
  }

  @override
  List<Object?> get props => [products, selectedItems, totalPayment, receivedAmount];
}

/// Cubit untuk mengelola logika transaksi
class TransactionCubit extends Cubit<TransactionState> {
  TransactionCubit()
      : super(const TransactionState(
    products: [
      Product(id: '1', name: 'Kopi Hitam', price: 12000),
      Product(id: '2', name: 'Roti Bakar', price: 15000),
      Product(id: '3', name: 'Mie Goreng', price: 18000),
      Product(id: '4', name: 'Teh Manis', price: 10000),
    ],
  ));

  /// Menambah produk ke dalam daftar pilihan
  void addProduct(Product product) {
    final existing = state.selectedItems.any((p) => p.id == product.id);
    if (!existing) {
      final updatedList = List<Product>.from(state.selectedItems)
        ..add(product.copyWith(quantity: 1));
      _updateTotal(updatedList);
    }
  }

  /// Menambah jumlah produk tertentu
  void addQuantity(Product product) {
    final updated = state.selectedItems.map((p) {
      if (p.id == product.id) {
        return p.copyWith(quantity: p.quantity + 1);
      }
      return p;
    }).toList();
    _updateTotal(updated);
  }

  /// Mengurangi jumlah produk tertentu
  void removeQuantity(Product product) {
    final updated = state.selectedItems.map((p) {
      if (p.id == product.id && p.quantity > 1) {
        return p.copyWith(quantity: p.quantity - 1);
      }
      return p;
    }).where((p) => p.quantity > 0).toList(); // buang yang quantity=0
    _updateTotal(updated);
  }

  /// Hitung ulang total
  void _updateTotal(List<Product> updatedItems) {
    final total = updatedItems.fold<int>(
      0,
          (sum, item) => sum + (item.price * item.quantity),
    );
    emit(state.copyWith(selectedItems: updatedItems, totalPayment: total));
  }

  /// Set nominal uang yang diterima kasir (dari CashPayment)
  void setReceivedAmount(int amount) {
    emit(state.copyWith(receivedAmount: amount));
  }

  /// Selesaikan transaksi (kirim ke backend nanti)
  void completeTransaction() {
    // TODO: Tambahkan logic API post di sini (via repository)
    emit(const TransactionState());
  }
}
