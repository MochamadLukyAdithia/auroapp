import 'package:flutter/material.dart';
import '../../../../../core/utils/auth_service.dart';
import '../../../../../route/route.dart';
import '../../../../widgets/custom_app_bar.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  bool _isOwner = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkRole();
  }

  Future<void> _checkRole() async {
    final isOwner = await AuthService.isOwner();
    setState(() {
      _isOwner = isOwner;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        appBar: CustomAppBar(title: 'Laporan'),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: const CustomAppBar(title: 'Laporan'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        children: [
          // ✅ Laporan Transaksi Penjualan - SEMUA ROLE bisa akses
          MenuTile(
            icon: Icons.group,
            title: 'Laporan Transaksi Penjualan',
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.salesReport);
            },
          ),
          const Divider(height: 1),

          // ✅ Menu di bawah ini HANYA untuk OWNER
          if (_isOwner) ...[
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
