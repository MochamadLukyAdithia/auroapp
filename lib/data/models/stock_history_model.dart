import 'package:equatable/equatable.dart';

class StockHistoryModel extends Equatable {
  final int? id;
  final int productId;
  final DateTime historyStockDate;
  final int initialStock;
  final int stockIn;
  final int stockOut;
  final int finalStock;
  final String? userEmail;
  final int? transactionId;
  final String? stockDescription;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const StockHistoryModel({
    this.id,
    required this.productId,
    required this.historyStockDate,
    required this.initialStock,
    required this.stockIn,
    required this.stockOut,
    required this.finalStock,
    this.userEmail,
    this.transactionId,
    this.stockDescription,
    this.createdAt,
    this.updatedAt,
  });

  // Helper getters
  StockMovementType get type {
    if (transactionId != null) return StockMovementType.sale;
    if (stockIn > 0 && stockOut == 0) return StockMovementType.stockIn;
    if (stockOut > 0 && stockIn == 0) return StockMovementType.stockOut;
    return StockMovementType.adjustment;
  }

  int get quantityChange => stockIn - stockOut;

  String get typeLabel {
    switch (type) {
      case StockMovementType.stockIn:
        return 'Stok Masuk';
      case StockMovementType.stockOut:
        return 'Stok Keluar';
      case StockMovementType.sale:
        return 'Penjualan';
      case StockMovementType.adjustment:
        return 'Penyesuaian';
    }
  }

  factory StockHistoryModel.fromJson(Map<String, dynamic> json) {
    return StockHistoryModel(
      id: json['id'] as int?,
      productId: json['product_id'] ?? 0,
      historyStockDate: json['history_stock_date'] != null
          ? DateTime.parse(json['history_stock_date'])
          : DateTime.now(),
      initialStock: json['initial_stock'] ?? 0,
      stockIn: json['stock_in'] ?? 0,
      stockOut: json['stock_out'] ?? 0,
      finalStock: json['final_stock'] ?? 0,
      userEmail: json['email'], // ✅ Dari join
      transactionId: json['transaction_id'] as int?,
      stockDescription: json['stock_description'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  StockHistoryModel copyWith({
    int? id,
    DateTime? historyStockDate,
    int? initialStock,
    int? stockIn,
    int? stockOut,
    int? finalStock,
    String? userEmail,
    int? transactionId,
    String? stockDescription,
  }) {
    return StockHistoryModel(
      id: id ?? this.id,
      historyStockDate: historyStockDate ?? this.historyStockDate,
      initialStock: initialStock ?? this.initialStock,
      stockIn: stockIn ?? this.stockIn,
      stockOut: stockOut ?? this.stockOut,
      finalStock: finalStock ?? this.finalStock,
      stockDescription: stockDescription ?? this.stockDescription,
      userEmail: userEmail ?? this.userEmail,
      transactionId: transactionId ?? this.transactionId,
      productId: productId,
    );
  }
  int get stockChange => stockIn - stockOut;

  String get stockChangeDisplay {
    if (stockIn > 0) return '+$stockIn';
    if (stockOut > 0) return '-$stockOut';
    return '0';
  }

  String get stockChangeType {
    if (stockIn > 0) return 'Masuk';
    if (stockOut > 0) return 'Keluar';
    return 'Tidak ada perubahan';
  }

  @override
  List<Object?> get props => [
    id,
    productId,
    historyStockDate,
    initialStock,
    stockIn,
    stockOut,
    finalStock,
    userEmail,
    transactionId,
    stockDescription,
    createdAt,
    updatedAt,
  ];
}

enum StockMovementType {
  stockIn,
  stockOut,
  sale,
  adjustment,
}