import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ini profile'),
        backgroundColor: primaryGreenColor,
        foregroundColor: Colors.white,
      ),
    );
  }
}
