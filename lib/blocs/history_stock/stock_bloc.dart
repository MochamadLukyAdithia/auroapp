// lib/blocs/stock/stock_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_mobile/data/models/product_model.dart';
import '../../data/repositories/stock_history_repository.dart';
import 'stock_event.dart';
import 'stock_state.dart';

class StockBloc extends Bloc<StockEvent, StockState> {
  final StockRepository _stockRepository;

  StockBloc(this._stockRepository) : super(const StockInitial()) {
    on<LoadStockHistory>(_onLoadStockHistory);
    on<AddStockIn>(_onAddStockIn);
    on<AddStockOut>(_onAddStockOut);
  }

  // ✅ LOAD STOCK HISTORY dari API
  Future<void> _onLoadStockHistory(
      LoadStockHistory event,
      Emitter<StockState> emit,
      ) async {
    emit(const StockLoading());

    try {
      final response = await _stockRepository.getProductLog(event.productId);

      if (response.success && response.data != null) {
        if (response.data!.logs.isEmpty) {
          emit(StockHistoryEmpty(
            productName: response.data!.product.productName,
          ));
        } else {
          // Current stock adalah final_stock dari log terakhir (index 0)
          final currentStock = response.data!.logs.first.finalStock;

          emit(StockHistoryLoaded(
            history: response.data!.logs,
            currentStock: currentStock,
            productName: response.data!.product.productName,
            productCode: response.data!.product.productCode,
          ));
        }
      } else {
        emit(StockError(message: response.message));
      }
    } catch (e) {
      emit(StockError(message: 'Gagal memuat riwayat: ${e.toString()}'));
    }
  }

  // ✅ ADD STOCK IN via API
  Future<void> _onAddStockIn(
      AddStockIn event,
      Emitter<StockState> emit,
      ) async {
    try {
      if (event.quantity <= 0) {
        emit(const StockError(message: 'Jumlah harus lebih dari 0'));
        return;
      }
      if (event.notes.trim().isEmpty) {
        emit(const StockError(message: 'Keterangan tidak boleh kosong'));
        return;
      }

      emit(const StockLoading());

      final response = await _stockRepository.updateStock(
        productId: event.productId,
        mode: 'tambah', // ✅ Backend expect 'tambah'
        jumlahStok: event.quantity,
        keterangan: event.notes.trim(),
      );

      if (response.success) {
        emit(const StockActionSuccess(message: 'Stok berhasil ditambahkan'));

        // ✅ Reload stock history
        add(LoadStockHistory(productId: event.productId));
      } else {
        emit(StockError(message: response.message));
      }
    } catch (e) {
      emit(StockError(message: 'Gagal menambah stok: ${e.toString()}'));
    }
  }

  // ✅ ADD STOCK OUT via API
  Future<void> _onAddStockOut(
      AddStockOut event,
      Emitter<StockState> emit,
      ) async {
    try {
      if (event.quantity <= 0) {
        emit(const StockError(message: 'Jumlah harus lebih dari 0'));
        return;
      }
      if (event.notes.trim().isEmpty) {
        emit(const StockError(message: 'Keterangan tidak boleh kosong'));
        return;
      }

      emit(const StockLoading());

      final response = await _stockRepository.updateStock(
        productId: event.productId,
        mode: 'kurang', // ✅ Backend expect 'kurang'
        jumlahStok: event.quantity,
        keterangan: event.notes.trim(),
      );

      if (response.success) {
        emit(const StockActionSuccess(message: 'Stok berhasil dikurangi'));

        // ✅ Reload stock history
        add(LoadStockHistory(productId: event.productId));
      } else {
        // Backend return error 400 jika stok tidak cukup
        emit(StockError(message: response.message));
      }
    } catch (e) {
      emit(StockError(message: 'Gagal mengurangi stok: ${e.toString()}'));
    }
  }
}