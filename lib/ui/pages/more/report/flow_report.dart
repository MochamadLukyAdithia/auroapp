import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';

class FlowReportPage extends StatelessWidget {
  const FlowReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan arus kas'),
        backgroundColor: primaryGreenColor,
        foregroundColor: Colors.white,
      ),
    );
  }
}
