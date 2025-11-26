import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_mobile/ui/owner/pages/transactions/sales/payment/transaction_success.dart';
import 'package:pos_mobile/ui/widgets/custom_app_bar.dart';
import '../../../../../../blocs/history_stock/stock_bloc.dart';
import '../../../../../../blocs/transaction/transaction_cubit.dart';
import '../../../../../../blocs/transaction/transaction_state.dart';
import '../../../../../../core/theme/theme.dart';
import '../../../../../../data/models/payment_method_model.dart' as pm;
import '../detail_payment.dart';

class EwalletPayment extends StatelessWidget {
  const EwalletPayment({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionCubit, TransactionState>(
      builder: (context, state) {
        final enabledEwallets = state.enabledEwallet;

        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          appBar: const CustomAppBar(title: 'Pilih E-Wallet'),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pilih E-Wallet',
                    style: TextStyle(
                      fontFamily: fontType,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (enabledEwallets.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(
                              Icons.account_balance_wallet_outlined,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Belum ada e-wallet yang aktif',
                              style: TextStyle(
                                fontFamily: fontType,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Aktifkan e-wallet di menu Metode Pembayaran',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: fontType,
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    EwalletListWidget(ewallets: enabledEwallets),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class EwalletListWidget extends StatelessWidget {
  final List<pm.PaymentMethod> ewallets;

  const EwalletListWidget({
    super.key,
    required this.ewallets,
  });

  Color _getEwalletColor(String? provider) {
    switch (provider?.toLowerCase()) {
      case 'gopay':
        return const Color(0xFF00AA13);
      case 'ovo':
        return const Color(0xFF4B2D83);
      case 'dana':
        return const Color(0xFF118EEA);
      case 'shopeepay':
        return const Color(0xFFEE4D2D);
      default:
        return primaryGreenColor;
    }
  }

  IconData _getEwalletIcon(String? provider) {
    switch (provider?.toLowerCase()) {
      case 'gopay':
        return Icons.two_wheeler;
      case 'shopeepay':
        return Icons.shopping_bag;
      default:
        return Icons.account_balance_wallet;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: ewallets.map((ewallet) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: EwalletItem(
            paymentMethod: ewallet,
            ewalletColor: _getEwalletColor(ewallet.provider),
            icon: _getEwalletIcon(ewallet.provider),
            onTap: () {
              _showEwalletConfirmation(context, ewallet);
            },
          ),
        );
      }).toList(),
    );
  }

  void _showEwalletConfirmation(BuildContext context, pm.PaymentMethod ewallet) {
    final cubit = context.read<TransactionCubit>();
    final stockBloc = context.read<StockBloc>();

    // Set payment method dengan detail e-wallet
    cubit.setPaymentMethodWithDetail(PaymentMethod.ewallet, ewallet);

    // Tampilkan dialog konfirmasi
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (dialogContext) => BlocProvider.value(
        value: cubit,
        child: EwalletConfirmationDialog(
          ewallet: ewallet,
          ewalletColor: _getEwalletColor(ewallet.provider),
          icon: _getEwalletIcon(ewallet.provider),
          onConfirm: () {
            final cubit = context.read<TransactionCubit>();
            // 1. SET UANG DITERIMA = totalte.finalTotal);
            cubit.completeDigitalPayment(PaymentMethod.ewallet);
            Navigator.of(dialogContext).pop();

            // Navigate ke TransactionSuccess
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => MultiBlocProvider(
                  providers: [
                    BlocProvider.value(value: cubit),
                    BlocProvider.value(value: stockBloc),
                  ],
                  child: const TransactionSuccess(),
                ),
              ),
            );
          },
          onCancel: () {
            Navigator.of(dialogContext).pop(); // Tutup dialog
          },
        ),
      ),
    );
  }
}

// 🆕 Dialog Konfirmasi E-Wallet
class EwalletConfirmationDialog extends StatelessWidget {
  final pm.PaymentMethod ewallet;
  final Color ewalletColor;
  final IconData icon;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const EwalletConfirmationDialog({
  super.key,
  required this.ewallet,
  required this.ewalletColor,
  required this.icon,
  required this.onConfirm,
  required this.onCancel,
});

  String _getBankInitial(String name) {
    if (name.length <= 3) return name.toUpperCase();
    return name.substring(0, 3).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionCubit, TransactionState>(
      builder: (context, state) {
        final total = state.finalTotal;

        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Dialog(
            backgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon bulat
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: ewalletColor,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      _getBankInitial(ewallet.provider ?? ewallet.name),
                      style: const TextStyle(
                        fontFamily: fontType,
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title
                  const Text(
                    "Konfirmasi Transfer E-Wallet",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: fontType,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Info total
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Total Pembayaran",
                          style: TextStyle(
                            fontFamily: fontType,
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Rp $total",
                          style: const TextStyle(
                            fontFamily: fontType,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: primaryGreenColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Text
                  Text(
                    "Pastikan transfer ke e-wallet tujuan sudah berhasil.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: fontType,
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Buttons
                  Row(
                    children: [
                      // Batal
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            backgroundColor: const Color(0xFFE57373),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          onPressed: onCancel,
                          child: const Text(
                            "Batal",
                            style: TextStyle(
                              fontFamily: fontType,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Konfirmasi
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            backgroundColor: primaryGreenColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          onPressed: onConfirm,
                          child: const Text(
                            "Berhasil",
                            style: TextStyle(
                              fontFamily: fontType,
                              fontSize: 14,
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
          ),
        );
      },
    );
  }
}



class EwalletItem extends StatelessWidget {
  final pm.PaymentMethod paymentMethod;
  final Color ewalletColor;
  final IconData icon;
  final VoidCallback onTap;

  const EwalletItem({
    super.key,
    required this.paymentMethod,
    required this.ewalletColor,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              // Logo E-Wallet (Placeholder dengan icon)
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: ewalletColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    color: ewalletColor,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // E-Wallet Name & Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      paymentMethod.name,
                      style: const TextStyle(
                        fontFamily: fontType,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // if (paymentMethod.accountNumber != null &&
                    //     paymentMethod.accountNumber!.isNotEmpty)
                    //   Text(
                    //     paymentMethod.accountNumber!,
                    //     style: TextStyle(
                    //       fontFamily: fontType,
                    //       fontSize: 12,
                    //       color: Colors.grey.shade600,
                    //       fontWeight: FontWeight.w500,
                    //     ),
                    //   )
                    // else
                    //   Text(
                    //     paymentMethod.provider?.toUpperCase() ?? '',
                    //     style: TextStyle(
                    //       fontFamily: fontType,
                    //       fontSize: 12,
                    //       color: Colors.grey.shade600,
                    //     ),
                    //   ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}