import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pos_mobile/data/models/transaction_sales_report_model.dart';
import '../../../../../../blocs/company/company_cubit.dart';
import '../../../../../../core/theme/theme.dart';
import '../../../../../../data/models/company_model.dart';
import '../../../../../../data/models/finance_model.dart';
import '../../../../../widgets/custom_app_bar.dart';
import '../../../../../widgets/finance_receipt.dart';
import '../../../../../widgets/floating_message.dart';
import '../history_transaction_receipt.dart';

class FlowDetailPage extends StatelessWidget {
  final DateTime date;
  final List<TransactionReport> transactions;
  final List<Finance> finances;

  const FlowDetailPage({
    super.key,
    required this.date,
    required this.transactions,
    required this.finances,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMMM yyyy', 'id_ID');
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    // Gabungkan semua transaksi dalam 1 list
    final List<Map<String, dynamic>> items = [];

    // Tambahkan transaksi penjualan
    for (var transaction in transactions) {
      items.add({
        'date': DateTime.parse(transaction.tanggal),
        'type': 'sales',
        'description': 'Transaksi #${transaction.kodeTransaksi}',
        'amount': transaction.totalPenjualan.toInt(),
        'profit': transaction.keuntungan.toInt(),
        'data': transaction,
      });
    }

    // Tambahkan transaksi keuangan
    for (var finance in finances) {
      items.add({
        'date': finance.date,
        'type': finance.type == FinanceType.income ? 'income' : 'expense',
        'description': finance.name,
        'amount': (finance.amount is double) ? (finance.amount as double).toInt() : finance.amount as int,
        'notes': finance.description,
        'data': finance,
      });
    }

    // Sort berdasarkan waktu (terbaru di atas)
    items.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));

    // Hitung summary untuk hari ini
    final totalSales = transactions.fold<double>(0, (sum, t) => sum + t.totalPenjualan);
    final totalIncome = finances
        .where((f) => f.type == FinanceType.income)
        .fold<double>(0, (sum, f) => sum + f.amount);
    final totalExpense = finances
        .where((f) => f.type == FinanceType.outcome)
        .fold<double>(0, (sum, f) => sum + f.amount);
    final totalRevenue = totalSales + totalIncome;
    final netIncome = totalRevenue - totalExpense;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: CustomAppBar(
        title: 'Detail Arus Kas - ${dateFormat.format(date)}',
      ),
      body: items.isEmpty
          ? _buildEmptyState()
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Card
              _buildSummaryCard(
                totalRevenue: totalRevenue,
                totalExpense: totalExpense,
                netIncome: netIncome,
                currencyFormat: currencyFormat,
              ),
              const SizedBox(height: 16),

              // Transaction List
              _buildTransactionList(
                items: items,
                currencyFormat: currencyFormat,
                context: context,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak ada transaksi',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Belum ada transaksi pada tanggal ini',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required double totalRevenue,
    required double totalExpense,
    required double netIncome,
    required NumberFormat currencyFormat,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ringkasan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),

          // Total Pemasukan & Pengeluaran
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  label: 'Total Pemasukan',
                  amount: currencyFormat.format(totalRevenue),
                  color: const Color(0xFF4CAF50),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryItem(
                  label: 'Total Pengeluaran',
                  amount: currencyFormat.format(totalExpense),
                  color: const Color(0xFFE57373),
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, color: Colors.grey[300]),
          ),

          // Pendapatan Neto
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pendapatan Neto',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                currencyFormat.format(netIncome),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: netIncome >= 0 ? const Color(0xFF4CAF50) : const Color(0xFFE57373),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required String label,
    required String amount,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          amount,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionList({
    required List<Map<String, dynamic>> items,
    required NumberFormat currencyFormat,
    required BuildContext context,
  }) {
    final timeFormat = DateFormat('HH:mm', 'id_ID');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Daftar Transaksi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${items.length} Transaksi',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey[200]),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: Colors.grey[200],
              indent: 72,
            ),
            itemBuilder: (context, index) {
              final item = items[index];
              final date = item['date'] as DateTime;
              final type = item['type'] as String;
              final description = item['description'] as String;
              final amount = (item['amount'] is double)
                  ? (item['amount'] as double).toInt()
                  : item['amount'] as int;

              Color amountColor;
              IconData icon;
              Color iconBgColor;
              String typeLabel;

              if (type == 'sales') {
                amountColor = const Color(0xFF4CAF50);
                icon = Icons.shopping_cart_outlined;
                iconBgColor = Colors.green[50]!;
                typeLabel = 'Pemasukan';
              } else if (type == 'income') {
                amountColor = const Color(0xFF4CAF50);
                icon = Icons.arrow_downward_rounded;
                iconBgColor = Colors.green[50]!;
                typeLabel = 'Pemasukan Lain';
              } else {
                amountColor = const Color(0xFFE57373);
                icon = Icons.arrow_upward_rounded;
                iconBgColor = Colors.red[50]!;
                typeLabel = 'Pengeluaran';
              }

              return InkWell(
                onTap: () => _showTransactionDetail(context, item),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      // Icon
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: iconBgColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          icon,
                          color: amountColor,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              description,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: type == 'expense'
                                        ? Colors.red[50]
                                        : Colors.green[50],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    typeLabel,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: type == 'expense'
                                          ? Colors.red[700]
                                          : Colors.green[700],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  timeFormat.format(date),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Amount
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            currencyFormat.format(amount),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: amountColor,
                              fontSize: 15,
                            ),
                          ),
                          if (type == 'sales' && item['profit'] != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              'Laba ${currencyFormat.format(item['profit'])}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ],
                      ),

                      const SizedBox(width: 8),
                      Icon(
                        Icons.chevron_right,
                        color: Colors.grey[400],
                        size: 20,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showTransactionDetail(BuildContext context, Map<String, dynamic> item) {
    final type = item['type'] as String;

    if (type == 'sales') {
      final transaction = item['data'] as TransactionReport;
      _showTransactionReportDialog(context, transaction);
    } else {
      final finance = item['data'] as Finance;

      final companyCubit = context.read<CompanyCubit>();
      final companyState = companyCubit.state;

      if (companyState is CompanyLoaded) {
        final company = companyState.company; // ✅ Di sini udah non-nullable

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FinanceReceiptPage(
              finance: finance,
              company: company, // ✅ Pasti non-null
            ),
          ),
        );
      } else {
        FloatingMessage.show(
          context,
          message: 'Data toko tidak tersedia',
          textOnly: true,
          backgroundColor: Colors.red,
        );
      }
    }
  }

  void _showTransactionReportDialog(BuildContext context, TransactionReport transaction) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

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
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
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
              const SizedBox(height: 20),

              // Detail Info
              _detailRow('Kode Transaksi', transaction.kodeTransaksi),
              const SizedBox(height: 12),
              _detailRow('Tanggal', DateFormat('dd MMMM yyyy HH:mm', 'id_ID').format(
                  DateTime.parse(transaction.tanggal)
              )),
              const SizedBox(height: 12),
              _detailRow('Kasir', transaction.kasir),
              const SizedBox(height: 12),
              _detailRow('Pelanggan', transaction.pelanggan),
              const SizedBox(height: 12),
              _detailRow('Metode Pembayaran', transaction.metode),

              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 20),

              // Financial Info
              _detailRow('Total Penjualan', currencyFormat.format(transaction.totalPenjualan)),
              const SizedBox(height: 12),
              _detailRow('Diskon', currencyFormat.format(transaction.totalDiskon)),
              const SizedBox(height: 12),
              _detailRow('Bayar', currencyFormat.format(transaction.bayar)),
              const SizedBox(height: 12),
              _detailRow('Kembalian', currencyFormat.format(transaction.kembalian)),
              if (transaction.biayaLain > 0) ...[
                const SizedBox(height: 12),
                _detailRow(
                  transaction.namaBiayaLain ?? 'Biaya Lain',
                  currencyFormat.format(transaction.biayaLain),
                ),
              ],

              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 20),

              // Profit
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Keuntungan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  Text(
                    currencyFormat.format(transaction.keuntungan),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryGreenColor,
                    ),
                  ),
                ],
              ),

              // const SizedBox(height: 24),
              // SizedBox(
              //   width: double.infinity,
              //   child: ElevatedButton(
              //     onPressed: () => Navigator.pop(context),
              //     style: ElevatedButton.styleFrom(
              //       backgroundColor: primaryGreenColor,
              //       padding: const EdgeInsets.symmetric(vertical: 14),
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(10),
              //       ),
              //     ),
              //     child: const Text(
              //       'Tutup',
              //       style: TextStyle(
              //         fontSize: 16,
              //         fontWeight: FontWeight.w600,
              //         color: Colors.white,
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}