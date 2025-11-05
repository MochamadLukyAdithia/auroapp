import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../../core/theme/theme.dart';
import '../../../../../../route/route.dart';

class TransactionSuccess extends StatelessWidget {
  const TransactionSuccess({super.key});

  String _formatCurrency(int value) {
    return NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0)
        .format(value);
  }

  String _formatDateTime(DateTime dateTime) {
    // Tanpa locale 'id' untuk menghindari error
    return DateFormat('dd MMM yyyy - HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Nanti ambil dari parameter atau Bloc
    final int totalTagihan = 12000;
    final int diterima = 12000;
    final int diskon = 0;
    final int biayaLain = 0;
    final int kembalian = 3000;
    final DateTime transactionDate = DateTime.now();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            // Header dengan tombol close
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 40),

                    // Success Title
                    const Text(
                      'Transaksi Berhasil',
                      style: TextStyle(
                        fontFamily: fontType,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: primaryGreenColor,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Date Time
                    Text(
                      _formatDateTime(transactionDate),
                      style: TextStyle(
                        fontFamily: fontType,
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Detail Transaksi Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade200,
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Detail Transaksi',
                            style: TextStyle(
                              fontFamily: fontType,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // List Detail
                          _DetailRow(
                            label: 'Total Tagihan',
                            value: _formatCurrency(totalTagihan),
                          ),
                          const SizedBox(height: 12),
                          _DetailRow(
                            label: 'Diterima',
                            value: _formatCurrency(diterima),
                          ),
                          const SizedBox(height: 12),
                          _DetailRow(
                            label: 'Diskon',
                            value: _formatCurrency(diskon),
                          ),
                          const SizedBox(height: 12),
                          _DetailRow(
                            label: 'Biaya Lain',
                            value: _formatCurrency(biayaLain),
                          ),
                          const SizedBox(height: 12),
                          _DetailRow(
                            label: 'Kembalian',
                            value: _formatCurrency(kembalian),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Buttons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Cetak Struk Button
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(color: primaryGreenColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            // TODO: Handle cetak struk
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Mencetak struk...'),
                                backgroundColor: primaryGreenColor,
                              ),
                            );
                          },
                          child: const Text(
                            'Cetak Struk',
                            style: TextStyle(
                              fontFamily: fontType,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: primaryGreenColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Bagikan Struk Button
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(color: primaryGreenColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            // TODO: Handle bagikan struk
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Membagikan struk...'),
                                backgroundColor: primaryGreenColor,
                              ),
                            );
                          },
                          child: const Text(
                            'Bagikan Struk',
                            style: TextStyle(
                              fontFamily: fontType,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: primaryGreenColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Transaksi Baru Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: primaryGreenColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {

                      },
                      child: const Text(
                        'Transaksi Baru',
                        style: TextStyle(
                          fontFamily: fontType,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
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

// Widget untuk row detail transaksi
class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: fontType,
            fontSize: 14,
            color: Colors.grey.shade700,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontFamily: fontType,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}