import 'package:flutter/material.dart';
import 'package:pos_mobile/route/route.dart';
import 'package:pos_mobile/ui/widgets/custom_app_bar.dart';

import '../../../../../../core/theme/theme.dart';

class BankTransferPayment extends StatelessWidget {
  const BankTransferPayment({super.key});

  @override
  Widget build(BuildContext context) {
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
              BankListWidget(),
            ],
          ),
        ),
      ),
    );
  }
}

class BankListWidget extends StatelessWidget {
  BankListWidget({super.key});

  final List<Map<String, String>> banks = [
    {
      'name': 'BCA (Bank Central Asia)',
      'code': 'BCA',
      'color': '0xFF0066CC'
    },
    {'name': 'Mandiri', 'code': 'MANDIRI', 'color': '0xFF003D79'},
    {'name': 'BRI (Bank Rakyat Indonesia)', 'code': 'BRI', 'color': '0xFF003D79'},
    {'name': 'BNI (Bank Negara Indonesia)', 'code': 'BNI', 'color': '0xFFFF6600'},
    {'name': 'BTN (Bank Tabungan Negara)', 'code': 'BTN', 'color': '0xFF0066CC'},
    {'name': 'CIMB Niaga', 'code': 'CIMB', 'color': '0xFFCC0000'},
    {'name': 'Danamon', 'code': 'DANAMON', 'color': '0xFF0066CC'},
    {'name': 'Permata Bank', 'code': 'PERMATA', 'color': '0xFF009900'},
    {'name': 'OCBC NISP', 'code': 'OCBC', 'color': '0xFFCC0000'},
    {'name': 'Bank Syariah Indonesia (BSI)', 'code': 'BSI', 'color': '0xFF00AA5B'},
    {'name': 'Panin Bank', 'code': 'PANIN', 'color': '0xFF0066CC'},
    {'name': 'BTPN', 'code': 'BTPN', 'color': '0xFFCC0000'},
    {'name': 'Maybank Indonesia', 'code': 'MAYBANK', 'color': '0xFFFFCC00'},
    {'name': 'Bank Mega', 'code': 'MEGA', 'color': '0xFFCC0000'},
    {'name': 'Bank Jago', 'code': 'JAGO', 'color': '0xFF0099FF'},
    {'name': 'Jenius (BTPN)', 'code': 'JENIUS', 'color': '0xFF00C2A8'},
    {'name': 'Bank Neo Commerce', 'code': 'NEO', 'color': '0xFF00D4AA'},
    {'name': 'SeaBank', 'code': 'SEABANK', 'color': '0xFF00AAF5'},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: banks.map((bank) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: BankItem(
            bankName: bank['name']!,
            bankCode: bank['code']!,
            bankColor: Color(int.parse(bank['color']!)),
            onTap: () {
              // TODO: Nanti dispatch event ke Bloc atau navigate ke halaman konfirmasi
              _showBankConfirmation(context, bank['name']!, bank['code']!);
            },
          ),
        );
      }).toList(),
    );
  }

  void _showBankConfirmation(
      BuildContext context, String bankName, String bankCode) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Konfirmasi Bank'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Anda memilih:',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              bankName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreenColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.transactionSuccess);
            },
            child: const Text('Konfirmasi'),
          ),
        ],
      ),
    );
  }
}

class BankItem extends StatelessWidget {
  final String bankName;
  final String bankCode;
  final Color bankColor;
  final VoidCallback onTap;

  const BankItem({
    super.key,
    required this.bankName,
    required this.bankCode,
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
                    _getBankInitial(bankCode),
                    style: TextStyle(
                      color: bankColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Bank Name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bankName,
                      style: const TextStyle(
                        fontFamily: fontType,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      bankCode,
                      style: TextStyle(
                        fontFamily: fontType,
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
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

  String _getBankInitial(String code) {
    if (code.length <= 3) return code;
    return code.substring(0, 3);
  }
}