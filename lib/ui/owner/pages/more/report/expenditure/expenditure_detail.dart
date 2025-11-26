// ui/pages/finance/expenditure_report/expenditure_detail.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../../core/theme/theme.dart';
import '../../../../../../data/models/finance_model.dart';
import '../../../../../widgets/custom_app_bar.dart';

class ExpenditureDetailPage extends StatelessWidget {
  final DateTime date;
  final List<Finance> finances;
  final String Function(double) formatCurrency; // ✅ Ubah dari int ke double

  const ExpenditureDetailPage({
    super.key,
    required this.date,
    required this.finances,
    required this.formatCurrency,
  });

  @override
  Widget build(BuildContext context) {
    final total = finances.fold<double>(
      0.0, // ✅ Ubah dari 0 ke 0.0
          (sum, item) => sum + item.amount, // ✅ Langsung pakai amount (double)
    );

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Detail Pengeluaran',
      ),
      body: Column(
        children: [
          // Summary Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [primaryGreenColor, Color(0xFF059669)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Pengeluaran',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  formatCurrency(total),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${finances.length} Transaksi',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // List of transactions
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: finances.length,
              itemBuilder: (context, index) {
                final finance = finances[index];
                return _ExpenditureDetailCard(
                  finance: finance,
                  formatCurrency: formatCurrency,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpenditureDetailCard extends StatelessWidget {
  final Finance finance;
  final String Function(double) formatCurrency;

  const _ExpenditureDetailCard({
    Key? key,
    required this.finance,
    required this.formatCurrency,
  }) : super(key: key);

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
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.receipt,
              color: Colors.red.shade400,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  finance.name,
                  style: const TextStyle(
                    fontFamily: fontType,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (finance.description != null && finance.description!.isNotEmpty)
                  Text(
                    finance.description!,
                    style: TextStyle(
                      fontFamily: fontType,
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 4),
                // ✅ Tampilkan tanggal lengkap atau hilangkan baris ini
                Text(
                  DateFormat('dd MMM yyyy', 'id').format(finance.date),
                  style: TextStyle(
                    fontFamily: fontType,
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),

          // Amount
          Text(
            formatCurrency(finance.amount),
            style: const TextStyle(
              fontFamily: fontType,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}