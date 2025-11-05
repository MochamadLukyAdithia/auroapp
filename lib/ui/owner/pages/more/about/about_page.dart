import 'package:flutter/material.dart';
import '../../../../widgets/custom_app_bar.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomAppBar(title: 'Tentang Aplikasi'),
    );
}}
