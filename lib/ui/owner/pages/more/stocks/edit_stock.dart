// ui/owner/pages/stock/edit_stock_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pos_mobile/ui/widgets/floating_message.dart';
import '../../../../../blocs/history_stock/stock_bloc.dart';
import '../../../../../blocs/history_stock/stock_event.dart';
import '../../../../../blocs/history_stock/stock_state.dart';
import '../../../../../blocs/product/product_bloc.dart';
import '../../../../../blocs/product/product_event.dart';
import '../../../../../blocs/product/product_state.dart';
import '../../../../../core/theme/theme.dart';
import '../../../../../data/models/product_model.dart';
import '../../../../../data/models/stock_history_model.dart';
import '../../../../../data/repositories/stock_history_repository.dart';
import '../../../../widgets/custom_app_bar.dart';


class EditStockPage extends StatefulWidget {
  final ProductModel product;

  const EditStockPage({super.key, required this.product});

  @override
  State<EditStockPage> createState() => _EditStockPageState();
}

class _EditStockPageState extends State<EditStockPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);

  }

  void _onTabChanged() {
    if (!mounted) return;
    if (_tabController.indexIsChanging) return;

    if (_tabController.index == 1) {
      context.read<StockBloc>().add(LoadStockHistory(productId: widget.product.id!));
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => StockBloc(context.read<StockRepository>()),
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'Kelola Stok',
          tabs: const ['Kelola', 'Riwayat'],
          tabController: _tabController,
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            ManageStockTab(product: widget.product),
            StockHistoryTab(product: widget.product),
          ],
        ),
      ),
    );
  }
}

// ==================== MANAGE STOCK TAB ====================

class ManageStockTab extends StatelessWidget {
  final ProductModel product;

  const ManageStockTab({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Info Card
          ProductInfoCard(product: product),
          const SizedBox(height: 24),

          // Stock In Section
          StockActionSection(
            title: 'Stok Masuk',
            icon: Icons.add_box,
            iconColor: primaryGreenColor,
            buttonLabel: 'Tambah Stok',
            buttonColor: primaryGreenColor,
            product: product,
            actionType: StockActionType.stockIn,
          ),
          const SizedBox(height: 16),

          // Stock Out Section
          StockActionSection(
            title: 'Stok Keluar',
            icon: Icons.remove_circle_outline,
            iconColor: Colors.orange,
            buttonLabel: 'Kurangi Stok',
            buttonColor: Colors.orange,
            product: product,
            actionType: StockActionType.stockOut,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class ProductInfoCard extends StatelessWidget {
  final ProductModel product;

  const ProductInfoCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryGreenColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryGreenColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.inventory_2,
                  color: primaryGreenColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.productName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Kode: ${product.productCode}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Stok Saat Ini',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              BlocBuilder<ProductBloc, ProductState>(
                builder: (context, state) {
                  int? currentStock = product.productStock;
                  if (state is ProductLoaded) {
                    final updatedProduct = state.products.firstWhere(
                          (p) => p.id == product.id,
                      orElse: () => product,
                    );
                    currentStock = updatedProduct.productStock;
                  }
                  return Text(
                    '$currentStock ${product.productUnits}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: primaryGreenColor,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}


enum StockActionType { stockIn, stockOut}

class StockActionSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final String buttonLabel;
  final Color buttonColor;
  final ProductModel product;
  final StockActionType actionType;

  const StockActionSection({
    super.key,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.buttonLabel,
    required this.buttonColor,
    required this.product,
    required this.actionType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey[300]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontFamily: fontType,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showStockDialog(context, actionType),
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                shadowColor: buttonColor.withOpacity(0.4),
                elevation: 3,
              ),
              child: Text(
                buttonLabel,
                style: TextStyle(
                  fontFamily: fontType,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showStockDialog(BuildContext context, StockActionType type) {
    final quantityController = TextEditingController();
    final notesController = TextEditingController();
    final stockBloc = context.read<StockBloc>();

    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: stockBloc,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          titlePadding: const EdgeInsets.only(top: 20, left: 20, right: 20),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          backgroundColor: Colors.white,
          title: Row(
            children: [
              Icon(
                type == StockActionType.stockIn
                    ? Icons.add_box_rounded
                    : Icons.indeterminate_check_box_rounded,
                color: type == StockActionType.stockIn
                    ? primaryGreenColor
                    : Colors.redAccent,
              ),
              const SizedBox(width: 8),
              Text(
                type == StockActionType.stockIn ? 'Tambah Stok' : 'Kurangi Stok',
                style: const TextStyle(
                  fontFamily: fontType,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          // ✅ TAMBAHKAN INI - Content yang hilang!
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Input Jumlah
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: 'Jumlah',
                  hintText: 'Masukkan jumlah',
                  suffixText: product.productUnits,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: primaryGreenColor, width: 1.4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Input Keterangan
              TextField(
                controller: notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Keterangan',
                  hintText: 'Tambahkan keterangan',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: primaryGreenColor, width: 1.4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.only(right: 16, bottom: 10, left: 16),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Batal',
                style: TextStyle(
                  fontFamily: fontType,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            BlocConsumer<StockBloc, StockState>(
              listener: (context, state) {
                if (state is StockActionSuccess) {
                  Navigator.pop(dialogContext);
                  context.read<ProductBloc>().add(const LoadProducts());
                  FloatingMessage.show(
                    context,
                    message: state.message,
                    backgroundColor: primaryGreenColor,
                  );
                } else if (state is StockError) {
                  FloatingMessage.show(
                    context,
                    message: state.message,
                    backgroundColor: Colors.redAccent,
                    position: FloatingMessagePosition.bottom,
                  );
                }
              },
              builder: (context, state) {
                return ElevatedButton(
                  onPressed: state is StockLoading
                      ? null
                      : () {
                    final quantity = int.tryParse(quantityController.text);
                    final notes = notesController.text.trim();

                    if (quantity == null || quantity <= 0) {
                      FloatingMessage.show(
                        context,
                        textOnly: true,
                        message: "Jumlah tidak valid",
                        position: FloatingMessagePosition.bottom,
                      );
                      return;
                    }

                    if (notes.isEmpty) {
                      FloatingMessage.show(
                        context,
                        textOnly: true,
                        message: "Deskripsi tidak boleh kosong",
                        position: FloatingMessagePosition.bottom,
                      );
                      return;
                    }

                    switch (type) {
                      case StockActionType.stockIn:
                        stockBloc.add(AddStockIn(
                          productId: product.id!,
                          quantity: quantity,
                          notes: notes,
                        ));
                        break;
                      case StockActionType.stockOut:
                        stockBloc.add(AddStockOut(
                          productId: product.id!,
                          quantity: quantity,
                          notes: notes,
                        ));
                        break;
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: state is StockLoading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : Text(
                    'Simpan',
                    style: const TextStyle(
                      fontFamily: fontType,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// 🧩 Widget Kecil untuk TextField agar lebih clean
class _CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final String? suffix;
  final int maxLines;
  final TextInputType? keyboardType;

  const _CustomTextField({
    required this.controller,
    required this.label,
    required this.hint,
    this.suffix,
    this.maxLines = 1,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: keyboardType == TextInputType.number
          ? [FilteringTextInputFormatter.digitsOnly]
          : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixText: suffix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: primaryGreenColor, width: 1.4),
          borderRadius: BorderRadius.circular(10),
        ),
        labelStyle: TextStyle(
          fontFamily: fontType,
          color: Colors.grey[800],
        ),
      ),
    );
  }
}



// ==================== STOCK HISTORY TAB ====================
class StockHistoryTab extends StatefulWidget {
  final ProductModel product;
  const StockHistoryTab({super.key, required this.product});

  @override
  State<StockHistoryTab> createState() => _StockHistoryTabState();
}

class _StockHistoryTabState extends State<StockHistoryTab> {

  @override
  void initState() {
    super.initState();
    context.read<StockBloc>().add(LoadStockHistory(productId: widget.product.id!));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StockBloc, StockState>(
      builder: (context, state) {
        if (state is StockLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is StockHistoryEmpty) {
          return const EmptyHistoryWidget();
        } else if (state is StockHistoryLoaded) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.history.length,
            itemBuilder: (context, index) {
              final history = state.history[index];
              return StockHistoryCard(history: history);
            },
          );
        } else if (state is StockError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(state.message, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context
                        .read<StockBloc>()
                        .add(LoadStockHistory(productId: widget.product.id!));
                  },
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          );
        }
        return const EmptyHistoryWidget();
      },
    );
  }
}

class StockHistoryCard extends StatelessWidget {
  final StockHistoryModel history; // ✅ FIX: Tambahkan tipe yang benar

  const StockHistoryCard({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    // ✅ FIX: Sesuaikan dengan field di StockHistoryModel
    final isIncrease = history.stockIn > 0; // stockIn > 0 = tambah, stockOut > 0 = kurang
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');
    final quantityChange = isIncrease ? history.stockIn : -history.stockOut;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isIncrease
                          ? primaryGreenColor.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isIncrease ? Icons.arrow_downward : Icons.arrow_upward,
                      color: isIncrease ? primaryGreenColor : Colors.red,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isIncrease ? 'Stok Masuk' : 'Stok Keluar',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Text(
                '${isIncrease ? '+' : ''}$quantityChange',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isIncrease ? primaryGreenColor : Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Stok Sebelum',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Text(
                '${history.initialStock}', // ✅ FIX: initialStock
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Stok Sesudah',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Text(
                '${history.finalStock}', // ✅ FIX: finalStock
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          if (history.stockDescription != null && history.stockDescription!.isNotEmpty) ...[
            const Divider(height: 16),
            Text(
              history.stockDescription!,
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
          ],
          const Divider(height: 16),
          Text(
            dateFormat.format(history.historyStockDate),
            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}

class EmptyHistoryWidget extends StatelessWidget {
  const EmptyHistoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada riwayat',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Riwayat pergerakan stok akan muncul di sini',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}