import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/theme.dart';
import '../../../../../data/models/finance_model.dart';
import 'custom_app_bar.dart';

class FinanceReceiptPage extends StatelessWidget {
  final Finance finance;

  const FinanceReceiptPage({
    Key? key,
    required this.finance,
  }) : super(key: key);

  String _formatCurrency(int amount) {
    return NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0)
        .format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = finance.type == FinanceType.income;
    final typeLabel = isIncome ? 'Pemasukan Lain' : 'Pengeluaran';
    final color = isIncome ? primaryGreenColor : Colors.red;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: CustomAppBar(title: 'Detail $typeLabel'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // RECEIPT DISPLAY
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
                  // HEADER TOKO
                  const Text(
                    'Cafe Indonesia',
                    style: TextStyle(
                      fontFamily: fontType,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Text(
                    'Jl. Kalimantan',
                    style: TextStyle(
                      fontFamily: fontType,
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // TYPE BADGE
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isIncome ? Colors.green[50] : Colors.red[50],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      typeLabel.toUpperCase(),
                      style: TextStyle(
                        fontFamily: fontType,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // TANGGAL & WAKTU
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('yyyy-MM-dd').format(finance.date),
                        style: const TextStyle(
                          fontFamily: fontType,
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        DateFormat('HH:mm:ss').format(finance.date),
                        style: const TextStyle(
                          fontFamily: fontType,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),

                  const Divider(height: 24),

                  // NAMA
                  _ReceiptRow(
                    label: 'Nama',
                    value: finance.name,
                    isBold: true,
                  ),

                  const SizedBox(height: 16),

                  // JUMLAH (Highlighted)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Jumlah',
                          style: TextStyle(
                            fontFamily: fontType,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _formatCurrency(finance.amount as int),
                          style: TextStyle(
                            fontFamily: fontType,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // CATATAN (jika ada)
                  if (finance.description != null && finance.description!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Divider(height: 24),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Catatan',
                          style: TextStyle(
                            fontFamily: fontType,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          finance.description!,
                          style: const TextStyle(
                            fontFamily: fontType,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 16),
                  const Divider(height: 24),

                  // FOOTER
                  Text(
                    finance.createdAt != null
                        ? 'Dibuat: ${DateFormat('dd MMM yyyy, HH:mm', 'id').format(finance.createdAt!)}'
                        : '',
                    style: TextStyle(
                      fontFamily: fontType,
                      fontSize: 10,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  if (finance.id != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'ID: ${finance.id}',
                      style: TextStyle(
                        fontFamily: fontType,
                        fontSize: 10,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // ACTION BUTTONS
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            //   child: Row(
            //     children: [
            //       Expanded(
            //         child: OutlinedButton.icon(
            //           onPressed: () {
            //             // TODO: Implement share functionality
            //             ScaffoldMessenger.of(context).showSnackBar(
            //               const SnackBar(content: Text('Fitur share segera hadir')),
            //             );
            //           },
            //           icon: const Icon(Icons.share, size: 18),
            //           label: const Text('Share'),
            //           style: OutlinedButton.styleFrom(
            //             foregroundColor: color,
            //             side: BorderSide(color: color),
            //             padding: const EdgeInsets.symmetric(vertical: 14),
            //           ),
            //         ),
            //       ),
            //       const SizedBox(width: 12),
            //       Expanded(
            //         child: ElevatedButton.icon(
            //           onPressed: () {
            //             // TODO: Implement print functionality
            //             ScaffoldMessenger.of(context).showSnackBar(
            //               const SnackBar(content: Text('Fitur print segera hadir')),
            //             );
            //           },
            //           icon: const Icon(Icons.print, size: 18),
            //           label: const Text('Print'),
            //           style: ElevatedButton.styleFrom(
            //             backgroundColor: color,
            //             foregroundColor: Colors.white,
            //             padding: const EdgeInsets.symmetric(vertical: 14),
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

// Helper Widget untuk baris struk
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
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: fontType,
                fontSize: fontSize,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}