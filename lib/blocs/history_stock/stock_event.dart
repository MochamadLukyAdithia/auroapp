// lib/blocs/stock/stock_event.dart

import 'package:equatable/equatable.dart';

abstract class StockEvent extends Equatable {
  const StockEvent();

  @override
  List<Object?> get props => [];
}

class LoadStockHistory extends StockEvent {
  final int productId;

  const LoadStockHistory({required this.productId});

  @override
  List<Object?> get props => [productId];
}

class AddStockIn extends StockEvent {
  final int productId;
  final int quantity;
  final String notes;

  const AddStockIn({
    required this.productId,
    required this.quantity,
    required this.notes,
  });

  @override
  List<Object?> get props => [productId, quantity, notes];
}

class AddStockOut extends StockEvent {
  final int productId;
  final int quantity;
  final String notes;


  const AddStockOut({
    required this.productId,
    required this.quantity,
    required this.notes,
  });

  @override
  List<Object?> get props => [productId, quantity, notes];
}
