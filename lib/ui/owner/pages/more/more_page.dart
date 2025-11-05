import 'package:flutter/material.dart';
import 'package:pos_mobile/core/theme/theme.dart';
import '../../../../route/route.dart';
import '../../../widgets/custom_app_bar.dart';



class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Lainnya'),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
        children: [
          MenuTile(
            icon: Icons.group,
            title: 'Kelola pelanggan',
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.customer);
            },
          ),
          const Divider(height: 1),

          MenuTile(
            icon: Icons.check_box,
            title: 'Kelola stok',
            onTap: () {
              // Navigator.pushNamed(context, AppRoutes.customer);
            },
          ),
          const Divider(height: 1),

          // MenuTile(
          //   icon: Icons.business,
          //   title: 'Kelola Supplier',
          //   onTap: () {
          //     Navigator.pushNamed(context, AppRoutes.supplier);
          //   },
          // ),
          // const Divider(height: 1),

          // MenuTile(
          //   icon: Icons.shopping_cart,
          //   title: 'Pembelian Barang',
          //   onTap: () {
          //     Navigator.pushNamed(context, AppRoutes.purchase);
          //   },
          // ),
          // const Divider(height: 1),

          MenuTile(
            icon: Icons.receipt_long,
            title: 'Laporan',
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.report);
            },
          ),
          const Divider(height: 1),

          MenuTile(
            icon: Icons.settings,
            title: 'Pengaturan',
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.setting);
            },
          ),
          const Divider(height: 1),

          MenuTile(
            icon: Icons.book,
            title: 'Panduan Pengguna',
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.guide);
            },
          ),
          const Divider(height: 1),

          MenuTile(
            icon: Icons.info,
            title: 'Tentang Aplikasi',
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.about);
            },
          ),
          const Divider(height: 1),

          MenuTile(
            icon: Icons.logout,
            title: 'Keluar',
            textColor: Colors.red,
            iconColor: Colors.red,
            onTap: () {
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Konfirmasi Keluar'),
          content: const Text('Apakah kamu yakin ingin keluar dari akun ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreenColor,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Keluar'),
            ),
          ],
        );
      },
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
