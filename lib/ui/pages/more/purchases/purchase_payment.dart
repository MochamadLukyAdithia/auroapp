import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';

class PurchasePayment extends StatelessWidget {
  const PurchasePayment({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('purchase page'),
        backgroundColor: primaryGreenColor,
        foregroundColor: Colors.white,
      ),
    );
  }
}
