import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../../blocs/history_stock/stock_bloc.dart';
import '../../../../../../blocs/history_stock/stock_event.dart';
import '../../../../../../blocs/transaction/transaction_cubit.dart';
import '../../../../../../blocs/transaction/transaction_state.dart';
import '../../../../../../core/theme/theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/utils/receipt_service.dart';
import '../../../../../widgets/floating_message.dart';

class TransactionSuccess extends StatefulWidget {
  const TransactionSuccess({super.key});

  @override
  State<TransactionSuccess> createState() => _TransactionSuccessState();
}

class _TransactionSuccessState extends State<TransactionSuccess> {
  bool _isProcessing = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _processTransaction();
  }

  Future<void> _processTransaction() async {
    try {
      final transactionCubit = context.read<TransactionCubit>();
      final stockBloc = context.read<StockBloc>();

      // 🔹 Kurangi stok dulu
      final stockReductions = transactionCubit.getStockReductionData();
      for (var item in stockReductions) {
        stockBloc.add(AddStockOut(
          productId: item['productId'],
          quantity: item['quantity'],
          notes: 'Transaksi: ${item['transactionId']}',
        ));
      }

      await Future.delayed(const Duration(milliseconds: 500));
      await transactionCubit.saveTransaction();

      setState(() => _isProcessing = false);
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  String _formatCurrency(int value) {
    return NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0)
        .format(value);
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('dd MMM yyyy - HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Hanya bisa pop kalau TIDAK sedang processing
      onPopInvokedWithResult: (didPop, result) async {
        if (_isProcessing && !didPop) {
          FloatingMessage.show(
            context,
            message: 'Mohon tunggu, transaksi sedang diproses...',
            textOnly: true,
            backgroundColor: Colors.orange,
          );
          return;
        }

        if (!didPop && !_isProcessing && !_hasError) {
          final shouldPop = await ConfirmationDialog.show(
            context,
            title: 'Keluar dari Halaman Ini?',
            message: 'Pastikan Anda sudah mencatat atau mencetak struk transaksi ini',
            confirmText: 'Ya, Keluar',
            cancelText: 'Batal',
            icon: Icons.warning_amber_rounded,
            iconColor: Colors.orange,
            confirmColor: primaryGreenColor,
          );

          if (shouldPop == true && context.mounted) {
            context.read<TransactionCubit>().resetTransaction();
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        }
      },
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (_isProcessing) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: primaryGreenColor),
              SizedBox(height: 16),
              Text('Memproses transaksi...'),
            ],
          ),
        ),
      );
    }

    // 🔹 Jika ada error saat proses
    if (_hasError) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Transaksi Gagal',
                style: TextStyle(
                  fontFamily: fontType,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _errorMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: fontType,
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text('Kembali'),
              ),
            ],
          ),
        ),
      );
    }

    // 🔹 Kalau sudah berhasil (normal state)
    return BlocBuilder<TransactionCubit, TransactionState>(
      builder: (context, state) {
        final totalTagihan = state.totalPayment;
        final diterima = state.receivedAmount ?? 0;
        final diskon = state.discount;
        final biayaLain = state.otherCosts;
        final kembalian = state.changeAmount;
        final transactionDate = state.transactionDate ?? DateTime.now();
        final customer = state.selectedCustomer;

        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          body: SafeArea(
            child: Column(
              children: [
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        const SizedBox(height: 40),

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

                        Text(
                          _formatDateTime(transactionDate),
                          style: TextStyle(
                            fontFamily: fontType,
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),

                        if (customer != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: primaryGreenColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.person,
                                  size: 16,
                                  color: primaryGreenColor,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  customer.name,
                                  style: const TextStyle(
                                    fontFamily: fontType,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: primaryGreenColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

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

                              _DetailRow(
                                label: 'Total Tagihan',
                                value: _formatCurrency(totalTagihan),
                              ),
                              const SizedBox(height: 12),

                              if (diskon > 0) ...[
                                _DetailRow(
                                  label: 'Diskon',
                                  value: '-${_formatCurrency(diskon)}',
                                  labelColor: Colors.red,
                                  valueColor: Colors.red,
                                ),
                                const SizedBox(height: 12),
                              ],

                              if (biayaLain > 0) ...[
                                _DetailRow(
                                  label: 'Biaya Lain',
                                  value: _formatCurrency(biayaLain),
                                ),
                                const SizedBox(height: 12),
                              ],

                              _DetailRow(
                                label: 'Diterima',
                                value: _formatCurrency(diterima),
                              ),
                              const SizedBox(height: 12),

                              _DetailRow(
                                label: 'Kembalian',
                                value: _formatCurrency(kembalian),
                                isHighlight: true,
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
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding:
                                const EdgeInsets.symmetric(vertical: 14),
                                side: const BorderSide(
                                    color: primaryGreenColor),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () async {
                                final stockBloc = context.read<StockBloc>();
                                final transactionCubit =
                                context.read<TransactionCubit>();

                                final stockReductions =
                                transactionCubit.getStockReductionData();
                                for (var item in stockReductions) {
                                  stockBloc.add(AddStockOut(
                                    productId: item['productId'],
                                    quantity: item['quantity'],
                                    notes:
                                    'Transaksi: ${item['transactionId']}',
                                  ));
                                }

                                await Future.delayed(
                                    const Duration(milliseconds: 300));

                                await transactionCubit.saveTransaction();
                                transactionCubit.resetTransaction();
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
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding:
                                const EdgeInsets.symmetric(vertical: 14),
                                side: const BorderSide(
                                    color: primaryGreenColor),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () async {
                                try {
                                  // final transaction = context.read<TransactionCubit>().getCurrentTransaction();
                                  // await ReceiptService.shareReceipt(transaction);

                                  if (context.mounted) {
                                    // ScaffoldMessenger.of(context).showSnackBar(
                                    //   const SnackBar(
                                    //     content:
                                    //     Text('Struk berhasil dibagikan'),
                                    //     backgroundColor: primaryGreenColor,
                                    //   ),
                                    // );
                                    FloatingMessage.show(context, message: 'Struk Berhasil Dibagikan', textOnly : true, backgroundColor: primaryBlueColor);

                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    // ScaffoldMessenger.of(context).showSnackBar(
                                    //   SnackBar(
                                    //     content: Text(
                                    //         'Gagal membagikan struk: $e'),
                                    //     backgroundColor: Colors.red,
                                    //   ),
                                    // );
                                    FloatingMessage.show(context, message: 'Gagal Membagikan Struk', textOnly : true, backgroundColor: primaryBlueColor);
                                  }
                                }
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
                          onPressed: () async {
                            context.read<TransactionCubit>().resetTransaction();
                            Navigator.of(context)
                                .popUntil((route) => route.isFirst);
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
      },
    );
  }
}

// Widget untuk row detail transaksi
class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isHighlight;
  final Color? labelColor;
  final Color? valueColor;

  const _DetailRow({
    required this.label,
    required this.value,
    this.isHighlight = false,
    this.labelColor,
    this.valueColor,
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
            color: labelColor ??
                (isHighlight ? primaryGreenColor : Colors.grey.shade700),
            fontWeight: isHighlight ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: fontType,
            fontSize: isHighlight ? 16 : 14,
            fontWeight: FontWeight.w600,
            color: valueColor ??
                (isHighlight ? primaryGreenColor : Colors.black87),
          ),
        ),
      ],
    );
  }
}


class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final Color? confirmColor;
  final IconData? icon;
  final Color? iconColor;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'Ya',
    this.cancelText = 'Batal',
    this.confirmColor,
    this.icon,
    this.iconColor,
  });

  static Future<bool?> show(
      BuildContext context, {
        required String title,
        required String message,
        String confirmText = 'Ya',
        String cancelText = 'Batal',
        Color? confirmColor,
        IconData? icon,
        Color? iconColor,
      }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ConfirmationDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        confirmColor: confirmColor,
        icon: icon,
        iconColor: iconColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            if (icon != null)
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: (iconColor ?? primaryGreenColor).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: iconColor ?? primaryGreenColor,
                ),
              ),

            if (icon != null) const SizedBox(height: 20),

            // Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: fontType,
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 12),

            // Message
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: fontType,
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(
                      cancelText,
                      style: TextStyle(
                        fontFamily: fontType,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: confirmColor ?? primaryGreenColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () => Navigator.pop(context, true),
                    child: Text(
                      confirmText,
                      style: const TextStyle(
                        fontFamily: fontType,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
