import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';

class PurchaseReportPage extends StatelessWidget {
  const PurchaseReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan pembelian barang'),
        backgroundColor: primaryGreenColor,
        foregroundColor: Colors.white,
      ),
    );
  }
}
