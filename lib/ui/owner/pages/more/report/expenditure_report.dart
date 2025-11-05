import 'package:flutter/material.dart';
import '../../../../widgets/custom_app_bar.dart';


class ExpenditureReportPage extends StatelessWidget {
  const ExpenditureReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomAppBar(title: 'Laporan Pengeluaran'),
    );
  }
}
