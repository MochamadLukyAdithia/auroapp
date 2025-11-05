import 'package:flutter/material.dart';
import 'package:pos_mobile/ui/widgets/custom_app_bar.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomAppBar(title: 'Beranda'),
      body: Center(
        child: Text(
          'Ini Homepage',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}