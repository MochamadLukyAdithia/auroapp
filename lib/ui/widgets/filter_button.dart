// ui/widgets/filter_button.dart
import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';

class FilterButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool hasActiveFilter;

  const FilterButton({
    super.key,
    required this.onTap,
    this.hasActiveFilter = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: primaryGreenColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: primaryGreenColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.filter_list,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
        if (hasActiveFilter)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const SizedBox(
                width: 6,
                height: 6,
              ),
            ),
          ),
      ],
    );
  }
}