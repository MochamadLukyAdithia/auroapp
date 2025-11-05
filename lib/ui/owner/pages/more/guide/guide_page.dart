import 'package:flutter/material.dart';
import '../../../../widgets/custom_app_bar.dart';

class GuidePage extends StatelessWidget {
  const GuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomAppBar(title: 'Panduan Pengguna'),
    );
  }
}
