import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pos_mobile/data/models/transaction_model.dart';
import '../../../../../core/theme/theme.dart';
import '../../../../../core/utils/receipt_service.dart';
import 'custom_app_bar.dart';

class TransactionReceiptPage extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionReceiptPage({
    Key? key,
    required this.transaction,
  }) : super(key: key);

  String _formatCurrency(int amount) {
    return NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0)
        .format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: const CustomAppBar(title: 'Detail Struk'),
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

                  // TANGGAL & WAKTU
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('yyyy-MM-dd').format(transaction.transactionDate),
                        style: const TextStyle(
                          fontFamily: fontType,
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        DateFormat('HH:mm:ss').format(transaction.transactionDate),
                        style: const TextStyle(
                          fontFamily: fontType,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // PELANGGAN (jika ada)
                  if (transaction.customer != null) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Pelanggan:',
                          style: TextStyle(
                            fontFamily: fontType,
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          transaction.customer!.name,
                          style: const TextStyle(
                            fontFamily: fontType,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],

                  const Divider(height: 24),

                  // ITEMS
                  // Di bagian ITEMS, ubah menjadi:
                  // ITEMS - Versi sederhana
                  ...transaction.items.map((item) {
                    print('   totalPrice: ${item.totalPrice}');
                    // Hitung harga per item (sudah didiskon jika ada)
                    final pricePerItem = item.totalPrice ~/ item.quantity;

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
                                  item.productName,
                                  style: const TextStyle(
                                    fontFamily: fontType,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Text(
                                _formatCurrency(item.totalPrice),
                                style: const TextStyle(
                                  fontFamily: fontType,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),

                          // Detail dengan info diskon jika ada
                          if (item.discount != null && item.discount! > 0) ...[
                            Text(
                              '${item.quantity} x ${_formatCurrency(pricePerItem)} (Disc ${item.discount!.toInt()}%)',
                              style: TextStyle(
                                fontFamily: fontType,
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            Text(
                              'Harga normal: ${_formatCurrency(item.sellingPrice.toInt())}',
                              style: TextStyle(
                                fontFamily: fontType,
                                fontSize: 10,
                                color: Colors.grey.shade500,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ] else
                            Text(
                              '${item.quantity} x ${_formatCurrency(pricePerItem)}',
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

                  // SUBTOTAL
                  _ReceiptRow(
                    label: 'Sub Total',
                    value: _formatCurrency(transaction.subtotal),
                  ),

                  // DISKON
                  if (transaction.discount > 0)
                    _ReceiptRow(
                      label: 'Diskon',
                      value: '-${_formatCurrency(transaction.discount)}',
                      valueColor: Colors.red,
                    ),

                  // BIAYA LAIN
                  if (transaction.otherCosts > 0)
                    _ReceiptRow(
                      label: 'Biaya Lain',
                      value: _formatCurrency(transaction.otherCosts),
                    ),

                  const SizedBox(height: 8),

                  // TOTAL
                  _ReceiptRow(
                    label: 'Total',
                    value: _formatCurrency(transaction.totalPayment),
                    isBold: true,
                    fontSize: 16,
                  ),

                  const Divider(height: 24),

                  // PEMBAYARAN
                  _ReceiptRow(
                    label: 'Bayar (${transaction.paymentMethod})',
                    value: _formatCurrency(transaction.receivedAmount),
                  ),

                  // KEMBALIAN
                  if (transaction.changeAmount > 0)
                    _ReceiptRow(
                      label: 'Kembalian',
                      value: _formatCurrency(transaction.changeAmount),
                    ),

                  const SizedBox(height: 16),
                  const Divider(height: 24),

                  // FOOTER
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
                    'Kode Transaksi: ${transaction.id}',
                    style: TextStyle(
                      fontFamily: fontType,
                      fontSize: 10,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            // ACTION BUTTONS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ReceiptService.shareReceipt(transaction);
                      },
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
                      onPressed: () {
                        ReceiptService.printReceipt(transaction);
                      },
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