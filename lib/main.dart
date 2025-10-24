import 'package:flutter/material.dart';
import 'package:pos_mobile/ui/pages/finances/add_finance.dart';
import 'package:pos_mobile/ui/pages/finances/filtered_finance_date.dart';
import 'package:pos_mobile/ui/pages/finances/update_finance.dart';
import 'package:pos_mobile/ui/pages/homepage.dart';
import 'package:pos_mobile/ui/pages/login/login_page.dart';
import 'package:pos_mobile/ui/pages/login/verification_page.dart';
import 'package:pos_mobile/ui/pages/more/customers/add_customer_page.dart';
import 'package:pos_mobile/ui/pages/more/more_page.dart';
import 'package:pos_mobile/ui/pages/more/suppliers/add_supplier.dart';
import 'package:pos_mobile/ui/pages/products_categories/categories/add_category_page.dart';
import 'package:pos_mobile/ui/pages/products_categories/products/add_price_page.dart';
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
      home: const AddSupplierPage(),
    );
  }
}
