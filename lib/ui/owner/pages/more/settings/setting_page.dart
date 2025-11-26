import 'package:flutter/material.dart';
import 'package:pos_mobile/core/theme/theme.dart';

import '../../../../../route/route.dart';
import '../../../../widgets/custom_app_bar.dart';




class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Pengaturan'),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
        children: [
          MenuTile(
            icon: Icons.business,
            title: 'Profil Toko',
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.shop);
            },
          ),

          const Divider(height: 1),

          MenuTile(
            icon: Icons.business,
            title: 'Profil Owner',
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.ownerProfile);
            },
          ),

          const Divider(height: 1),

          MenuTile(
            icon: Icons.group,
            title: 'Manajemen Pengguna',
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.cashier);
            },
          ),

          const Divider(height: 1),

          MenuTile(
            icon: Icons.payment,
            title: 'Metode Pembayaran',
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.paymentMethod);
            },
          ),
        ],
      ),
    );
  }
}

class MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final Color? textColor;
  final Color? iconColor;

  const MenuTile({
    super.key,
    required this.icon,
    required this.title,
    this.onTap,
    this.textColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? Colors.black),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? Colors.black,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}
