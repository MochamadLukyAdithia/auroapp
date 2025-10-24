import 'package:flutter/material.dart';
import 'package:pos_mobile/ui/pages/homepage/homepage.dart';
import 'package:pos_mobile/ui/pages/login/login_page.dart';
import 'package:pos_mobile/ui/pages/login/verification_page.dart';
import 'package:pos_mobile/ui/pages/product/product_page.dart';
import 'package:pos_mobile/ui/widgets/bottom_bar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ProductPage(),
    );
  }
}
