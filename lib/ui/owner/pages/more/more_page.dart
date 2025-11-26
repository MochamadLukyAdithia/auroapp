import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_mobile/core/theme/theme.dart';
import 'package:pos_mobile/ui/owner/pages/more/profile_cashier/profile_cashier.dart';
import 'package:pos_mobile/ui/owner/pages/more/stocks/stock_page.dart';
import '../../../../blocs/auth/login/login_bloc.dart';
import '../../../../blocs/auth/login/login_event.dart';
import '../../../../blocs/cashier/cashier_bloc.dart';
import '../../../../blocs/product/product_bloc.dart';
import '../../../../route/route.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../../core/utils/auth_service.dart';

class MorePage extends StatefulWidget {
  const MorePage({super.key});

  @override
  State<MorePage> createState() => _MorePageState();
}

class _MorePageState extends State<MorePage> {
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
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: const CustomAppBar(title: 'Lainnya'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        children: [
          // ==========================
          //         MENU OWNER
          // ==========================
          if (_isOwner) ...[
            MenuTile(
              icon: Icons.group,
              title: 'Kelola pelanggan',
              onTap: () => Navigator.pushNamed(context, AppRoutes.customer),
            ),
            const Divider(height: 1),

            MenuTile(
              icon: Icons.inventory_2_outlined,
              title: 'Kelola Stok',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: context.read<ProductBloc>(),
                      child: const StockPage(),
                    ),
                  ),
                );
              },
            ),
            const Divider(height: 1),

            MenuTile(
              icon: Icons.receipt_long,
              title: 'Laporan',
              onTap: () => Navigator.pushNamed(context, AppRoutes.report),
            ),
            const Divider(height: 1),

            MenuTile(
              icon: Icons.settings,
              title: 'Pengaturan',
              onTap: () => Navigator.pushNamed(context, AppRoutes.setting),
            ),
            const Divider(height: 1),
          ],

          // ==========================
          //        MENU CASHIER
          // ==========================
          if (!_isOwner) ...[
            MenuTile(
              icon: Icons.group,
              title: 'Kelola pelanggan',
              onTap: () => Navigator.pushNamed(context, AppRoutes.customer),
            ),
            const Divider(height: 1),

            // 🆕 PROFILE - Hanya untuk cashier
            MenuTile(
              icon: Icons.person,
              title: 'Profil',
              onTap: () {
                // Navigasi ke halaman ProfileCashier
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlocProvider.value(
                      value: context.read<CashierBloc>(),
                      child: const ProfileCashier(),
                    ),
                  ),
                );
              },
            ),
            const Divider(height: 1),

            MenuTile(
              icon: Icons.receipt_long,
              title: 'Laporan',
              onTap: () => Navigator.pushNamed(context, AppRoutes.report),
            ),
            const Divider(height: 1),
          ],

          // ==========================
          //       MENU BERSAMA
          // ==========================

          MenuTile(
            icon: Icons.book,
            title: 'Panduan Pengguna',
            onTap: () => Navigator.pushNamed(context, AppRoutes.guide),
          ),
          const Divider(height: 1),

          MenuTile(
            icon: Icons.info,
            title: 'Tentang Aplikasi',
            onTap: () => Navigator.pushNamed(context, AppRoutes.about),
          ),
          const Divider(height: 1),

          // ==========================
          //         LOGOUT
          // ==========================
          MenuTile(
            icon: Icons.logout,
            title: 'Keluar',
            textColor: Colors.red,
            iconColor: Colors.red,
            onTap: () => _showLogoutDialog(context),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    size: 40,
                    color: Colors.red,
                  ),
                ),

                const SizedBox(height: 24),

                // Title
                const Text(
                  'Keluar dari Akun?',
                  style: TextStyle(
                    fontFamily: fontType,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 12),

                // Description
                const Text(
                  'Apakah kamu yakin ingin keluar dari akun ini? Kamu harus login kembali untuk mengakses aplikasi.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: fontType,
                    fontSize: 14,
                    color: Colors.grey,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 28),

                // Buttons
                Row(
                  children: [
                    // Batal Button
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: Colors.grey, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Batal',
                          style: TextStyle(
                            fontFamily: fontType,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Keluar Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          context.read<LoginBloc>().add(const LogoutRequested());
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            AppRoutes.login,
                                (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Ya, Keluar',
                          style: TextStyle(
                            fontFamily: fontType,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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