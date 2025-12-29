import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../../blocs/company/company_cubit.dart';
import '../../../../../../blocs/transaction/transaction_cubit.dart';
import '../../../../../../blocs/transaction/transaction_state.dart';
import '../../../../../../core/theme/theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../data/models/company_model.dart';
import '../../../../../../route/route.dart';
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

      // Panggil API untuk save transaction
      await transactionCubit.completeAndSaveTransaction();

      // Check if success
      final state = transactionCubit.state;
      if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
        setState(() {
          _isProcessing = false;
          _hasError = true;
          _errorMessage = state.errorMessage!;
        });
      } else {
        if (mounted) {
          setState(() => _isProcessing = false);
        }
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  String _formatCurrency(double value) {
    return NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0)
        .format(value);
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('dd MMM yyyy - HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
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

        // if (!didPop && !_isProcessing && !_hasError) {
        //   final shouldPop = await ConfirmationDialog.show(
        //     context,
        //     title: 'Keluar dari Halaman Ini?',
        //     message: 'Pastikan Anda sudah mencatat atau mencetak struk transaksi ini',
        //     confirmText: 'Ya, Keluar',
        //     cancelText: 'Batal',
        //     icon: Icons.warning_amber_rounded,
        //     iconColor: Colors.orange,
        //     confirmColor: primaryGreenColor,
        //   );
        // }
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

    if (_hasError) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
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
                    context.read<TransactionCubit>().resetTransaction();
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      AppRoutes.transaction,
                          (route) => route.isFirst,
                    );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreenColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Kembali'),
              ),
            ],
          ),
        ),
      );
    }

    return BlocBuilder<TransactionCubit, TransactionState>(
      builder: (context, state) {
        final transaction = state.completedTransaction;

        // Gunakan data dari completed transaction (dari API)
        final transactionNumber = transaction?.transactionNumber ?? '';
        final totalTagihan = transaction?.totalTransaction ?? state.finalTotal.toDouble();
        final diterima = transaction?.totalPayment ?? (state.receivedAmount ?? 0).toDouble();
        final diskon = transaction?.transactionDiscount ?? state.discount.toDouble();
        final biayaLain = transaction?.otherCost ?? state.otherCosts.toDouble();
        final kembalian = transaction?.changeAmount ?? state.changeAmount.toDouble();
        final transactionDate = transaction?.transactionDate ?? state.transactionDate ?? DateTime.now();
        final customer = transaction?.customer ?? state.selectedCustomer;
        final paymentMethod = transaction?.companyPaymentMethod.paymentMethod.paymentMethodName ??
            state.selectedPaymentMethod?.name ?? // ✅
            'Belum dipilih';

        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        const Icon(
                          Icons.check_circle,
                          size: 80,
                          color: primaryGreenColor,
                        ),
                        const SizedBox(height: 16),
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
                        if (transactionNumber.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              transactionNumber,
                              style: TextStyle(
                                fontFamily: fontType,
                                fontSize: 12,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
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
                                  label: transaction?.nameOtherCost ?? 'Biaya Lain',
                                  value: _formatCurrency(biayaLain),
                                ),
                                const SizedBox(height: 12),
                              ],
                              _DetailRow(
                                label: 'Metode Pembayaran',
                                value: paymentMethod,
                                valueIsBold: true,
                              ),
                              const SizedBox(height: 12),
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

                        // Detail Items (opsional, bisa ditampilkan jika perlu)
                        if (transaction != null && transaction.detailTransaction.isNotEmpty) ...[
                          const SizedBox(height: 16),
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
                                  'Item Produk',
                                  style: TextStyle(
                                    fontFamily: fontType,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ...transaction.detailTransaction.map((detail) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            '${detail.product.productName} x${detail.quantity}',
                                            style: TextStyle(
                                              fontFamily: fontType,
                                              fontSize: 13,
                                              color: Colors.grey.shade700,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          _formatCurrency(detail.subtotal),
                                          style: const TextStyle(
                                            fontFamily: fontType,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
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
                      // Tombol Lihat Detail Struk
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(color: primaryGreenColor, width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () async {
                            if (transaction != null) {
                              // Ambil data company dari CompanyCubit
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
                                    backgroundColor: Colors.red,
                                  );
                                }
                                return;
                              }

                              // Arahkan ke halaman detail struk
                              if (context.mounted) {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.transactionReceipt,
                                  arguments: {
                                    'transaction': transaction,
                                    'company': company,
                                  },
                                );
                              }
                            } else {
                              if (context.mounted) {
                                FloatingMessage.show(
                                  context,
                                  message: 'Data transaksi tidak tersedia',
                                  backgroundColor: Colors.red,
                                );
                              }
                            }
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.receipt_long,
                                color: primaryGreenColor,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Lihat Detail Struk',
                                style: TextStyle(
                                  fontFamily: fontType,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: primaryGreenColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Tombol Transaksi Baru
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: primaryGreenColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () {
                            context.read<TransactionCubit>().resetTransaction();
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              AppRoutes.transaction,
                                  (route) => route.isFirst,
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.add_circle_outline, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Transaksi Baru',
                                style: TextStyle(
                                  fontFamily: fontType,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isHighlight;
  final bool valueIsBold;
  final Color? labelColor;
  final Color? valueColor;

  const _DetailRow({
    required this.label,
    required this.value,
    this.isHighlight = false,
    this.valueIsBold = false,
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
            fontWeight: (isHighlight || valueIsBold) ? FontWeight.w600 : FontWeight.normal,
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