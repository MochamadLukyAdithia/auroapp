import 'package:flutter/material.dart';
import '../../../../widgets/custom_app_bar.dart';

class FlowReportPage extends StatelessWidget {
  const FlowReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomAppBar(title: 'Laporan Arus Kas'),
    );
  }
}
