import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';

class SalesReportPage extends StatelessWidget {
  const SalesReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan transaksi penjualan'),
        backgroundColor: primaryGreenColor,
        foregroundColor: Colors.white,
      ),
    );
  }
}
