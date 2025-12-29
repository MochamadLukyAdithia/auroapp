import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pos_mobile/ui/owner/pages/transactions/sales/payment/transaction_success.dart';
import 'package:pos_mobile/ui/widgets/custom_app_bar.dart';
import '../../../../../../blocs/history_stock/stock_bloc.dart';
import '../../../../../../blocs/product/product_bloc.dart';
import '../../../../../../blocs/transaction/transaction_cubit.dart';
import '../../../../../../blocs/transaction/transaction_state.dart';
import '../../../../../../core/theme/theme.dart';
import '../../../../../widgets/floating_message.dart';

class CashPayment extends StatelessWidget {
  const CashPayment({super.key});

  String _formatCurrency(int value) {
    return NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0)
        .format(value);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(  // ✅ TAMBAH INI
        onPopInvoked: (didPop) {
          if (didPop) {
            context.read<TransactionCubit>().setReceivedAmount(null);
          }
        },
      child: BlocBuilder<TransactionCubit, TransactionState>(
      builder: (context, state) {
        final totalTagihan = state.finalTotal;
        final uangDiterima = state.receivedAmount;
        // final kembalian = state.changeAmount; // Pakai helper dari state
        final kembalian = state.receivedAmount != null
            ? (state.receivedAmount! - totalTagihan).clamp(0, double.infinity)
            : 0;
        final isPaymentValid = state.isPaymentSufficient;

        return Scaffold(
          appBar: const CustomAppBar(title: 'Tunai'),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TotalPaymentCard(
                  total: totalTagihan,
                  format: _formatCurrency,
                ),
                const SizedBox(height: 16),

                NominalButton(
                  totalTagihan: totalTagihan,
                  selectedNominal: uangDiterima,
                  onSelect: (nominal) {
                    context.read<TransactionCubit>().setReceivedAmount(nominal);
                  },
                  onCustomNominal: () async {
                    final nominal = await _showCustomNominalDialog(context);
                    if (nominal != null) {
                      context.read<TransactionCubit>().setReceivedAmount(nominal);
                    }
                  },
                  formatCurrency: _formatCurrency,
                ),

                const SizedBox(height: 20),

                // ===== BAGIAN KEMBALIAN DIPERBAIKI =====
                if (uangDiterima != null) ...[
                  // Tampilkan uang yang diterima
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Uang Diterima',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatCurrency(uangDiterima),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Tampilkan kembalian atau warning
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isPaymentValid
                          ? Colors.green.shade50
                          : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isPaymentValid
                            ? Colors.green.shade200
                            : Colors.red.shade200,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isPaymentValid ? 'Kembalian' : '⚠️ Uang Kurang',
                          style: TextStyle(
                            fontSize: 14,
                            color: isPaymentValid ? Colors.grey : Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isPaymentValid
                              ? _formatCurrency(kembalian.toInt())
                              : 'Kurang ${_formatCurrency(totalTagihan - uangDiterima)}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isPaymentValid ? primaryGreenColor : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const Spacer(),

                // Button bayar (disabled kalau uang kurang)
                PayButton(
                  isEnabled: uangDiterima != null && isPaymentValid,
                  onPressed: () async {
                    final cubit = context.read<TransactionCubit>();
                    final stockBloc = context.read<StockBloc>();
                    final productBloc = context.read<ProductBloc>();
                    final state = cubit.state;

                    // 🆕 VALIDASI STOK DULU
                    bool hasStockIssue = false;
                    String errorMessage = '';
                    for (var product in state.selectedItems) {
                      final qty = state.getQuantity(product.id.toString());
                      final stock = product.productStock;

                      if (qty > stock!) {
                        hasStockIssue = true;
                        errorMessage = 'Stok ${product.productName} tidak mencukupi!\n'
                            'Tersedia: $stock, Dipilih: $qty';
                        break;
                      }
                    }

                    if (hasStockIssue) {
                      FloatingMessage.show(context, message: errorMessage, backgroundColor: Colors.red);
                      return;
                    }
                    cubit.completeCashPayment();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MultiBlocProvider(
                          providers: [
                            BlocProvider.value(value: cubit),
                            BlocProvider.value(value: stockBloc),
                            BlocProvider.value(value: productBloc),
                          ],
                          child: const TransactionSuccess(),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    ));
  }

  Future<int?> _showCustomNominalDialog(BuildContext context) async {
    final controller = TextEditingController();
    return showDialog<int>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Nominal Lainnya'),
        content: SingleChildScrollView( // ✅ TAMBAH INI
          child: Column( // ✅ WRAP DENGAN COLUMN
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                autofocus: true, // ✅ OPSIONAL: auto focus
                decoration: const InputDecoration(
                  prefixText: 'Rp ',
                  hintText: '0',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                Navigator.pop(dialogContext, int.parse(text));
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}


// ==========================================================
// =============== WIDGET TERPISAH UNTUK UI ================
// ==========================================================

class TotalPaymentCard extends StatelessWidget {
  final int total;
  final String Function(int) format;

  const TotalPaymentCard({
    super.key,
    required this.total,
    required this.format,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Total Tagihan",
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Text(
            format(total),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class NominalButton extends StatelessWidget {
  final int? selectedNominal;
  final void Function(int) onSelect;
  final VoidCallback onCustomNominal;
  final int totalTagihan;
  final String Function(int) formatCurrency;

  const NominalButton({
    super.key,
    required this.selectedNominal,
    required this.onSelect,
    required this.onCustomNominal,
    required this.totalTagihan,
    required this.formatCurrency,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> nominalOptions = [
      {'label': 'Uang Pas', 'value': totalTagihan},
      {'label': 'Rp 5.000', 'value': 5000},
      {'label': 'Rp 10.000', 'value': 10000},
      {'label': 'Rp 20.000', 'value': 20000},
      {'label': 'Rp 50.000', 'value': 50000},
      {'label': 'Rp 100.000', 'value': 100000},
      {'label': 'Nominal Lainnya', 'value': null}, // null untuk custom
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (var item in nominalOptions)
          _NominalButton(
            label: item['label'],
            isSelected: selectedNominal == item['value'],
            onTap: () {
              if (item['value'] == null) {
                onCustomNominal();
              } else {
                onSelect(item['value']);
              }
            },
          ),
      ],
    );
  }
}

class _NominalButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NominalButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double buttonWidth =
        (MediaQuery.of(context).size.width - 16 * 2 - 8) / 2;

    return SizedBox(
      width: buttonWidth,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? primaryGreenColor.withOpacity(0.1) : Colors.white,
              border: Border.all(
                color: isSelected ? primaryGreenColor : Colors.grey.shade300,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isSelected ? primaryGreenColor : Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CustomNominalCard extends StatelessWidget {
  final int nominal;
  final String Function(int) formatCurrency;
  final VoidCallback onEdit;

  const _CustomNominalCard({
    required this.nominal,
    required this.formatCurrency,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: primaryGreenColor.withOpacity(0.05),
        border: Border.all(color: primaryGreenColor),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Nominal Lainnya",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Text(
                formatCurrency(nominal),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: onEdit,
            child: Row(
              children: [
                Icon(Icons.edit, color: primaryGreenColor, size: 18),
                const SizedBox(width: 4),
                Text(
                  "Ubah Nominal",
                  style: TextStyle(
                    fontSize: 14,
                    color: primaryGreenColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PayButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isEnabled;

  const PayButton({
    super.key,
    required this.onPressed,
    this.isEnabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled ? primaryGreenColor : Colors.grey.shade300,
          foregroundColor: isEnabled ? Colors.white : Colors.grey.shade500,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
          textStyle: const TextStyle(
            fontFamily: fontType,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        onPressed: isEnabled ? onPressed : null,
        child: const Text('Bayar'),
      ),
    );
  }
}