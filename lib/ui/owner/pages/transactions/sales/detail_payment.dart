import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_mobile/ui/owner/pages/transactions/sales/payment/bank.dart';
import 'package:pos_mobile/ui/owner/pages/transactions/sales/payment/cash.dart';
import 'package:pos_mobile/ui/owner/pages/transactions/sales/payment/e-wallet.dart';
import 'package:pos_mobile/ui/owner/pages/transactions/sales/payment/transaction_success.dart';
import 'package:pos_mobile/ui/widgets/custom_app_bar.dart';
import 'package:pos_mobile/ui/widgets/floating_message.dart';
import '../../../../../blocs/history_stock/stock_bloc.dart';
import '../../../../../blocs/payment_method/payment_method_cubit.dart';
import '../../../../../blocs/payment_method/payment_method_state.dart';
import '../../../../../blocs/product/product_bloc.dart';
import '../../../../../blocs/transaction/transaction_cubit.dart';
import '../../../../../blocs/transaction/transaction_state.dart';
import '../../../../../core/theme/theme.dart';
import '../../../../../data/models/payment_method_model.dart' as pm;

class DetailPayment extends StatelessWidget {
  const DetailPayment({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: const CustomAppBar(title: 'Jenis Pembayaran'),
      body: const SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pilih Jenis Pembayaran',
                style: TextStyle(
                  fontFamily: fontType,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 16),
              PaymentOptionList(),
              SizedBox(height: 24),
              PaymentNoteField(),
            ],
          ),
        ),
      ),
    );
  }
}

// opsi list nya
class PaymentOptionList extends StatelessWidget {
  const PaymentOptionList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PaymentMethodCubit, PaymentMethodState>(
      builder: (context, paymentState) {
        // ✅ Check apakah ada payment method yang aktif per kategori
        final hasActiveQRIS = paymentState is PaymentMethodLoaded &&
            paymentState.qrisMethods.any((p) => p.isEnabled);

        final hasActiveEwallet = paymentState is PaymentMethodLoaded &&
            paymentState.ewalletMethods.any((p) => p.isEnabled);

        final hasActiveBank = paymentState is PaymentMethodLoaded &&
            paymentState.bankMethods.any((p) => p.isEnabled);

        // ✅ Build payment options list secara dinamis
        final payments = <Map<String, dynamic>>[
          // Cash selalu ada
          {'icon': Icons.attach_money_rounded, 'label': 'Tunai'},

          // QRIS muncul kalau ada yang aktif
          if (hasActiveQRIS)
            {'icon': Icons.qr_code_2_rounded, 'label': 'QRIS'},

          // Bank Transfer muncul kalau ada yang aktif
          if (hasActiveBank)
            {'icon': Icons.account_balance_rounded, 'label': 'Bank Transfer'},

          // E-Wallet muncul kalau ada yang aktif
          if (hasActiveEwallet)
            {'icon': Icons.credit_card_rounded, 'label': 'E-Wallet'},
        ];

        return Column(
          children: payments
              .map((p) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: PaymentOptionItem(
              icon: p['icon'] as IconData,
              label: p['label'] as String,
              onTap: () {
                _navigateToPayment(context, p['label'] as String);
              },
            ),
          ))
              .toList(),
        );
      },
    );
  }

  void _navigateToPayment(BuildContext context, String label) {
    final transactionCubit = context.read<TransactionCubit>();

    switch (label) {
      case 'Tunai':
        final cashMethod = transactionCubit.state.availablePaymentMethods
            .firstWhere((method) => method.type == pm.PaymentType.cash);
        transactionCubit.setPaymentMethod(cashMethod);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: transactionCubit,
              child: const CashPayment(),
            ),
          ),
        );
        break;

      case 'QRIS':
        _showDigitalPaymentDialog(context, pm.PaymentType.qris);
        break;

      case 'Bank Transfer':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: transactionCubit,
              child: const BankTransferPayment(),
            ),
          ),
        );
        break;

      case 'E-Wallet':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: transactionCubit,
              child: const EwalletPayment(),
            ),
          ),
        );
        break;
    }
  }

  void _showDigitalPaymentDialog(BuildContext context, pm.PaymentType type) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<TransactionCubit>(),
        child: DigitalPaymentDialog(paymentType: type),
      ),
    );
  }
}

// opsi pembayaran
class PaymentOptionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const PaymentOptionItem({
    super.key,
    required this.icon,
    required this.label,
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryGreenColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: primaryGreenColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontFamily: fontType,
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
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

// catatan
class PaymentNoteField extends StatelessWidget {
  const PaymentNoteField({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Catatan',
          style: TextStyle(
            fontFamily: fontType,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          maxLines: 3,
          onChanged: (value) {
            context.read<TransactionCubit>().setNotes(value);
          },
          decoration: InputDecoration(
            hintText: 'Contoh: Pembelian Produk',
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: primaryGreenColor),
            ),
          ),
        ),
      ],
    );
  }
}

// Dialog QRIS dengan Blur Background
class DigitalPaymentDialog extends StatelessWidget {
  final pm.PaymentType paymentType;

  const DigitalPaymentDialog({super.key, required this.paymentType});

  IconData get _icon {
    switch (paymentType) {
      case pm.PaymentType.qris:
        return Icons.qr_code_scanner;
      case pm.PaymentType.bank:
        return Icons.account_balance;
      case pm.PaymentType.ewallet:
        return Icons.account_balance_wallet;
      default:
        return Icons.payment;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionCubit, TransactionState>(
      builder: (context, state) {
        final totalTagihan = state.finalTotal;

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
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: const BoxDecoration(
                      color: primaryGreenColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _icon,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title
                  Text(
                    'Konfirmasi Pembayaran ${_getPaymentTypeName()}',
                    style: const TextStyle(
                      fontFamily: fontType,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  // Total
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Total Pembayaran',
                          style: TextStyle(
                            fontFamily: fontType,
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Rp $totalTagihan',
                          style: const TextStyle(
                            fontFamily: fontType,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: primaryGreenColor,
                          ),
                        ),
                        if (state.discount > 0 || state.otherCosts > 0) ...[
                          const SizedBox(height: 8),
                          const Divider(height: 1),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Subtotal',
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              Text(
                                'Rp ${state.subtotal}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          if (state.discount > 0) ...[
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Diskon',
                                  style: TextStyle(fontSize: 12, color: Colors.red),
                                ),
                                Text(
                                  '- Rp ${state.discount}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          if (state.otherCosts > 0) ...[
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Biaya Lain',
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                                Text(
                                  '+ Rp ${state.otherCosts}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Message
                  Text(
                    'Apakah pembayaran via ${_getPaymentTypeName()} sudah berhasil?',
                    style: const TextStyle(
                      fontFamily: fontType,
                      fontSize: 13,
                      color: Colors.grey,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  // Buttons
                  Row(
                    children: [
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
                          onPressed: () {
                            Navigator.of(context).pop();
                            FloatingMessage.show(
                              context,
                              message: 'Pembayaran dibatalkan',
                              backgroundColor: Colors.red,
                            );
                          },
                          child: const Text(
                            'Batal',
                            style: TextStyle(
                              fontFamily: fontType,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
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
                          onPressed: () async {
                            final cubit = context.read<TransactionCubit>();
                            final stockBloc = context.read<StockBloc>();
                            final productBloc = context.read<ProductBloc>();

                            // Validasi stok
                            bool hasStockIssue = false;
                            String errorMessage = '';

                            for (var product in state.selectedItems) {
                              final qty = state.getQuantity(product.id.toString());
                              final stock = product.productStock;

                              if (qty > stock!) {
                                hasStockIssue = true;
                                errorMessage = 'Stok ${product.productName} tidak mencukupi!\n'
                                    'Tersedia: $stock, Dipilih: $qty';
                                break;
                              }
                            }

                            if (hasStockIssue) {
                              Navigator.of(context).pop(); // Tutup dialog dulu
                              if (context.mounted) {
                                FloatingMessage.show(context, message: errorMessage, backgroundColor: Colors.red);
                              }
                              return;
                            }

                            final selectedMethod = state.availablePaymentMethods.firstWhere(
                                  (pm) => pm.type == paymentType,
                            );
                            cubit.setPaymentMethod(selectedMethod);
                            cubit.setReceivedAmount(state.finalTotal);
                            cubit.completeDigitalPayment();

                            Navigator.of(context).pop();

                            if (context.mounted) {
                              Navigator.push(
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
                          child: const Text(
                            'Berhasil',
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

  String _getPaymentTypeName() {
    switch (paymentType) {
      case pm.PaymentType.qris:
        return 'QRIS';
      case pm.PaymentType.bank:
        return 'Bank Transfer';
      case pm.PaymentType.ewallet:
        return 'E-Wallet';
      default:
        return 'Digital';
    }
  }
}