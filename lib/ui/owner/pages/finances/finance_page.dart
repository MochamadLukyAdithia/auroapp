import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../../widgets/custom_app_bar.dart';
import 'add_finance.dart';

class FinancePage extends StatefulWidget {
  const FinancePage({super.key});

  @override
  State<FinancePage> createState() => _FinancePageState();
}

class _FinancePageState extends State<FinancePage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomAppBar(title: 'Keuangan'),
      body: Row(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: EmptyFinanceSection(),
          )
        ],
      ),
    );
  }
}

class EmptyFinanceSection extends StatelessWidget {
  const EmptyFinanceSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 330),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Catatan Keuangan Kosong',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: primaryGreenColor,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Silahkan tambahkan catatan pemasukan & pengeluaran terlebih dahulu',
              style: TextStyle(
                fontSize: 12,
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
                'Catat Keuangan',
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
                  MaterialPageRoute(builder: (_) => const AddFinance()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}