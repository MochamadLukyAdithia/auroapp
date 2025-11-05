import 'package:flutter/material.dart';
import 'package:pos_mobile/route/route.dart';
import 'package:pos_mobile/ui/widgets/custom_app_bar.dart';

import '../../../../../../core/theme/theme.dart';

class PaymentMethodPage extends StatelessWidget {
  const PaymentMethodPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: 'Metode Pembayaran'),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const PaymentSectionHeader(title: 'PEMBAYARAN TUNAI'),
          const SizedBox(height: 16),
          PaymentMethodItem(
            title: 'Tunai',
            isEnabled: true,
            onChanged: (value) {
              // TODO: Handle toggle with BLoC
            },
          ),
          const SizedBox(height: 12),
          PaymentMethodItem(
            title: 'Qris',
            isEnabled: true,
            onChanged: (value) {
              // TODO: Handle toggle with BLoC
            },
          ),
          const SizedBox(height: 32),
          const PaymentSectionHeader(title: 'PEMBAYARAN NON TUNAI'),
          const SizedBox(height: 16),
          PaymentMethodItem(
            title: 'Bank Transfer',
            isEnabled: true,
            onChanged: (value) {
              // TODO: Handle toggle with BLoC
            },
          ),
          const SizedBox(height: 56),
          const AddPaymentMethodButton()
        ],
      ),
    );
  }
}

class PaymentSectionHeader extends StatelessWidget {
  final String title;

  const PaymentSectionHeader({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
        letterSpacing: 0.5,
        fontFamily: fontType,
      ),
    );
  }
}

class PaymentMethodItem extends StatelessWidget {
  final String title;
  final bool isEnabled;
  final ValueChanged<bool> onChanged;

  const PaymentMethodItem({
    super.key,
    required this.title,
    required this.isEnabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
              fontFamily: fontType,
            ),
          ),
          Switch(
            value: isEnabled,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: primaryGreenColor, // Ganti dengan warna primaryGreenColor mu
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.grey.shade300,
          ),
        ],
      ),
    );
  }
}

class AddPaymentMethodButton extends StatelessWidget {
  const AddPaymentMethodButton({super.key});
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.addPaymentMethod);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreenColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          'Tambah Rekening',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontFamily: fontType,
          ),
        ),
      ),
    );
  }
}