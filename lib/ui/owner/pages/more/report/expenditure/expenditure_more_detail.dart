import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../../../blocs/financials/finance_bloc.dart';
import '../../../../../../blocs/financials/finance_event.dart';
import '../../../../../../blocs/financials/finance_state.dart';
import '../../../../../../core/theme/theme.dart';
import '../../../../../../data/models/finance_model.dart';
import '../../../../../widgets/custom_app_bar.dart';
import '../../../../../widgets/floating_message.dart';

class ExpenditureMoreDetail extends StatelessWidget {
  final Finance finance;
  final String Function(int) formatCurrency;

  const ExpenditureMoreDetail({
    super.key,
    required this.finance,
    required this.formatCurrency,
  });

  // void _showDeleteDialog(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     builder: (dialogContext) => AlertDialog(
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(16),
  //       ),
  //       title: const Text(
  //         'Hapus Transaksi?',
  //         style: TextStyle(
  //           fontFamily: fontType,
  //           fontWeight: FontWeight.w600,
  //         ),
  //       ),
  //       content: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text(
  //             'Apakah Anda yakin ingin menghapus transaksi "${finance.name}"?',
  //             style: const TextStyle(
  //               fontFamily: fontType,
  //               fontSize: 14,
  //             ),
  //           ),
  //           const SizedBox(height: 12),
  //           Container(
  //             padding: const EdgeInsets.all(12),
  //             decoration: BoxDecoration(
  //               color: Colors.red.withOpacity(0.1),
  //               borderRadius: BorderRadius.circular(8),
  //             ),
  //             child: const Row(
  //               children: [
  //                 Icon(
  //                   Icons.warning_amber_rounded,
  //                   color: Colors.red,
  //                   size: 20,
  //                 ),
  //                 SizedBox(width: 8),
  //                 Expanded(
  //                   child: Text(
  //                     'Data yang dihapus tidak dapat dikembalikan',
  //                     style: TextStyle(
  //                       fontFamily: fontType,
  //                       fontSize: 12,
  //                       color: Colors.red,
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ],
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(dialogContext),
  //           child: const Text(
  //             'Batal',
  //             style: TextStyle(
  //               fontFamily: fontType,
  //               color: Colors.grey,
  //             ),
  //           ),
  //         ),
  //         ElevatedButton(
  //           style: ElevatedButton.styleFrom(
  //             backgroundColor: Colors.red,
  //             foregroundColor: Colors.white,
  //             shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(8),
  //             ),
  //           ),
  //           onPressed: () {
  //             context.read<FinanceBloc>().add(DeleteFinance(finance.id!));
  //             Navigator.pop(dialogContext); // Close dialog
  //             Navigator.pop(context); // Close detail page
  //           },
  //           child: const Text(
  //             'Hapus',
  //             style: TextStyle(
  //               fontFamily: fontType,
  //               fontWeight: FontWeight.w600,
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final isExpense = finance.type == FinanceType.outcome;
    final cardColor = isExpense
        ? const Color(0xFFD4E7D4) // Light green untuk expense
        : const Color(0xFFD4E4F7); // Light blue untuk income

    return BlocListener<FinanceBloc, FinanceState>(
      listener: (context, state) {
        if (state is FinanceOperationSuccess) {
          FloatingMessage.show(
            context,
            message: state.message,
            backgroundColor: primaryGreenColor,
          );
        } else if (state is FinanceError) {
          FloatingMessage.show(
            context,
            message: state.message,
            backgroundColor: Colors.red,
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: CustomAppBar(
          title: 'Detail ${isExpense ? "Pengeluaran" : "Pemasukan"}',
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    // Date & Time
                    Text(
                      DateFormat('dd MMMM yyyy', 'id_ID').format(finance.date),
                      style: const TextStyle(
                        fontFamily: fontType,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('HH:mm:ss').format(finance.date),
                      style: TextStyle(
                        fontFamily: fontType,
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),

                    const SizedBox(height: 15),

                    // Amount
                    Text(
                      formatCurrency(finance.amount as int),
                      style: const TextStyle(
                        fontFamily: fontType,
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Nama Transaksi
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _DetailRow(
                        label: 'Nama Transaksi:',
                        value: finance.name,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Catatan
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _DetailRow(
                        label: 'Catatan:',
                        value: finance.description?.isNotEmpty == true
                            ? finance.description!
                            : '-',
                      ),
                    )

                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Additional Info Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Informasi Tambahan',
                      style: TextStyle(
                        fontFamily: fontType,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _InfoRow(
                      icon: Icons.category_outlined,
                      label: 'Tipe',
                      value: isExpense ? 'Pengeluaran' : 'Pemasukan',
                      valueColor: isExpense ? Colors.red : primaryGreenColor,
                    ),

                    const Divider(height: 24),

                    _InfoRow(
                      icon: Icons.access_time_outlined,
                      label: 'Dibuat',
                      value: finance.createdAt != null
                          ? DateFormat('dd MMM yyyy, HH:mm', 'id_ID')
                          .format(finance.createdAt!)
                          : '-',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget untuk row detail di card utama
class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: fontType,
            fontSize: 14,
            color: Colors.black,
            fontWeight: FontWeight.w700
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontFamily: fontType,
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

// Widget untuk info row di card tambahan
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: fontType,
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontFamily: fontType,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: valueColor ?? Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}