import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';

class ReportPage extends StatelessWidget {
  const ReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ini laporan'),
        backgroundColor: primaryGreenColor,
        foregroundColor: Colors.white,
      ),
    );
  }
}
