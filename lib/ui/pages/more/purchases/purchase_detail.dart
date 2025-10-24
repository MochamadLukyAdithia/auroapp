import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class PurchaseDetail extends StatelessWidget {
  const PurchaseDetail({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('purchase detail'),
        backgroundColor: primaryGreenColor,
        foregroundColor: Colors.white,
      ),
    );
  }
}
