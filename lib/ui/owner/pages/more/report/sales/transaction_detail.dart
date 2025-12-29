import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pos_mobile/data/models/transaction_sales_report_model.dart';
import '../../../../../../blocs/company/company_cubit.dart';
import '../../../../../../core/theme/theme.dart';
import '../../../../../../data/models/company_model.dart';
import '../../../../../widgets/custom_app_bar.dart';
import '../../../../../widgets/floating_message.dart';
import '../history_transaction_receipt.dart';

class TransactionDetailPage extends StatelessWidget {
  final DateTime date;
  final List<TransactionReport>? transactions;
  final String Function(double) formatCurrency;

  const TransactionDetailPage({
    Key? key,
    required this.date,
    this.transactions,
    required this.formatCurrency,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: CustomAppBar(
        title: 'Detail Transaksi - ${DateFormat('dd MMM yyyy').format(date)}',
      ),
      body: transactions == null || transactions!.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak ada transaksi',
              style: TextStyle(
                fontFamily: fontType,
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: transactions!.length,
        itemBuilder: (context, index) {
          final transaction = transactions![index];
          return GestureDetector(
            onTap: () {
              // Navigate ke detail transaksi jika diperlukan
              _showTransactionDetail(context, transaction);
            },
            child: _TransactionDetailCard(
              transaction: transaction,
              formatCurrency: formatCurrency,
            ),
          );
        },
      ),
    );
  }

  void _showTransactionDetail(BuildContext context, TransactionReport transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return _TransactionDetailBottomSheet(
            transaction: transaction,
            formatCurrency: formatCurrency,
            scrollController: scrollController,
          );
        },
      ),
    );
  }
}

// ===================================================================
// SECTION: TRANSACTION DETAIL CARD
// ===================================================================
class _TransactionDetailCard extends StatelessWidget {
  final TransactionReport transaction;
  final String Function(double) formatCurrency;

  const _TransactionDetailCard({
    required this.transaction,
    required this.formatCurrency,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  transaction.kodeTransaksi,
                  style: const TextStyle(
                    fontFamily: fontType,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryGreenColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  transaction.metode,
                  style: const TextStyle(
                    fontFamily: fontType,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: primaryGreenColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // WAKTU
          Row(
            children: [
              Icon(Icons.access_time, size: 14, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(
                _formatTime(transaction.tanggal),
                style: TextStyle(
                  fontFamily: fontType,
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),

          // CUSTOMER
          if (transaction.pelanggan != 'Tanpa pelanggan') ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.person, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    transaction.pelanggan,
                    style: TextStyle(
                      fontFamily: fontType,
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],

          // KASIR
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.person_outline, size: 14, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(
                'Kasir: ${transaction.kasir}',
                style: TextStyle(
                  fontFamily: fontType,
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),

          const Divider(height: 20),

          // TOTAL DAN KEUNTUNGAN
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Penjualan',
                    style: TextStyle(
                      fontFamily: fontType,
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formatCurrency(transaction.totalPenjualan),
                    style: const TextStyle(
                      fontFamily: fontType,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: primaryGreenColor,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Keuntungan',
                    style: TextStyle(
                      fontFamily: fontType,
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formatCurrency(transaction.keuntungan),
                    style: const TextStyle(
                      fontFamily: fontType,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2196F3),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // INFO TAMBAHAN
          if (transaction.totalDiskon > 0 || transaction.biayaLain > 0) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (transaction.totalDiskon > 0)
                  Text(
                    'Diskon: ${formatCurrency(transaction.totalDiskon)}',
                    style: TextStyle(
                      fontFamily: fontType,
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                if (transaction.biayaLain > 0)
                  Text(
                    'Biaya Lain: ${formatCurrency(transaction.biayaLain)}',
                    style: TextStyle(
                      fontFamily: fontType,
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return DateFormat('HH:mm').format(dateTime);
    } catch (e) {
      return '-';
    }
  }
}

// ===================================================================
// SECTION: TRANSACTION DETAIL BOTTOM SHEET
// ===================================================================
class _TransactionDetailBottomSheet extends StatelessWidget {
  final TransactionReport transaction;
  final String Function(double) formatCurrency;
  final ScrollController scrollController;

  const _TransactionDetailBottomSheet({
    required this.transaction,
    required this.formatCurrency,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: ListView(
        controller: scrollController,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Detail Transaksi',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              IconButton(
                onPressed: () async {
                  Navigator.pop(context); // Tutup modal dulu

                  // ✅ Ambil data company dari CompanyCubit
                  final companyCubit = context.read<CompanyCubit>();
                  final companyState = companyCubit.state;

                  Company? company;

                  if (companyState is CompanyLoaded) {
                    company = companyState.company;
                  } else {
                    // Jika belum loaded, load dulu
                    await companyCubit.loadCompany();
                    final newState = companyCubit.state;
                    if (newState is CompanyLoaded) {
                      company = newState.company;
                    }
                  }

                  if (company == null) {
                    if (context.mounted) {
                      FloatingMessage.show(
                        context,
                        message: 'Data toko tidak tersedia',
                        textOnly: true,
                        backgroundColor: Colors.red,
                      );
                    }
                    return;
                  }

                  // ✅ Kirim company sebagai parameter
                  if (context.mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HistoryTransactionReceiptPage(
                          transactionId: transaction.id,
                          transactionCode: transaction.kodeTransaksi,
                          company: company!, // ✅ Kirim data company
                        ),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.receipt_long),
                color: primaryGreenColor,
                tooltip: 'Lihat Receipt Lengkap',
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            transaction.kodeTransaksi,
            style: TextStyle(
              fontFamily: fontType,
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const Divider(height: 24),

          // Info Grid
          _buildInfoRow('Tanggal', _formatDate(transaction.tanggal)),
          _buildInfoRow('Waktu', _formatTime(transaction.tanggal)),
          _buildInfoRow('Kasir', transaction.kasir),
          _buildInfoRow('Pelanggan', transaction.pelanggan),
          if (transaction.teleponPelanggan != '-')
            _buildInfoRow('Telepon', transaction.teleponPelanggan),
          _buildInfoRow('Metode Pembayaran', transaction.metode),

          const Divider(height: 24),

          // Financial Details
          _buildFinancialRow('Total Penjualan', transaction.totalPenjualan, isPrimary: true),
          if (transaction.totalDiskon > 0)
            _buildFinancialRow('Diskon', transaction.totalDiskon, isNegative: true),
          if (transaction.biayaLain > 0)
            _buildFinancialRow(
              transaction.namaBiayaLain ?? 'Biaya Lain',
              transaction.biayaLain,
            ),
          _buildFinancialRow('Bayar', transaction.bayar),
          _buildFinancialRow('Kembalian', transaction.kembalian),

          const Divider(height: 24),

          _buildFinancialRow('Keuntungan', transaction.keuntungan, isProfit: true),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: fontType,
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: fontType,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialRow(
      String label,
      double value, {
        bool isPrimary = false,
        bool isProfit = false,
        bool isNegative = false,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: fontType,
              fontSize: isPrimary || isProfit ? 14 : 13,
              fontWeight: isPrimary || isProfit ? FontWeight.w600 : FontWeight.normal,
              color: isPrimary || isProfit ? Colors.black : Colors.grey.shade600,
            ),
          ),
          Text(
            '${isNegative ? '-' : ''}${formatCurrency(value)}',
            style: TextStyle(
              fontFamily: fontType,
              fontSize: isPrimary || isProfit ? 16 : 13,
              fontWeight: isPrimary || isProfit ? FontWeight.w700 : FontWeight.w600,
              color: isProfit
                  ? const Color(0xFF2196F3)
                  : isPrimary
                  ? primaryGreenColor
                  : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return DateFormat('dd MMM yyyy').format(dateTime);
    } catch (e) {
      return '-';
    }
  }

  String _formatTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return DateFormat('HH:mm').format(dateTime);
    } catch (e) {
      return '-';
    }
  }
}