// pages/product/product_filter_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../blocs/product/product_cubit.dart';

class ProductFilterPage extends StatefulWidget {
  final ProductFilterState currentFilter;

  const ProductFilterPage({
    super.key,
    required this.currentFilter,
  });

  @override
  State<ProductFilterPage> createState() => _ProductFilterPageState();
}

class _ProductFilterPageState extends State<ProductFilterPage> {
  late SortType selectedSort;
  late StockFilterType selectedStock;

  @override
  void initState() {
    super.initState();
    selectedSort = widget.currentFilter.sortBy;
    selectedStock = widget.currentFilter.stockStatus;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Filter Produk',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                selectedSort = SortType.newest;
                selectedStock = StockFilterType.all;
              });
            },
            child: const Text(
              'Reset',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 📊 SORT SECTION
                  _buildSectionHeader('Urutkan Berdasarkan'),
                  _buildSortOption(
                    title: 'Terbaru',
                    value: SortType.newest,
                    icon: Icons.new_releases_outlined,
                  ),
                  _buildSortOption(
                    title: 'Terlama',
                    value: SortType.oldest,
                    icon: Icons.history,
                  ),
                  _buildSortOption(
                    title: 'Nama (A-Z)',
                    value: SortType.nameAsc,
                    icon: Icons.sort_by_alpha,
                  ),
                  _buildSortOption(
                    title: 'Nama (Z-A)',
                    value: SortType.nameDesc,
                    icon: Icons.sort_by_alpha,
                  ),
                  _buildSortOption(
                    title: 'Kode (A-Z)',
                    value: SortType.codeAsc,
                    icon: Icons.qr_code,
                  ),
                  _buildSortOption(
                    title: 'Kode (Z-A)',
                    value: SortType.codeDesc,
                    icon: Icons.qr_code,
                  ),
                  _buildSortOption(
                    title: 'Harga Terendah',
                    value: SortType.priceAsc,
                    icon: Icons.arrow_downward,
                  ),
                  _buildSortOption(
                    title: 'Harga Tertinggi',
                    value: SortType.priceDesc,
                    icon: Icons.arrow_upward,
                  ),
                  _buildSortOption(
                    title: 'Stok Terendah',
                    value: SortType.stockAsc,
                    icon: Icons.inventory_2_outlined,
                  ),
                  _buildSortOption(
                    title: 'Stok Tertinggi',
                    value: SortType.stockDesc,
                    icon: Icons.inventory_outlined,
                  ),

                  const SizedBox(height: 8),
                  const Divider(height: 1),

                  // 📦 STOCK STATUS SECTION
                  _buildSectionHeader('Status Stok'),
                  _buildStockOption(
                    title: 'Semua Produk',
                    value: StockFilterType.all,
                    icon: Icons.apps,
                  ),
                  _buildStockOption(
                    title: 'Tersedia (>10)',
                    value: StockFilterType.available,
                    icon: Icons.check_circle_outline,
                    color: Colors.green,
                  ),
                  _buildStockOption(
                    title: 'Menipis (1-10)',
                    value: StockFilterType.low,
                    icon: Icons.warning_amber_outlined,
                    color: Colors.orange,
                  ),
                  _buildStockOption(
                    title: 'Habis (0)',
                    value: StockFilterType.empty,
                    icon: Icons.remove_circle_outline,
                    color: Colors.red,
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),

          // 🔘 APPLY BUTTON
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    final newFilter = ProductFilterState(
                      sortBy: selectedSort,
                      stockStatus: selectedStock,
                    );
                    Navigator.pop(context, newFilter);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Terapkan Filter',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black54,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSortOption({
    required String title,
    required SortType value,
    required IconData icon,
  }) {
    final isSelected = selectedSort == value;
    return InkWell(
      onTap: () {
        setState(() {
          selectedSort = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2E7D32).withOpacity(0.08) : null,
          border: Border(
            left: BorderSide(
              color: isSelected ? const Color(0xFF2E7D32) : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected ? const Color(0xFF2E7D32) : Colors.grey[600],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? const Color(0xFF2E7D32) : Colors.black87,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF2E7D32),
                size: 22,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockOption({
    required String title,
    required StockFilterType value,
    required IconData icon,
    Color? color,
  }) {
    final isSelected = selectedStock == value;
    final displayColor = color ?? Colors.grey[600];

    return InkWell(
      onTap: () {
        setState(() {
          selectedStock = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? displayColor?.withOpacity(0.08) : null,
          border: Border(
            left: BorderSide(
              color: isSelected ? displayColor! : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected ? displayColor : Colors.grey[600],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? displayColor : Colors.black87,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: displayColor,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}



class ActiveFilterChips extends StatelessWidget {
  final ProductFilterState filterState;

  const ActiveFilterChips({
    super.key,
    required this.filterState,
  });

  @override
  Widget build(BuildContext context) {
    if (!filterState.hasActiveFilter) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          // Sort Chip - hanya muncul jika bukan default (newest)
          if (filterState.sortBy != SortType.newest)
            _buildFilterChip(
              context: context,
              label: filterState.sortLabel,
              icon: _getSortIcon(filterState.sortBy),
              onDelete: () {
                // Reset HANYA sort ke default
                final newFilter = filterState.copyWith(
                  sortBy: SortType.newest,
                );
                context.read<ProductSearchCubit>().applyFilter(newFilter);
              },
            ),

          // Stock Status Chip - hanya muncul jika bukan default (all)
          if (filterState.stockStatus != StockFilterType.all)
            _buildFilterChip(
              context: context,
              label: filterState.stockLabel,
              icon: _getStockIcon(filterState.stockStatus),
              color: _getStockColor(filterState.stockStatus),
              onDelete: () {
                // Reset HANYA stock status ke default
                final newFilter = filterState.copyWith(
                  stockStatus: StockFilterType.all,
                );
                context.read<ProductSearchCubit>().applyFilter(newFilter);
              },
            ),

          // Clear All Button - hanya muncul jika ada filter aktif
          if (filterState.hasActiveFilter)
            _buildClearAllChip(context),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required BuildContext context,
    required String label,
    required IconData icon,
    Color? color,
    required VoidCallback onDelete,
  }) {
    final chipColor = color ?? const Color(0xFF2E7D32);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: chipColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: chipColor,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: chipColor,
            ),
          ),
          const SizedBox(width: 4),
          InkWell(
            onTap: onDelete,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: Icon(
                Icons.close,
                size: 16,
                color: chipColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClearAllChip(BuildContext context) {
    return InkWell(
      onTap: () {
        context.read<ProductSearchCubit>().resetFilter();
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.red.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.clear_all,
              size: 16,
              color: Colors.red,
            ),
            const SizedBox(width: 6),
            const Text(
              'Hapus Semua',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getSortIcon(SortType type) {
    switch (type) {
      case SortType.newest:
        return Icons.new_releases_outlined;
      case SortType.oldest:
        return Icons.history;
      case SortType.nameAsc:
      case SortType.nameDesc:
        return Icons.sort_by_alpha;
      case SortType.codeAsc:
      case SortType.codeDesc:
        return Icons.qr_code;
      case SortType.priceAsc:
        return Icons.arrow_downward;
      case SortType.priceDesc:
        return Icons.arrow_upward;
      case SortType.stockAsc:
        return Icons.inventory_2_outlined;
      case SortType.stockDesc:
        return Icons.inventory_outlined;
    }
  }

  IconData _getStockIcon(StockFilterType type) {
    switch (type) {
      case StockFilterType.available:
        return Icons.check_circle_outline;
      case StockFilterType.low:
        return Icons.warning_amber_outlined;
      case StockFilterType.empty:
        return Icons.remove_circle_outline;
      case StockFilterType.all:
      default:
        return Icons.apps;
    }
  }

  Color _getStockColor(StockFilterType type) {
    switch (type) {
      case StockFilterType.available:
        return Colors.green;
      case StockFilterType.low:
        return Colors.orange;
      case StockFilterType.empty:
        return Colors.red;
      case StockFilterType.all:
      default:
        return Colors.grey;
    }
  }
}