import 'package:flutter/material.dart';
import 'package:pos_mobile/core/theme/theme.dart';

class MorePage extends StatefulWidget {
  const MorePage({super.key});

  @override
  State<MorePage> createState() => _MorePageState();
}

class _MorePageState extends State<MorePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lainnya'),
        backgroundColor: primaryGreenColor,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        children: const [
          MenuTile(
            icon: Icons.group,
            title: 'Kelola Pelanggan',
          ),
          Divider(height: 1),
          MenuTile(
            icon: Icons.business,
            title: 'Kelola Supplier',
          ),
          Divider(height: 1),
          MenuTile(
            icon: Icons.shopping_cart,
            title: 'Pembelian Barang',
          ),
          Divider(height: 1),
          MenuTile(
            icon: Icons.receipt_long,
            title: 'Laporan',
          ),
          Divider(height: 1),
          MenuTile(
            icon: Icons.settings,
            title: 'Pengaturan',
          ),
          Divider(height: 1),
          MenuTile(
            icon: Icons.book,
            title: 'Panduan Pengguna',
          ),
          Divider(height: 1),
          MenuTile(
            icon: Icons.info,
            title: 'Tentang Aplikasi',
          ),
          Divider(height: 1),
          MenuTile(
            icon: Icons.logout,
            title: 'Keluar',
            textColor: Colors.red,
            iconColor: Colors.red,
          ),
        ],
      ),
    );
  }
}

class MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color? textColor;
  final Color? iconColor;

  const MenuTile({
    super.key,
    required this.icon,
    required this.title,
    this.textColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? Colors.black,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? Colors.black,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: Colors.grey,
      ),
      onTap: () {
        // Tambahkan navigasi di sini
      },
    );
  }
}