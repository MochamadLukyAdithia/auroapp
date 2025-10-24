import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ini setting'),
        backgroundColor: primaryGreenColor,
        foregroundColor: Colors.white,
      ),
    );
  }
}
