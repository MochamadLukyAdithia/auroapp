import 'package:flutter/material.dart';
import '../../../../widgets/custom_app_bar.dart';

class SalesReportPage extends StatelessWidget {
  const SalesReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomAppBar(title: 'Laporan Transaksi Penjualan'),
    );
  }
}
