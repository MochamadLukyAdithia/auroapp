class TransactionReport {
  final int id;
  final String kodeTransaksi;
  final String tanggal;
  final double totalPenjualan;
  final double totalDiskon;
  final double keuntungan;
  final double bayar;
  final double kembalian;
  final String pelanggan;
  final String teleponPelanggan;
  final String kasir;
  final String metode;
  final String? namaBiayaLain;
  final double biayaLain;

  TransactionReport({
    required this.id,
    required this.kodeTransaksi,
    required this.tanggal,
    required this.totalPenjualan,
    required this.totalDiskon,
    required this.keuntungan,
    required this.bayar,
    required this.kembalian,
    required this.pelanggan,
    required this.teleponPelanggan,
    required this.kasir,
    required this.metode,
    this.namaBiayaLain,
    required this.biayaLain,
  });

  factory TransactionReport.fromJson(Map<String, dynamic> json) {
    return TransactionReport(
      id: json['id'] ?? 0,
      kodeTransaksi: json['kodeTransaksi'] ?? '',
      tanggal: json['tanggal'] ?? '',
      totalPenjualan: _parseDouble(json['totalPenjualan']),
      totalDiskon: _parseDouble(json['totalDiskon']),
      keuntungan: _parseDouble(json['keuntungan']),
      bayar: _parseDouble(json['bayar']),
      kembalian: _parseDouble(json['kembalian']),
      pelanggan: json['pelanggan'] ?? 'Tanpa pelanggan',
      teleponPelanggan: json['teleponPelanggan'] ?? '-',
      kasir: json['kasir'] ?? '-',
      metode: json['metode'] ?? '-',
      namaBiayaLain: json['namaBiayaLain'],
      biayaLain: _parseDouble(json['biayaLain']),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kodeTransaksi': kodeTransaksi,
      'tanggal': tanggal,
      'totalPenjualan': totalPenjualan,
      'totalDiskon': totalDiskon,
      'keuntungan': keuntungan,
      'bayar': bayar,
      'kembalian': kembalian,
      'pelanggan': pelanggan,
      'teleponPelanggan': teleponPelanggan,
      'kasir': kasir,
      'metode': metode,
      'namaBiayaLain': namaBiayaLain,
      'biayaLain': biayaLain,
    };
  }
}

class TransactionReportSummary {
  final int jumlahTransaksi;
  final double jumlahPendapatan;
  final double jumlahKeuntungan;

  TransactionReportSummary({
    required this.jumlahTransaksi,
    required this.jumlahPendapatan,
    required this.jumlahKeuntungan,
  });

  factory TransactionReportSummary.fromJson(Map<String, dynamic> json) {
    return TransactionReportSummary(
      jumlahTransaksi: json['jumlahTransaksi'] ?? 0,
      jumlahPendapatan: _parseDouble(json['jumlahPendapatan']),
      jumlahKeuntungan: _parseDouble(json['jumlahKeuntungan']),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }
}

class TransactionReportResponse {
  final List<TransactionReport> transactions;
  final TransactionReportSummary summary;
  final PaginationMeta meta;

  TransactionReportResponse({
    required this.transactions,
    required this.summary,
    required this.meta,
  });

  factory TransactionReportResponse.fromJson(Map<String, dynamic> json) {
    final transactionsData = json['transactions'];

    return TransactionReportResponse(
      transactions: (transactionsData['data'] as List<dynamic>?)
          ?.map((item) => TransactionReport.fromJson(item))
          .toList() ??
          [],
      summary: TransactionReportSummary.fromJson(json['summary'] ?? {}),
      meta: PaginationMeta.fromJson(transactionsData),
    );
  }
}

class PaginationMeta {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final int from;
  final int to;

  PaginationMeta({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    required this.from,
    required this.to,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      perPage: json['per_page'] ?? 10,
      total: json['total'] ?? 0,
      from: json['from'] ?? 0,
      to: json['to'] ?? 0,
    );
  }
}

class TransactionReportDetail {
  final TransactionInfo transaction;
  final List<ProductItem> products;

  TransactionReportDetail({
    required this.transaction,
    required this.products,
  });

  factory TransactionReportDetail.fromJson(Map<String, dynamic> json) {
    return TransactionReportDetail(
      transaction: TransactionInfo.fromJson(json['transaction'] ?? {}),
      products: (json['products'] as List<dynamic>?)
          ?.map((item) => ProductItem.fromJson(item))
          .toList() ??
          [],
    );
  }
}

class TransactionInfo {
  final String kodeTransaksi;
  final String tanggal;
  final String waktu;
  final String kasir;
  final String pelanggan;
  final String metodePembayaran;
  final double totalPenjualan;
  final double diskon;
  final double bayar;
  final double kembalian;
  final String catatan;
  final double biayaLain;

  TransactionInfo({
    required this.kodeTransaksi,
    required this.tanggal,
    required this.waktu,
    required this.kasir,
    required this.pelanggan,
    required this.metodePembayaran,
    required this.totalPenjualan,
    required this.diskon,
    required this.bayar,
    required this.kembalian,
    required this.catatan,
    required this.biayaLain,
  });

  factory TransactionInfo.fromJson(Map<String, dynamic> json) {
    return TransactionInfo(
      kodeTransaksi: json['kodeTransaksi'] ?? '',
      tanggal: json['tanggal'] ?? '',
      waktu: json['waktu'] ?? '',
      kasir: json['kasir'] ?? '-',
      pelanggan: json['pelanggan'] ?? 'Tanpa pelanggan',
      metodePembayaran: json['metodePembayaran'] ?? '-',
      totalPenjualan: _parseDouble(json['totalPenjualan']),
      diskon: _parseDouble(json['diskon']),
      bayar: _parseDouble(json['bayar']),
      kembalian: _parseDouble(json['kembalian']),
      catatan: json['catatan'] ?? '-',
      biayaLain: _parseDouble(json['biayaLain']),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }
}

class ProductItem {
  final int no;
  final String namaProduk;
  final int jumlah;
  final double hargaSatuan;
  final double diskon;
  final double subtotal;

  ProductItem({
    required this.no,
    required this.namaProduk,
    required this.jumlah,
    required this.hargaSatuan,
    required this.diskon,
    required this.subtotal,
  });

  factory ProductItem.fromJson(Map<String, dynamic> json) {
    return ProductItem(
      no: json['no'] ?? 0,
      namaProduk: json['namaProduk'] ?? '',
      jumlah: json['jumlah'] ?? 0,
      hargaSatuan: _parseDouble(json['hargaSatuan']),
      diskon: _parseDouble(json['diskon']),
      subtotal: _parseDouble(json['subtotal']),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }
}