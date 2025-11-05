import 'package:flutter/material.dart';
import 'package:pos_mobile/ui/owner/pages/more/settings/cashiers/add_cashier.dart';
import 'package:pos_mobile/ui/widgets/custom_app_bar.dart';

import '../../../../../../core/theme/theme.dart';

class CashierPage extends StatelessWidget {
  const CashierPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomAppBar(title: 'Manajemen Kasir'),
      body: Column(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: EmptyCashierSection(),
          )
        ],
      ),
    );
  }
}

class EmptyCashierSection extends StatelessWidget {
  const EmptyCashierSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 300),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Belum ada kasir',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: primaryGreenColor,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Silahkan tambahkan kasir',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreenColor,
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Tambah Kasir',
                style: TextStyle(
                  fontFamily: 'Segoe',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddCashierPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}