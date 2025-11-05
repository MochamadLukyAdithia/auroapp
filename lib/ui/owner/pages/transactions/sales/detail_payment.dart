import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:pos_mobile/ui/widgets/custom_app_bar.dart';
import '../../../../../core/theme/theme.dart';
import '../../../../../route/route.dart';

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
    final payments = [
      {'icon': Icons.attach_money_rounded, 'label': 'Tunai'},
      {'icon': Icons.qr_code_2_rounded, 'label': 'QRIS'},
      {'icon': Icons.account_balance_rounded, 'label': 'Bank Transfer'},
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
  }

  void _navigateToPayment(BuildContext context, String label) {
    switch (label) {
      case 'Tunai':
        Navigator.pushNamed(context, AppRoutes.cashPayment);
        break;
      case 'QRIS':
        _showQrisPaymentDialog(context);
        break;
      case 'Bank Transfer':
        Navigator.pushNamed(context, AppRoutes.bankPayment);
        break;
      case 'E-Wallet':
        Navigator.pushNamed(context, AppRoutes.ewalletPayment);
        break;
    }
  }

  void _showQrisPaymentDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (context) => const QrisPaymentDialog(),
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
class QrisPaymentDialog extends StatelessWidget {
  const QrisPaymentDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
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
              // Icon Warning
              Container(
                padding: const EdgeInsets.all(14),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFA726),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_rounded,
                  size: 32,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),

              // Title
              const Text(
                'Warning',
                style: TextStyle(
                  fontFamily: fontType,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Message
              const Text(
                'This is the description of the presenter dialog box',
                style: TextStyle(
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
                  // Button Dismiss
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
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Pembayaran dibatalkan'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      },
                      child: const Text(
                        'Dismiss',
                        style: TextStyle(
                          fontFamily: fontType,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Button OK
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
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.transactionSuccess);

                      },
                      child: const Text(
                        'OK',
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
  }
}