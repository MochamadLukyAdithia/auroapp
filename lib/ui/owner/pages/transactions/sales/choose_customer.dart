import 'package:flutter/material.dart';
import 'package:pos_mobile/ui/widgets/custom_app_bar.dart';

import '../../../../../core/theme/theme.dart';
import '../../../../../route/route.dart';

class ChooseCustomer extends StatelessWidget {
  const ChooseCustomer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: const CustomAppBar(title: 'Pilih Pelanggan'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              CustomerSearchBar(
                onSearchChanged: (query) {
                },
              ),
              const EmptyCustomerSection(),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomerSearchBar extends StatelessWidget {
  final ValueChanged<String>? onSearchChanged;

  const CustomerSearchBar({
    super.key,
    this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        onChanged: onSearchChanged,
        decoration: const InputDecoration(
          hintText: 'Cari nama pelanggan...',
          hintStyle: TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          contentPadding: EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}

class EmptyCustomerSection extends StatelessWidget {
  const EmptyCustomerSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 280),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Data Pelanggan Kosong',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: primaryGreenColor,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Coba masukan data pelanggan, ya',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreenColor,
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Tambah Pelanggan',
                style: TextStyle(
                  fontFamily: 'Segoe',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              onPressed: () {Navigator.pushNamed(context, AppRoutes.addCustomer);},
            ),
          ],
        ),
      ),
    );
  }
}