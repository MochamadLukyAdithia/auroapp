// lib/blocs/stock/stock_state.dart

import 'package:equatable/equatable.dart';
import '../../data/models/stock_history_model.dart';

abstract class StockState extends Equatable {
  const StockState();

  @override
  List<Object?> get props => [];
}

class StockInitial extends StockState {
  const StockInitial();
}

class StockLoading extends StockState {
  const StockLoading();
}

class StockHistoryLoaded extends StockState {
  final List<StockHistoryModel> history;
  final int currentStock;
  final String productName;
  final String productCode;

  const StockHistoryLoaded({
    required this.history,
    required this.currentStock,
    required this.productName,
    required this.productCode,
  });

  @override
  List<Object?> get props => [history, currentStock, productName, productCode];
}

class StockHistoryEmpty extends StockState {
  final String productName;

  const StockHistoryEmpty({required this.productName});

  @override
  List<Object?> get props => [productName];
}

class StockActionSuccess extends StockState {
  final String message;

  const StockActionSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class StockError extends StockState {
  final String message;

  const StockError({required this.message});

  @override
  List<Object?> get props => [message];
}