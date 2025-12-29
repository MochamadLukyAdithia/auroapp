import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_mobile/ui/owner/pages/transactions/sales/payment/transaction_success.dart';
import 'package:pos_mobile/ui/widgets/custom_app_bar.dart';
import '../../../../../../blocs/history_stock/stock_bloc.dart';
import '../../../../../../blocs/product/product_bloc.dart';
import '../../../../../../blocs/transaction/transaction_cubit.dart';
import '../../../../../../blocs/transaction/transaction_state.dart';
import '../../../../../../core/theme/theme.dart';
import '../../../../../../data/models/payment_method_model.dart' as pm;

class BankTransferPayment extends StatelessWidget {
  const BankTransferPayment({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionCubit, TransactionState>(
      builder: (context, state) {
        final enabledBanks = state.enabledBank;

        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          appBar: const CustomAppBar(title: 'Pilih Bank'),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pilih Bank Tujuan',
                    style: TextStyle(
                      fontFamily: fontType,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (enabledBanks.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(
                              Icons.account_balance_outlined,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Belum ada bank yang aktif',
                              style: TextStyle(
                                fontFamily: fontType,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Aktifkan bank di menu Metode Pembayaran',
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
                    BankListWidget(banks: enabledBanks),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class BankListWidget extends StatelessWidget {
  final List<pm.PaymentMethod> banks;

  const BankListWidget({
    super.key,
    required this.banks,
  });

  Color _getBankColor(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('bca')) return const Color(0xFF0066CC);
    if (lowerName.contains('mandiri')) return const Color(0xFF003D79);
    if (lowerName.contains('bri')) return const Color(0xFF003D79);
    if (lowerName.contains('bni')) return const Color(0xFFFF6600);
    return primaryGreenColor; // default
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: banks.map((bank) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: BankItem(
            paymentMethod: bank,
            bankColor: _getBankColor(bank.name),
            onTap: () {
              _showBankConfirmation(context, bank);
            },
          ),
        );
      }).toList(),
    );
  }

  void _showBankConfirmation(BuildContext context, pm.PaymentMethod bank) {
    final cubit = context.read<TransactionCubit>();
    final stockBloc = context.read<StockBloc>();

    // Set payment method dengan detail bank
    cubit.setPaymentMethod(bank);

    // Tampilkan dialog konfirmasi
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (dialogContext) => BlocProvider.value(
        value: cubit,
        child: BankTransferConfirmationDialog(
          bank: bank,
          bankColor: _getBankColor(bank.name),
          onConfirm: () {
            final cubit = context.read<TransactionCubit>();
            final productBloc = context.read<ProductBloc>();

            cubit.setReceivedAmount(cubit.state.finalTotal);
            cubit.completeDigitalPayment();

            Navigator.of(dialogContext).pop(); // Tutup dialog dulu

            // ✅ PERBAIKAN: Pop halaman bank, baru push success
            if (context.mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => MultiBlocProvider(
                    providers: [
                      BlocProvider.value(value: cubit),
                      BlocProvider.value(value: stockBloc),
                      BlocProvider.value(value: productBloc),
                    ],
                    child: const TransactionSuccess(),
                  ),
                ),
              );
            }
          },
          onCancel: () {
            Navigator.of(dialogContext).pop(); // Tutup dialog
          },
        ),
      ),
    );
  }
}

// 🆕 Dialog Konfirmasi Bank Transfer
class BankTransferConfirmationDialog extends StatelessWidget {
  final pm.PaymentMethod bank;
  final Color bankColor;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const BankTransferConfirmationDialog({
    super.key,
    required this.bank,
    required this.bankColor,
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
                      color: bankColor,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      _getBankInitial(bank.name),
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
                    "Konfirmasi Transfer Bank",
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
                    "Pastikan transfer ke bank tujuan sudah berhasil.",
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


class BankItem extends StatelessWidget {
  final pm.PaymentMethod paymentMethod;
  final Color bankColor;
  final VoidCallback onTap;

  const BankItem({
    super.key,
    required this.paymentMethod,
    required this.bankColor,
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
              // Logo Bank (Placeholder dengan initial)
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: bankColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    _getBankInitial(paymentMethod.name),
                    style: TextStyle(
                      color: bankColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Bank Name & Details
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

  String _getBankInitial(String name) {
    if (name.length <= 3) return name.toUpperCase();
    return name.substring(0, 3).toUpperCase();
  }
}