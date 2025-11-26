import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';
import '../../core/utils/auth_service.dart';
import '../owner/pages/finances/finance_page.dart';
import '../owner/pages/homepage.dart';
import '../owner/pages/more/more_page.dart';
import '../owner/pages/products_categories/product_category.dart';
import '../owner/pages/transactions/transaction_page.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({super.key});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int currentIndex = 0; // ✅ Ubah ke 0 (Beranda default)
  bool _isOwner = true;
  bool _isLoading = true; // ✅ Tambah loading state

  @override
  void initState() {
    super.initState();
    _checkRole();
  }

  Future<void> _checkRole() async {
    final isOwner = await AuthService.isOwner();
    setState(() {
      _isOwner = isOwner;
      _isLoading = false; // ✅ Loading selesai
      // ✅ Reset index jika cashier (karena menu lebih sedikit)
      if (!isOwner && currentIndex >= 3) {
        currentIndex = 0;
      }
    });
  }

  // 👤 OWNER - 5 Menu (Full Access)
  final List<Widget> _ownerPages = [
    const Homepage(),
    const ProductCategoryPage(),
    const TransactionPage(), // POS
    const FinancePage(),
    const MorePage(),
  ];

  // 🧑‍💼 CASHIER - 3 Menu (Limited Access)
  final List<Widget> _cashierPages = [
    const Homepage(),
    const TransactionPage(), // POS (index 1 untuk cashier)
    const MorePage(),
  ];

  // 👤 OWNER - Icon Data (5 menu)
  final List<Map<String, dynamic>> _ownerIconData = [
    {
      'outline': Icons.home_outlined,
      'filled': Icons.home_rounded,
      'label': 'Beranda'
    },
    {
      'outline': Icons.inventory_2_outlined,
      'filled': Icons.inventory_2_rounded,
      'label': 'Produk'
    },
    {
      'outline': Icons.point_of_sale_outlined,
      'filled': Icons.point_of_sale_rounded,
      'label': 'POS'
    },
    {
      'outline': Icons.account_balance_wallet_outlined,
      'filled': Icons.account_balance_wallet_rounded,
      'label': 'Keuangan'
    },
    {
      'outline': Icons.more_horiz_outlined,
      'filled': Icons.more_horiz_rounded,
      'label': 'Lainnya'
    },
  ];

  // 🧑‍💼 CASHIER - Icon Data (3 menu)
  final List<Map<String, dynamic>> _cashierIconData = [
    {
      'outline': Icons.home_outlined,
      'filled': Icons.home_rounded,
      'label': 'Beranda'
    },
    {
      'outline': Icons.point_of_sale_outlined,
      'filled': Icons.point_of_sale_rounded,
      'label': 'POS'
    },
    {
      'outline': Icons.more_horiz_outlined,
      'filled': Icons.more_horiz_rounded,
      'label': 'Lainnya'
    },
  ];

  @override
  Widget build(BuildContext context) {
    // ✅ Tampilkan loading saat cek role
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // ✅ Tentukan data berdasarkan role
    final pages = _isOwner ? _ownerPages : _cashierPages;
    final iconData = _isOwner ? _ownerIconData : _cashierIconData;
    final posIndex = _isOwner ? 2 : 1; // POS index berbeda untuk owner & cashier

    return Scaffold(
      extendBody: true,
      body: pages[currentIndex],
      bottomNavigationBar: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          // Bottom bar background
          Container(
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(iconData.length, (index) {
                final isActive = currentIndex == index;
                final isPOS = index == posIndex;

                // POS: bikin placeholder kosong (floating button)
                if (isPOS) {
                  return const SizedBox(width: 60);
                }

                // Menu lainnya
                return GestureDetector(
                  onTap: () => onTap(index),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isActive
                            ? iconData[index]['filled']
                            : iconData[index]['outline'],
                        color: isActive ? primaryGreenColor : Colors.grey,
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        iconData[index]['label'],
                        style: TextStyle(
                          fontSize: 10,
                          color: isActive ? primaryGreenColor : Colors.grey,
                          fontWeight:
                          isActive ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),

          // POS button (floating di atas)
          Positioned(
            bottom: 30,
            child: GestureDetector(
              onTap: () => onTap(posIndex), // ✅ Dynamic POS index
              child: Container(
                width: 65,
                height: 65,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryGreenColor,
                  boxShadow: [
                    BoxShadow(
                      color: primaryGreenColor.withOpacity(0.3),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  iconData[posIndex]['filled'],
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void onTap(int index) {
    setState(() {
      currentIndex = index;
    });
  }
}