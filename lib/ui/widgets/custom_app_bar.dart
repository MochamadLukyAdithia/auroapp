import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:pos_mobile/core/theme/theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<String>? tabs;
  final TabController? tabController;

  const CustomAppBar({
    super.key,
    required this.title,
    this.tabs,
    this.tabController,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: primaryGreenColor,
      foregroundColor: Colors.white,
      elevation: 0,
      titleSpacing: 16,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: AutoSizeText(
              title,
              style: const TextStyle(
                fontSize: 22, // font maksimal
                fontWeight: FontWeight.w700,
                fontFamily: 'Segoe',
              ),
              maxLines: 1,
              minFontSize: 12,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'Auro',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              fontFamily: 'Segoe',
            ),
          ),
        ],
      ),
      bottom: tabs != null
          ? TabBar(
        controller: tabController,
        tabs: tabs!
            .map(
              (t) => Tab(
            text: t,
          ),
        )
            .toList(),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        indicatorColor: Colors.white,
        indicatorWeight: 3,
        labelStyle: const TextStyle(
          fontFamily: 'Segoe',
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Segoe',
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
      )
          : null,
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(tabs != null ? 112 : 66);
}