// lib/data/repositories/stock_repository.dart

import 'package:dio/dio.dart';
import '../models/stock_history_model.dart';
import '../models/product_model.dart';
import '../models/api_response.dart';
import 'dio.dart';

class StockRepository {
  final Dio _dio = dio();

  // ✅ GET - Fetch stock history by product ID
  Future<ApiResponse<StockHistoryResponse>> getProductLog(int productId) async {
    try {
      final response = await _dio.get('/products/$productId/log');

      if (response.data['meta']['status'] == true) {
        final data = StockHistoryResponse.fromJson(response.data['data']);
        return ApiResponse.success(
          message: response.data['meta']['message'] ?? 'Data log produk berhasil diambil',
          data: data,
        );
      } else {
        return ApiResponse.error(
          message: response.data['meta']['message'] ?? 'Gagal memuat riwayat stok',
        );
      }
    } catch (e) {
      return ApiResponse.error(
        message: 'Gagal memuat riwayat stok: ${e.toString()}',
      );
    }
  }

  // ✅ POST - Update stock (tambah/kurang)
  Future<ApiResponse<ProductModel>> updateStock({
    required int productId,
    required String mode, // 'tambah' atau 'kurang'
    required int jumlahStok,
    String? keterangan,
  }) async {
    try {
      final response = await _dio.post(
        '/products/update/$productId/stock',
        data: {
          'mode': mode,
          'jumlah_stok': jumlahStok,
          if (keterangan != null) 'keterangan': keterangan,
        },
      );

      if (response.data['success'] == true) {
        final product = ProductModel.fromJson(response.data['data']);
        return ApiResponse.success(
          message: response.data['message'] ?? 'Stok berhasil diperbarui',
          data: product,
        );
      } else {
        return ApiResponse.error(
          message: response.data['message'] ?? 'Gagal memperbarui stok',
        );
      }
    } catch (e) {
      // Handle error stok tidak cukup dari backend
      if (e is DioException && e.response?.statusCode == 400) {
        return ApiResponse.error(
          message: e.response?.data['message'] ?? 'Stok tidak mencukupi untuk dikurangi',
          code: 400,
        );
      }

      return ApiResponse.error(
        message: 'Gagal memperbarui stok: ${e.toString()}',
      );
    }
  }
}

// ✅ Response model untuk getProductLog
class StockHistoryResponse {
  final ProductBasicInfo product;
  final List<StockHistoryModel> logs;

  StockHistoryResponse({
    required this.product,
    required this.logs,
  });

  factory StockHistoryResponse.fromJson(Map<String, dynamic> json) {
    return StockHistoryResponse(
      product: ProductBasicInfo.fromJson(json['product']),
      logs: (json['logs'] as List)
          .map((e) => StockHistoryModel.fromJson(e))
          .toList(),
    );
  }
}

// ✅ Model untuk product basic info
class ProductBasicInfo {
  final int id;
  final String productName;
  final String productCode;
  final double costPrice;
  final double sellingPrice;

  ProductBasicInfo({
    required this.id,
    required this.productName,
    required this.productCode,
    required this.costPrice,
    required this.sellingPrice,
  });

  factory ProductBasicInfo.fromJson(Map<String, dynamic> json) {
    return ProductBasicInfo(
      id: json['id'] ?? 0,
      productName: json['product_name'] ?? '',
      productCode: json['product_code'] ?? '',
      costPrice: (json['cost_price'] ?? 0).toDouble(),
      sellingPrice: (json['selling_price'] ?? 0).toDouble(),
    );
  }
}