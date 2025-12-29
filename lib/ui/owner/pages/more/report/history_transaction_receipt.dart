import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pos_mobile/data/models/transaction_sales_report_model.dart';
import '../../../../../core/theme/theme.dart';
import '../../../../../core/utils/auth_service.dart';
import '../../../../../core/utils/receipt_service.dart';
import '../../../../../data/models/company_model.dart';
import '../../../../../data/repositories/transaction_sales_repository.dart';
import '../../../../widgets/custom_app_bar.dart';

class HistoryTransactionReceiptPage extends StatefulWidget {
  final int transactionId;
  final String transactionCode;
  final Company company;

  const HistoryTransactionReceiptPage({
    Key? key,
    required this.transactionId,
    required this.transactionCode,
    required this.company
  }) : super(key: key);

  @override
  State<HistoryTransactionReceiptPage> createState() => _HistoryTransactionReceiptPageState();
}

class _HistoryTransactionReceiptPageState extends State<HistoryTransactionReceiptPage> {
  final TransactionReportRepository _repository = TransactionReportRepository();
  TransactionReportDetail? _detail;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTransactionDetail();
  }

  Future<void> _loadTransactionDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _repository.getTransactionReportDetail(widget.transactionId);

      if (result.success && result.data != null) {
        setState(() {
          _detail = result.data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result.message ?? 'Gagal memuat detail transaksi';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan: $e';
        _isLoading = false;
      });
    }
  }

  String _formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0)
        .format(amount);
  }

  void _shareReceipt() async {
    if (_detail == null) return;
    await ReceiptService.shareHistoryReceipt(_detail!, widget.company);
  }

  void _printReceipt() async {
    if (_detail == null) return;
    await ReceiptService.printHistoryReceipt(_detail!, widget.company);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: CustomAppBar(
        title: 'Detail Struk #${widget.transactionCode}',
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? _buildErrorState()
          : FutureBuilder<String>(
        future: AuthService.getCurrentRoleDisplayName(),
        builder: (context, snapshot) {
          return _buildReceiptContent(snapshot.data ?? 'Kasir');

        },
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Terjadi kesalahan',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadTransactionDetail,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreenColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptContent(String roleLabel) {
    if (_detail == null) return const SizedBox();

    final transaction = _detail!.transaction;
    final products = _detail!.products;

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  widget.company.name,
                  style: const TextStyle(
                    fontFamily: fontType,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  widget.company.address,
                  style: const TextStyle(
                    fontFamily: fontType,
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      transaction.tanggal,
                      style: const TextStyle(
                        fontFamily: fontType,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      transaction.waktu,
                      style: const TextStyle(
                        fontFamily: fontType,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                if (transaction.pelanggan != 'Tanpa pelanggan') ...[
                  _ReceiptRow(
                    label: 'Pelanggan',
                    value: transaction.pelanggan,
                    fontSize: 11,
                  ),
                  const SizedBox(height: 4),
                ],

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const  Text(
                      'Kasir: ',
                      style: const TextStyle(
                        fontFamily: fontType,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      transaction.kasir,
                      style: const TextStyle(
                        fontFamily: fontType,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                _ReceiptRow(
                  label: 'Metode Pembayaran',
                  value: transaction.metodePembayaran,
                  fontSize: 11,
                ),

                const Divider(height: 24),

                ...products.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                item.namaProduk,
                                style: const TextStyle(
                                  fontFamily: fontType,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Text(
                              _formatCurrency(item.subtotal),
                              style: const TextStyle(
                                fontFamily: fontType,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),

                        if (item.diskon > 0) ...[
                          Text(
                            '${item.jumlah} x ${_formatCurrency(item.hargaSatuan * (1 - item.diskon / 100))} (Disc ${item.diskon.toInt()}%)',
                            style: TextStyle(
                              fontFamily: fontType,
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            'Harga normal: ${_formatCurrency(item.hargaSatuan)}',
                            style: TextStyle(
                              fontFamily: fontType,
                              fontSize: 10,
                              color: Colors.grey.shade500,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ] else
                          Text(
                            '${item.jumlah} x ${_formatCurrency(item.hargaSatuan)}',
                            style: TextStyle(
                              fontFamily: fontType,
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                      ],
                    ),
                  );
                }).toList(),

                const Divider(height: 24),

                _ReceiptRow(
                  label: 'Sub Total',
                  value: _formatCurrency(transaction.totalPenjualan),
                ),

                if (transaction.diskon > 0)
                  _ReceiptRow(
                    label: 'Diskon',
                    value: '-${_formatCurrency(transaction.diskon)}',
                    valueColor: Colors.red,
                  ),

                if (transaction.biayaLain > 0)
                  _ReceiptRow(
                    label: 'Biaya Lain',
                    value: _formatCurrency(transaction.biayaLain),
                  ),

                const SizedBox(height: 8),

                _ReceiptRow(
                  label: 'Total',
                  value: _formatCurrency(transaction.bayar),
                  isBold: true,
                  fontSize: 16,
                ),

                const Divider(height: 24),

                _ReceiptRow(
                  label: 'Bayar (${transaction.metodePembayaran})',
                  value: _formatCurrency(transaction.bayar),
                ),

                if (transaction.kembalian > 0)
                  _ReceiptRow(
                    label: 'Kembalian',
                    value: _formatCurrency(transaction.kembalian),
                  ),

                const SizedBox(height: 16),

                if (transaction.catatan.isNotEmpty && transaction.catatan != '-') ...[
                  const Divider(height: 24),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Catatan:',
                          style: TextStyle(
                            fontFamily: fontType,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          transaction.catatan,
                          style: TextStyle(
                            fontFamily: fontType,
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const Divider(height: 24),

                const Text(
                  'Terima kasih!',
                  style: TextStyle(
                    fontFamily: fontType,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Kode: ${transaction.kodeTransaksi}',
                  style: TextStyle(
                    fontFamily: fontType,
                    fontSize: 10,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _shareReceipt,
                    icon: const Icon(Icons.share, size: 18),
                    label: const Text('Share'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primaryGreenColor,
                      side: const BorderSide(color: primaryGreenColor),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _printReceipt,
                    icon: const Icon(Icons.print, size: 18),
                    label: const Text('Print'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreenColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final double fontSize;
  final Color? valueColor;

  const _ReceiptRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.fontSize = 13,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: fontType,
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: fontType,
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}