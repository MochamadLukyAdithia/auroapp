import 'package:flutter/material.dart';
import '../../../../../route/route.dart';
import '../../../../widgets/custom_app_bar.dart';



class ReportPage extends StatelessWidget {
  const ReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Laporan'),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
        children: [
          MenuTile(
            icon: Icons.group,
            title: 'Laporan Transaksi Penjualan',
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.salesReport);
            },
          ),
          const Divider(height: 1),

          MenuTile(
            icon: Icons.business,
            title: 'Laporan Pengeluaran',
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.expenditureReport);
            },
          ),
          const Divider(height: 1),

          MenuTile(
            icon: Icons.shopping_cart,
            title: 'Laporan Arus Kas',
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.flowReport);
            },
          ),
          const Divider(height: 1),
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
