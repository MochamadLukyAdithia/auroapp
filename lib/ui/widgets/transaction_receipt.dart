import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pos_mobile/core/utils/auth_service.dart';
import 'package:pos_mobile/data/models/company_model.dart';
import 'package:pos_mobile/data/models/transaction_model.dart';
import '../../../../../core/theme/theme.dart';
import '../../../../../core/utils/receipt_service.dart';
import 'custom_app_bar.dart';

class TransactionReceiptPage extends StatelessWidget {
  final TransactionModel transaction;
  final Company company;

  const TransactionReceiptPage({
    Key? key,
    required this.transaction,
    required this.company
  }) : super(key: key);

  String _formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0)
        .format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: const CustomAppBar(title: 'Detail Struk'),
      body: FutureBuilder<String>(
        future: AuthService.getCurrentRoleDisplayName(),
        builder: (context, snapshot){
          return SingleChildScrollView(
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
                      Text(
                        company.name,
                        style: const TextStyle(
                          fontFamily: fontType,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        company.address,
                        style: const TextStyle(
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

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${snapshot.data ?? "Kasir"}:',  // ✅ Pakai snapshot.data dari FutureBuilder
                            style: const TextStyle(
                              fontFamily: fontType,
                              fontSize: 11,
                            ),
                          ),
                          FutureBuilder<String?>(
                            future: AuthService.getCurrentUserName(),
                            builder: (context, userSnapshot) {
                              return Text(
                                userSnapshot.data ?? transaction.user.fullname,
                                style: const TextStyle(
                                  fontFamily: fontType,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              );
                            },
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
                        const SizedBox(height: 4),
                      ],
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Metode Pembayaran:',
                            style: TextStyle(
                              fontFamily: fontType,
                              fontSize: 11,
                            ),
                          ),
                          Text(
                            transaction.companyPaymentMethod.paymentMethod.paymentMethodName,
                            style: const TextStyle(
                              fontFamily: fontType,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),

                      const Divider(height: 24),

                      // ITEMS
                      ...transaction.detailTransaction.map((item) {
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
                                      item.product.productName,
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

                              // Detail dengan info diskon jika ada
                              if (item.discount > 0) ...[
                                Text(
                                  '${item.quantity} x ${_formatCurrency(item.unitPrice * (1 - item.discount / 100))} (Disc ${item.discount.toInt()}%)',
                                  style: TextStyle(
                                    fontFamily: fontType,
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                Text(
                                  'Harga normal: ${_formatCurrency(item.unitPrice)}',
                                  style: TextStyle(
                                    fontFamily: fontType,
                                    fontSize: 10,
                                    color: Colors.grey.shade500,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              ] else
                                Text(
                                  '${item.quantity} x ${_formatCurrency(item.unitPrice)}',
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

                      // DISKON TRANSAKSI
                      if (transaction.transactionDiscount !> 0)
                        _ReceiptRow(
                          label: 'Diskon',
                          value: '-${_formatCurrency(transaction.transactionDiscount!)}',
                          valueColor: Colors.red,
                        ),

                      // PAJAK (jika ada)
                      if (transaction.transactionTax > 0)
                        _ReceiptRow(
                          label: 'Pajak',
                          value: _formatCurrency(transaction.transactionTax),
                        ),

                      // BIAYA LAIN
                      if (transaction.otherCost > 0)
                        _ReceiptRow(
                          label: transaction.nameOtherCost ?? 'Biaya Lain',
                          value: _formatCurrency(transaction.otherCost),
                        ),

                      const SizedBox(height: 8),

                      // TOTAL TRANSAKSI
                      _ReceiptRow(
                        label: 'Total',
                        value: _formatCurrency(transaction.totalTransaction),
                        isBold: true,
                        fontSize: 16,
                      ),

                      const Divider(height: 24),

                      // PEMBAYARAN
                      _ReceiptRow(
                        label: 'Bayar (${transaction.companyPaymentMethod.paymentMethod.paymentMethodName})',
                        value: _formatCurrency(transaction.totalPayment),
                      ),

                      // KEMBALIAN
                      if (transaction.changeAmount > 0)
                        _ReceiptRow(
                          label: 'Kembalian',
                          value: _formatCurrency(transaction.changeAmount),
                        ),

                      const SizedBox(height: 16),

                      // CATATAN (jika ada)
                      if (transaction.transactionDescription != null &&
                          transaction.transactionDescription!.isNotEmpty) ...[
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
                                transaction.transactionDescription!,
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
                        'Kode: ${transaction.transactionNumber}',
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
                            ReceiptService.shareReceipt(transaction, company);
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
                            ReceiptService.printReceipt(transaction, company);
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
          );
        }
      )
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