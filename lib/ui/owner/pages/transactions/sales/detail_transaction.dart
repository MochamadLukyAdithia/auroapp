import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_mobile/blocs/transaction/transaction_cubit.dart';
import 'package:pos_mobile/route/route.dart';
import 'package:pos_mobile/ui/widgets/custom_app_bar.dart';
import '../../../../../blocs/customer/customer_bloc.dart';
import '../../../../../blocs/customer/customer_event.dart';
import '../../../../../blocs/customer/customer_state.dart';
import '../../../../../blocs/transaction/transaction_state.dart';
import '../../../../../core/theme/theme.dart';
import '../../../../../data/models/customer_model.dart';
import '../../../../widgets/floating_message.dart';
import 'detail_payment.dart';

class DetailTransaction extends StatelessWidget {
  const DetailTransaction({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<TransactionCubit, TransactionState>(
        listener: (context, state) {
          // ✅ Auto close jika tidak ada item
          if (state.selectedItems.isEmpty) {
            Navigator.pop(context);
          }
        },
    child: Scaffold(
      extendBody: true,
      backgroundColor: Colors.grey.shade50,
      appBar: const CustomAppBar(title: 'Rincian Pembayaran'),
      body: Column(
        children: [
          const CustomerSelectionButton(),
          const Expanded(child: ItemListSection()),
          const TransactionSummarySection(),
          const BottomActionButtons(),
          BlocBuilder<TransactionCubit, TransactionState>(
            builder: (context, state) {
              final totalQty = state.selectedItems.fold<int>(
                0,
                    (sum, product) => sum + state.getQuantity(product.id.toString()),
              );

              return PaymentButton(
                onPressed: () {
                  // VALIDASI STOK SEBELUM LANJUT
                  bool hasStockIssue = false;
                  String? errorMessage;

                  for (var product in state.selectedItems) {
                    final qty = state.getQuantity(product.id.toString());
                    final stock = product.productStock;

                    // Cek jika produk punya tracking stok
                    if (qty > stock!) {
                      hasStockIssue = true;
                      errorMessage = 'Stok ${product.productName} tidak mencukupi!\n'
                          'Tersedia: $stock, Dipilih: $qty';
                      break;
                    }
                  }

                  // Show error jika ada masalah stok
                  if (hasStockIssue) {
                    FloatingMessage.show(context, message: errorMessage, backgroundColor: Colors.red);
                    return;
                  }
                  // Stok valid, lanjut ke payment
                  final transactionCubit = context.read<TransactionCubit>();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: transactionCubit,
                        child: const DetailPayment(),
                      ),
                    ),
                  );
                },
                quantity: totalQty,
                price: 'Rp ${state.finalTotal}',
                label: 'Bayar',
              );
            },
          ),
        ],
      ),
    ));
  }
}

// pilih pelanggan
class CustomerSelectionButton extends StatelessWidget {
  const CustomerSelectionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionCubit, TransactionState>(
      builder: (context, state) {
        final selectedCustomer = state.selectedCustomer;

        return InkWell(
          onTap: () async {
            final result = await Navigator.pushNamed(
              context,
              AppRoutes.customerSelection,
            );

            if (context.mounted && result != null && result is Customer) {
              // ✅ Set ke TransactionCubit
              context.read<TransactionCubit>().setSelectedCustomer(result);

              // ✅ PENTING: Pastikan customer ada di CustomerBloc
              final customerBloc = context.read<CustomerBloc>();
              final customerState = customerBloc.state;

              // Check apakah customer sudah ada di list
              if (customerState is CustomerLoaded) {
                final exists = customerState.customers.any((c) =>
                c.phone == result.phone || c.email == result.email
                );

                // Jika belum ada, tambahkan
                if (!exists) {
                  customerBloc.add(AddCustomer(result));
                }
              }
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  selectedCustomer != null
                      ? Icons.person
                      : Icons.person_add_outlined,
                  color: primaryGreenColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    selectedCustomer != null
                        ? selectedCustomer.name
                        : 'Pilih Pelanggan',
                    style: const TextStyle(
                      fontFamily: fontType,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: primaryGreenColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // ✅ Tambah tombol clear kalau ada customer
                if (selectedCustomer != null) ...[
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      context.read<TransactionCubit>().clearSelectedCustomer();
                    },
                    child: const Icon(
                      Icons.close,
                      size: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

// listnya
class ItemListSection extends StatelessWidget {
  const ItemListSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionCubit, TransactionState>(
      builder: (context, state) {
        final selectedProducts = state.selectedItems
            .where((product) => state.getQuantity(product.id.toString()) > 0)
            .toList();

        if (selectedProducts.isEmpty) {
          return const Center(
            child: Text(
              'Belum ada item ditambahkan',
              style: TextStyle(
                fontFamily: fontType,
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: selectedProducts.length,
          itemBuilder: (context, index) {
            final product = selectedProducts[index];
            final quantity = state.getQuantity(product.id.toString());
            final isSelected = state.selectedProductIds.contains(product.id.toString());
            final isSelectionMode = state.isSelectionMode;

            // Existing calculations
            final hasProductDiscount = product.productDiscount > 0;
            final priceAfterDiscount = product.sellingPrice * (1 - product.productDiscount / 100);
            final totalPrice = priceAfterDiscount * quantity;
            final currentStock = product.productStock ?? 0;
            final isOverStock = product.productStock != null && quantity > currentStock;

            return GestureDetector(
              // Long press
              onLongPress: () {
                if (!isSelectionMode) {
                  context.read<TransactionCubit>().toggleSelectionMode();
                }
                context.read<TransactionCubit>().toggleProductSelection(product.id.toString());
              },
              // Tap untuk toggle selection jika sudah dalam mode selection
              onTap: isSelectionMode
                  ? () => context.read<TransactionCubit>().toggleProductSelection(product.id.toString())
                  : null,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected ? primaryGreenColor.withOpacity(0.1) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? primaryGreenColor
                        : (isOverStock ? Colors.red.shade300 : Colors.grey.shade200),
                    width: isSelected ? 2 : (isOverStock ? 1.5 : 1),
                  ),
                ),
                child: ListTile(
                    // ✅ Gunakan conditional yang lebih eksplisit
                    leading: isSelectionMode
                        ? Checkbox(
                      value: isSelected,
                      onChanged: (_) {
                        context.read<TransactionCubit>().toggleProductSelection(product.id.toString());
                      },
                      activeColor: primaryGreenColor,
                    )
                        : null, // ✅ Gunakan null, bukan SizedBox

                    // ✅ PENTING: Tambahkan key agar Flutter tau ini widget berbeda
                    key: ValueKey('product_${product.id}_$isSelectionMode'),

                    contentPadding: EdgeInsets.symmetric(
                      horizontal: isSelectionMode ? 8 : 16,
                      vertical: 8,
                    ),
                  // ... rest of ListTile content (title, subtitle, trailing) tetap sama
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          product.productName,
                          style: const TextStyle(
                            fontFamily: fontType,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      if (isOverStock)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.shade500,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Stok Habis',
                            style: TextStyle(
                              fontFamily: fontType,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(
                            '$quantity × ${priceAfterDiscount.toInt()}',
                            style: const TextStyle(
                              fontFamily: fontType,
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      if (hasProductDiscount) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: Colors.orange.shade200,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.local_offer,
                                    size: 10,
                                    color: Colors.orange.shade700,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    'Diskon ${product.productDiscount.toInt()}%',
                                    style: TextStyle(
                                      fontFamily: fontType,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.orange.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Hemat ${((product.sellingPrice - priceAfterDiscount) * quantity).toInt()}',
                              style: TextStyle(
                                fontFamily: fontType,
                                fontSize: 10,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                  trailing: Text(
                    '${totalPrice.toInt()}',
                    style: const TextStyle(
                      fontFamily: fontType,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}


// trio button dibawah
class BottomActionButtons extends StatelessWidget {
  const BottomActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionCubit, TransactionState>(
      builder: (context, state) {
        final isSelectionMode = state.isSelectionMode;
        final selectedCount = state.selectedProductIds.length;
        final hasSelection = selectedCount > 0;

        // 🆕 Jika dalam selection mode, tampilkan UI berbeda
        if (isSelectionMode) {
          return Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            decoration: BoxDecoration(
              color: primaryGreenColor.withOpacity(0.1),
              border: const Border(
                top: BorderSide(color: primaryGreenColor, width: 2),
              ),
            ),
            child: Row(
              children: [
                // Cancel button
                IconButton(
                  onPressed: () {
                    context.read<TransactionCubit>().clearSelection();
                  },
                  icon: const Icon(Icons.close),
                  color: Colors.grey.shade700,
                ),
                const SizedBox(width: 8),
                // Selection info
                Expanded(
                  child: Text(
                    '$selectedCount item dipilih',
                    style: const TextStyle(
                      fontFamily: fontType,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: primaryGreenColor,
                    ),
                  ),
                ),
                // Select all button
                TextButton.icon(
                  onPressed: () {
                    context.read<TransactionCubit>().selectAllProducts();
                  },
                  icon: const Icon(Icons.select_all, size: 18),
                  label: const Text('Pilih Semua'),
                  style: TextButton.styleFrom(
                    foregroundColor: primaryGreenColor,
                  ),
                ),
                const SizedBox(width: 8),
                // Delete button (only enabled if has selection)
                ElevatedButton.icon(
                  onPressed: hasSelection
                      ? () => _showDeleteSelectedConfirmation(context, selectedCount)
                      : null,
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Hapus'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: hasSelection ? Colors.red : Colors.grey.shade300,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    disabledForegroundColor: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          );
        }

        // 🆕 UI normal (tidak dalam selection mode)
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: Color(0xFFE0E0E0)),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: ActionButton(
                  icon: Icons.percent_rounded,
                  label: 'Diskon',
                  onTap: () {
                    _showDiscountBottomSheet(context);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ActionButton(
                  icon: Icons.receipt_long_rounded,
                  label: 'Biaya Lain',
                  onTap: () {
                    _showOtherCostsDialog(context);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ActionButton(
                  icon: Icons.delete_outline_rounded,
                  label: 'Hapus',
                  onTap: () {
                    _showDeleteOptions(context); // 🆕 Tampilkan opsi hapus
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 🆕 Dialog untuk pilih cara hapus
  void _showDeleteOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Pilih Opsi Hapus',
              style: TextStyle(
                fontFamily: fontType,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.checklist, color: primaryGreenColor),
              title: const Text(
                'Hapus Beberapa Item',
                style: TextStyle(fontFamily: fontType, fontWeight: FontWeight.w600),
              ),
              subtitle: const Text(
                'Pilih item yang ingin dihapus',
                style: TextStyle(fontFamily: fontType, fontSize: 12),
              ),
              onTap: () {
                Navigator.pop(sheetContext);
                context.read<TransactionCubit>().toggleSelectionMode();
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.delete_sweep, color: Colors.red),
              title: const Text(
                'Hapus Semua Transaksi',
                style: TextStyle(
                  fontFamily: fontType,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
              subtitle: const Text(
                'Hapus seluruh transaksi',
                style: TextStyle(fontFamily: fontType, fontSize: 12),
              ),
              onTap: () {
                Navigator.pop(sheetContext);
                _showDeleteConfirmation(context);
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  // 🆕 Confirmation untuk hapus selected items
  void _showDeleteSelectedConfirmation(BuildContext context, int count) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Hapus Item Terpilih?',
          style: TextStyle(fontFamily: fontType, fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Anda akan menghapus $count item dari transaksi. Tindakan ini tidak dapat dibatalkan.',
          style: const TextStyle(fontFamily: fontType, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              context.read<TransactionCubit>().deleteSelectedProducts();
              Navigator.pop(dialogContext);
              FloatingMessage.show(
                context,
                message: '$count item berhasil dihapus',
                backgroundColor: primaryGreenColor,
              );
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _showDiscountBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => BlocProvider.value(
        value: context.read<TransactionCubit>(),
        child: const DiscountBottomSheet(),
      ),
    );
  }

  void _showOtherCostsDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,  // ✅ Tambahkan ini
      backgroundColor: Colors.transparent,  // ✅ Tambahkan ini
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<TransactionCubit>(),
        child: const OtherCostsDialog(),
      ),
    );
  }
  void _showDeleteConfirmation(BuildContext context) {
    final state = context.read<TransactionCubit>().state;
    final itemCount = state.selectedItems.length;
    final totalQty = state.selectedItems.fold<int>(
      0,
          (sum, product) => sum + state.getQuantity(product.id.toString()),
    );

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Hapus Transaksi?',
          style: TextStyle(
            fontFamily: fontType,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Anda akan menghapus:',
              style: TextStyle(
                fontFamily: fontType,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '• $itemCount produk',
              style: const TextStyle(
                fontFamily: fontType,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '• Total $totalQty item',
              style: const TextStyle(
                fontFamily: fontType,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tindakan ini tidak dapat dibatalkan.',
              style: TextStyle(
                fontFamily: fontType,
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              context.read<TransactionCubit>().resetTransaction();
              Navigator.pop(dialogContext); // Close dialog
              Navigator.pop(context); // Back to TransactionPage

              FloatingMessage.show(
                context,
                message: 'Transaksi berhasil dihapus',
                textOnly: true,
                backgroundColor: primaryGreenColor,
              );
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}


class DiscountBottomSheet extends StatefulWidget {
  const DiscountBottomSheet({super.key});

  @override
  State<DiscountBottomSheet> createState() => _DiscountBottomSheetState();
}

class _DiscountBottomSheetState extends State<DiscountBottomSheet> {
  final TextEditingController _controller = TextEditingController();
  bool _isPercentMode = false;

  @override
  void initState() {
    super.initState();
    // Load existing discount
    final state = context.read<TransactionCubit>().state;
    if (state.discount > 0) {
      _controller.text = state.discount.toString();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionCubit, TransactionState>(
      builder: (context, state) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20,20,20,20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tambah Diskon',
                        style: TextStyle(
                          fontFamily: fontType,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Toggle Rp / %
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildToggleButton('Rupiah', !_isPercentMode, () {
                            setState(() => _isPercentMode = false);
                            _controller.clear();
                            context.read<TransactionCubit>().clearDiscount();
                          }),
                        ),
                        Expanded(
                          child: _buildToggleButton('Persen', _isPercentMode, () {
                            setState(() => _isPercentMode = true);
                            _controller.clear();
                            context.read<TransactionCubit>().clearDiscount();
                          }),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Input Field
                  TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: _isPercentMode ? 'Contoh: 10' : 'Contoh: 5000',
                      prefixText: _isPercentMode ? '' : 'Rp ',
                      suffixText: _isPercentMode ? '%' : '',
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: primaryGreenColor, width: 2),
                      ),
                    ),
                    onChanged: (value) {
                      if (value.isEmpty) {
                        context.read<TransactionCubit>().clearDiscount();
                        return;
                      }

                      final amount = int.tryParse(value);
                      if (amount == null) return;

                      if (_isPercentMode) {
                        context.read<TransactionCubit>().setDiscountPercent(amount);
                      } else {
                        context.read<TransactionCubit>().setDiscountAmount(amount);
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Quick Discount Chips
                  const Text(
                    'Diskon Cepat',
                    style: TextStyle(
                      fontFamily: fontType,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _isPercentMode
                        ? [
                      _buildQuickChipPercent('5%', 5),
                      _buildQuickChipPercent('10%', 10),
                      _buildQuickChipPercent('15%', 15),
                      _buildQuickChipPercent('20%', 20),
                      _buildQuickChipPercent('25%', 25),
                      _buildQuickChipPercent('50%', 50),
                    ]
                        : [
                      _buildQuickChipRupiah('1.000', 1000),
                      _buildQuickChipRupiah('5.000', 5000),
                      _buildQuickChipRupiah('10.000', 10000),
                      _buildQuickChipRupiah('20.000', 20000),
                      _buildQuickChipRupiah('50.000', 50000),
                      _buildQuickChipRupiah('100.000', 100000),
                    ],
                  ),

                  // Discount Preview
                  if (state.discount > 0) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Subtotal',
                                style: TextStyle(
                                  fontFamily: fontType,
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                'Rp ${state.subtotal}',
                                style: const TextStyle(
                                  fontFamily: fontType,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Diskon',
                                style: TextStyle(
                                  fontFamily: fontType,
                                  fontSize: 13,
                                  color: Colors.red,
                                ),
                              ),
                              Text(
                                '- Rp ${state.discount}',
                                style: const TextStyle(
                                  fontFamily: fontType,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total',
                                style: TextStyle(
                                  fontFamily: fontType,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Rp ${state.finalTotal}',
                                style: const TextStyle(
                                  fontFamily: fontType,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: primaryGreenColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // Action Buttons
                  Row(
                    children: [
                      if (state.discount > 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              _controller.clear();
                              context.read<TransactionCubit>().clearDiscount();
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: const BorderSide(color: Colors.red),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Hapus Diskon',
                              style: TextStyle(
                                fontFamily: fontType,
                                fontWeight: FontWeight.w600,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ),
                      if (state.discount > 0) const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: primaryGreenColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Terapkan',
                            style: TextStyle(
                              fontFamily: fontType,
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
          )
        );
      },
    );
  }

  Widget _buildToggleButton(String label, bool isActive, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? primaryGreenColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: fontType,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }


  Widget _buildQuickChipPercent(String label, int percent) {
    return InkWell(
      onTap: () {
        setState(() {
          _isPercentMode = true;
          _controller.text = percent.toString();
        });
        context.read<TransactionCubit>().setDiscountPercent(percent);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: primaryGreenColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: primaryGreenColor.withOpacity(0.3)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: fontType,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: primaryGreenColor,
          ),
        ),
      ),
    );
  }

  Widget _buildQuickChipRupiah(String label, int amount) {
    return InkWell(
      onTap: () {
        setState(() {
          _controller.text = amount.toString();
        });
        context.read<TransactionCubit>().setDiscountAmount(amount);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: primaryGreenColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: primaryGreenColor.withOpacity(0.3)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: fontType,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: primaryGreenColor,
          ),
        ),
      ),
    );
  }
}

// widget umum action button
class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const ActionButton({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      splashColor: Colors.grey.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.grey.shade500, size: 26),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: fontType,
                fontWeight: FontWeight.w500,
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// next bayar
class PaymentButton extends StatelessWidget {
  final VoidCallback onPressed;
  final int quantity;
  final String label;
  final String price;

  const PaymentButton({
    super.key,
    required this.onPressed,
    this.quantity = 1,
    this.label = 'Bayar',
    this.price = 'Rp 0',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: primaryGreenColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -1),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.all(0),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            splashColor: Colors.white24,
            highlightColor: Colors.white12,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$quantity',
                          style: const TextStyle(
                            fontFamily: fontType,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        label,
                        style: const TextStyle(
                          fontFamily: fontType,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        price,
                        style: const TextStyle(
                          fontFamily: fontType,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.chevron_right, color: Colors.white, size: 22),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


// HASIL TOTAL NYA
class TransactionSummarySection extends StatelessWidget {
  const TransactionSummarySection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionCubit, TransactionState>(
      builder: (context, state) {
        // Hanya tampilkan jika ada diskon atau biaya lain
        final hasDiscount = state.discount > 0;
        final hasOtherCosts = state.otherCosts > 0;

        if (!hasDiscount && !hasOtherCosts) {
          return const SizedBox.shrink(); // Tidak tampil jika tidak ada
        }

        return Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              // Subtotal
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Subtotal',
                    style: TextStyle(
                      fontFamily: fontType,
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    '${state.subtotal}',
                    style: const TextStyle(
                      fontFamily: fontType,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),

              // Diskon Global (jika ada)
              if (hasDiscount) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.local_offer,
                          size: 14,
                          color: Colors.redAccent,
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'Diskon Transaksi',
                          style: TextStyle(
                            fontFamily: fontType,
                            fontSize: 13,
                            color: Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '- ${state.discount}',
                      style: const TextStyle(
                        fontFamily: fontType,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],

              // Biaya Lain (jika ada)
              if (hasOtherCosts) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Biaya Lain',
                      style: TextStyle(
                        fontFamily: fontType,
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      '+ ${state.otherCosts}',
                      style: const TextStyle(
                        fontFamily: fontType,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ],

              // Divider
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Divider(
                  height: 1,
                  color: Colors.grey.shade300,
                ),
              ),

              // Total Akhir
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(
                      fontFamily: fontType,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    '${state.finalTotal}',
                    style: const TextStyle(
                      fontFamily: fontType,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: primaryGreenColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}


// BIAYA LAIN
class OtherCostsDialog extends StatefulWidget {
  const OtherCostsDialog({super.key});

  @override
  State<OtherCostsDialog> createState() => _OtherCostsDialogState();
}

class _OtherCostsDialogState extends State<OtherCostsDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Load existing data jika ada
    final state = context.read<TransactionCubit>().state;
    if (state.otherCosts > 0 && state.otherCostsName.isNotEmpty) {
      _nameController.text = state.otherCostsName;
      _amountController.text = state.otherCosts.toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,  // ✅ Pindahkan ke sini
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SingleChildScrollView(  // ✅ Langsung wrap Column
          child: Padding(
            padding: const EdgeInsets.all(20),  // ✅ Padding fixed
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Biaya Lain',
                        style: TextStyle(
                          fontFamily: fontType,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Nama Biaya Input
                  const Text(
                    'Nama Biaya',
                    style: TextStyle(
                      fontFamily: fontType,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'Contoh: Ongkir, Pajak, dll',
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: primaryGreenColor,
                          width: 2,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Nama biaya tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Nominal Input
                  const Text(
                    'Nominal',
                    style: TextStyle(
                      fontFamily: fontType,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Contoh: 5000',
                      prefixText: 'Rp ',
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: primaryGreenColor,
                          width: 2,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nominal tidak boleh kosong';
                      }
                      final amount = int.tryParse(value);
                      if (amount == null || amount <= 0) {
                        return 'Nominal harus lebih dari 0';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Quick Amount Chips
                  const Text(
                    'Nominal Cepat',
                    style: TextStyle(
                      fontFamily: fontType,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildQuickChip('1.000', 1000),
                      _buildQuickChip('5.000', 5000),
                      _buildQuickChip('10.000', 10000),
                      _buildQuickChip('15.000', 15000),
                      _buildQuickChip('20.000', 20000),
                      _buildQuickChip('50.000', 50000),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons
                  BlocBuilder<TransactionCubit, TransactionState>(
                    builder: (context, state) {
                      final hasOtherCosts = state.otherCosts > 0;

                      return Row(
                        children: [
                          if (hasOtherCosts)
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  context.read<TransactionCubit>().clearOtherCosts();
                                  Navigator.pop(context);
                                },
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  side: const BorderSide(color: Colors.red),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  'Hapus',
                                  style: TextStyle(
                                    fontFamily: fontType,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ),
                          if (hasOtherCosts) const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  final name = _nameController.text.trim();
                                  final amount = int.parse(_amountController.text);

                                  context.read<TransactionCubit>().setOtherCosts(
                                    amount: amount,
                                    name: name,
                                  );
                                  Navigator.pop(context);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                backgroundColor: primaryGreenColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'Simpan',
                                style: TextStyle(
                                  fontFamily: fontType,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickChip(String label, int amount) {
    return InkWell(
      onTap: () {
        _amountController.text = amount.toString();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: primaryGreenColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: primaryGreenColor.withOpacity(0.3)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: fontType,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: primaryGreenColor,
          ),
        ),
      ),
    );
  }
}