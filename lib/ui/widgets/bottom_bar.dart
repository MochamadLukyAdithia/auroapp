import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';
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
  int currentIndex = 2; // Default ke POS (index 2)

  final List<Widget> body = [
    const Homepage(),
    const ProductCategoryPage(),
    const TransactionPage(), // POS
    const FinancePage(),
    const MorePage(),
  ];

  // Data icon: [outline, filled, label]
  final List<Map<String, dynamic>> iconData = [
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


  List<Widget> get icon {
    return List.generate(iconData.length, (index) {
      final isActive = currentIndex == index;
      final isPOS = index == 2; // POS di tengah

      // Kalau POS, bikin khusus (besar, fluid)
      if (isPOS) {
        return Container(
          width: 60,
          height: 60,
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
            isActive ? iconData[index]['filled'] : iconData[index]['outline'],
            color: Colors.white,
            size: 32,
          ),
        );
      }

      return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isActive ? iconData[index]['filled'] : iconData[index]['outline'],
            color: isActive ? primaryGreenColor : Colors.grey,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            iconData[index]['label'],
            style: TextStyle(
              fontSize: 10,
              color: isActive ? primaryGreenColor : Colors.grey,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: body[currentIndex],
      bottomNavigationBar: Stack(
        clipBehavior: Clip.none, // Biar POS bisa keluar dari container
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
                final isPOS = index == 2;

                // POS: bikin placeholder kosong
                if (isPOS) {
                  return const SizedBox(width: 60); // Placeholder
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
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
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
            bottom: 30, // Seberapa tinggi mau naik (adjust sesuai selera)
            child: GestureDetector(
              onTap: () => onTap(2),
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
                  iconData[2]['filled'],
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

  void onTap(index) {
    setState(() {
      currentIndex = index;
    });
  }
}