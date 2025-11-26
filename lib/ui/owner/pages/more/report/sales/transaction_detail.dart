import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pos_mobile/data/models/transaction_model.dart';
import '../../../../../../core/theme/theme.dart';
import '../../../../../widgets/custom_app_bar.dart';
import '../../../../../widgets/transaction_receipt.dart';

class TransactionDetailPage extends StatelessWidget {
  final DateTime date;
  final List<TransactionModel> transactions;
  final String Function(int) formatCurrency;

  const TransactionDetailPage({
    Key? key,
    required this.date,
    required this.transactions,
    required this.formatCurrency,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: CustomAppBar(
        title: 'Detail Transaksi - ${DateFormat('dd MMM yyyy').format(date)}',
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final transaction = transactions[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TransactionReceiptPage(
                    transaction: transaction,
                  ),
                ),
              );
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
}

// ===================================================================
// SECTION: TRANSACTION DETAIL CARD
// ===================================================================
class _TransactionDetailCard extends StatelessWidget {
  final TransactionModel transaction;
  final String Function(int) formatCurrency;

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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                transaction.id,
                style: const TextStyle(
                  fontFamily: fontType,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryGreenColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  transaction.paymentMethod,
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
                DateFormat('HH:mm').format(transaction.transactionDate),
                style: TextStyle(
                  fontFamily: fontType,
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),

          // CUSTOMER
          if (transaction.customer != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.person, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  transaction.customer!.name,
                  style: TextStyle(
                    fontFamily: fontType,
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],

          const Divider(height: 20),

          // TOTAL DAN ITEM
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pendapatan',
                    style: TextStyle(
                      fontFamily: fontType,
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formatCurrency(transaction.totalPayment),
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
                    formatCurrency(transaction.totalProfit),
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

          const SizedBox(height: 8),

          // INFO ITEM
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '${transaction.items.length} item • ',
                style: TextStyle(
                  fontFamily: fontType,
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                '${transaction.items.fold<int>(0, (sum, item) => sum + item.quantity)} qty',
                style: TextStyle(
                  fontFamily: fontType,
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}