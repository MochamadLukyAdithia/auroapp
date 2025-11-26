import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../blocs/financials/finance_bloc.dart';
import '../../../../blocs/financials/finance_event.dart';
import '../../../../blocs/financials/finance_state.dart';
import '../../../../core/theme/theme.dart';
import '../../../../data/models/finance_model.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/floating_message.dart';
import 'add_finance.dart';
import 'filtered_finance_date.dart';


class FinancePage extends StatelessWidget {
  const FinancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FinanceBloc, FinanceState>(
        builder: (context, state) {
          bool showFab = false;

          if (state is FinanceLoaded && state.filteredFinances.isNotEmpty) {
            showFab = true;
          }

          return Scaffold(
            appBar: const CustomAppBar(title: 'Keuangan'),
            floatingActionButton: showFab
                ? Padding(padding: const EdgeInsets.only(bottom: 80.0),
              child: FloatingActionButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddFinancePage()),
                  );
                  if (result != null && result is Finance) {
                    context.read<FinanceBloc>().add(AddFinance(result));
                  }
                },
                backgroundColor: primaryGreenColor,
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ): null,


            body: BlocConsumer<FinanceBloc, FinanceState>(
              listener: (context, state) {
                if (state is FinanceError) {
                  FloatingMessage.show(
                    context,
                    message: state.message,
                    backgroundColor: Colors.red,
                  );
                }
                if (state is FinanceOperationSuccess) {
                  FloatingMessage.show(
                    context,
                    message: state.message,
                    backgroundColor: primaryGreenColor,
                  );
                }

              },
              builder: (context, state) {
                if (state is FinanceLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: primaryGreenColor,
                    ),
                  );
                }

                if (state is FinanceLoaded) {
                  final finances = state.filteredFinances;

                  // ✅ Kalau kosong, hanya tampil EmptyFinanceSection
                  if (finances.isEmpty &&
                      (state.searchQuery?.isEmpty ?? true) &&
                      state.filterType == null) {
                    return const EmptyFinanceSection();
                  }

                  // ✅ Kalau sudah ada data, tampil layout utama
                  return Column(
                    children: [
                      // FinanceSummaryCard(
                      //   totalIncome: state.totalIncome,
                      //   totalExpense: state.totalExpense,
                      //   balance: state.balance,
                      // ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: FinanceSearchBar(
                                onSearchChanged: (query) {
                                  context.read<FinanceBloc>().add(SearchFinances(query));
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            FilterButton(
                              hasActiveFilter: state.filterType != null ||
                                  state.startDate != null ||
                                  state.endDate != null ||
                                  (state.sortBy != null && state.sortBy != 'date_desc'),
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BlocProvider.value(
                                      value: context.read<FinanceBloc>(),
                                      child: const FilteredFinancesPage(),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: FinanceListView(finances: finances),
                      ),
                    ],
                  );
                }

                return const EmptyFinanceSection();
              },
            ),
          );
        },
      );
  }
}


// // Summary Card
// class FinanceSummaryCard extends StatelessWidget {
//   final int totalIncome;
//   final int totalExpense;
//   final int balance;
//
//   const FinanceSummaryCard({
//     super.key,
//     required this.totalIncome,
//     required this.totalExpense,
//     required this.balance,
//   });
//
//   String _formatCurrency(int amount) {
//     return NumberFormat.currency(
//       locale: 'id',
//       symbol: 'Rp ',
//       decimalDigits: 0,
//     ).format(amount);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.all(16),
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           colors: [primaryGreenColor, Color(0xFF45B849)],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: primaryGreenColor.withOpacity(0.3),
//             blurRadius: 12,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           // const Text(
//           //   'Saldo',
//           //   style: TextStyle(
//           //     fontFamily: fontType,
//           //     fontSize: 14,
//           //     color: Colors.white70,
//           //     fontWeight: FontWeight.w700,
//           //   ),
//           // ),
//           // const SizedBox(height: 8),
//           // Text(
//           //   _formatCurrency(balance),
//           //   style: const TextStyle(
//           //     fontFamily: fontType,
//           //     fontSize: 28,
//           //     color: Colors.white,
//           //     fontWeight: FontWeight.bold,
//           //   ),
//           // ),
//           // const SizedBox(height: 20),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               Column(
//                 children: [
//                   const Text(
//                     'Pemasukan',
//                     style: TextStyle(
//                       color: Colors.white70,
//                       fontSize: 14,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     _formatCurrency(totalIncome),
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//               Container(
//                 width: 1,
//                 height: 40,
//                 color: Colors.white30,
//               ),
//               Column(
//                 children: [
//                   const Text(
//                     'Pengeluaran',
//                     style: TextStyle(
//                       color: Colors.white70,
//                       fontSize: 14,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     _formatCurrency(totalExpense),
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           )
//
//         ],
//       ),
//     );
//   }
// }

// class _SummaryItem extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final String amount;
//   final Color color;
//
//   const _SummaryItem({
//     required this.icon,
//     required this.label,
//     required this.amount,
//     required this.color,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Row(
//           children: [
//             Icon(icon, size: 16, color: color),
//             const SizedBox(width: 4),
//             Text(
//               label,
//               style: TextStyle(
//                 fontFamily: fontType,
//                 fontSize: 12,
//                 color: color.withOpacity(0.9),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 4),
//         Text(
//           amount,
//           style: TextStyle(
//             fontFamily: fontType,
//             fontSize: 18,
//             fontWeight: FontWeight.w600,
//             color: color,
//           ),
//         ),
//       ],
//     );
//   }
// }

// Empty Section
class EmptyFinanceSection extends StatelessWidget {
  const EmptyFinanceSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Catatan Keuangan Kosong',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: primaryGreenColor,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Silahkan tambahkan catatan pemasukan & pengeluaran',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreenColor,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Catat Keuangan',
                style: TextStyle(
                  fontFamily: fontType,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddFinancePage()),
                );
                if (result != null && result is Finance) {
                  context.read<FinanceBloc>().add(AddFinance(result));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Search Bar
class FinanceSearchBar extends StatelessWidget {
  final ValueChanged<String>? onSearchChanged;

  const FinanceSearchBar({
    super.key,
    this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        onChanged: onSearchChanged,
        decoration: const InputDecoration(
          hintText: 'Cari catatan keuangan...',
          hintStyle: TextStyle(
            fontFamily: fontType,
            color: Colors.grey,
            fontSize: 14,
          ),
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          contentPadding: EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 16,
          ),
        ),
      ),
    );
  }
}

// Filter Button
// Tambahkan di FilterButton widget
class FilterButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool hasActiveFilter; // ✅ Tambahkan parameter ini

  const FilterButton({
    super.key,
    required this.onTap,
    this.hasActiveFilter = false, // ✅ Default false
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
        // ✅ Badge indicator untuk filter aktif
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

// Finance List
class FinanceListView extends StatelessWidget {
  final List<Finance> finances;

  const FinanceListView({
    super.key,
    required this.finances,
  });

  String _formatCurrency(int amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy', 'id_ID').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FinanceBloc, FinanceState>(
      builder: (context, state) {
        if (state is! FinanceLoaded) return const SizedBox.shrink();

        final isSelectionMode = state.isSelectionMode;

        return Column(
          children: [
            // 🆕 Selection toolbar
            if (isSelectionMode)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: primaryGreenColor.withOpacity(0.1),
                  border: const Border(
                    bottom: BorderSide(color: primaryGreenColor, width: 2),
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        context.read<FinanceBloc>().add(const ClearSelection());
                      },
                      icon: const Icon(Icons.close),
                      color: Colors.grey.shade700,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${state.selectedFinanceIds.length} item dipilih',
                        style: const TextStyle(
                          fontFamily: fontType,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: primaryGreenColor,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        context.read<FinanceBloc>().add(const SelectAllFinances());
                      },
                      icon: const Icon(Icons.select_all, size: 18),
                      label: const Text('Pilih Semua'),
                      style: TextButton.styleFrom(
                        foregroundColor: primaryGreenColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: state.selectedFinanceIds.isNotEmpty
                          ? () => _showDeleteConfirmation(
                        context,
                        state.selectedFinanceIds.length,
                      )
                          : null,
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text('Hapus'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: state.selectedFinanceIds.isNotEmpty
                            ? Colors.red
                            : Colors.grey.shade300,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade300,
                        disabledForegroundColor: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),

            // List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: finances.length,
                itemBuilder: (context, index) {
                  final finance = finances[index];
                  final isIncome = finance.type == FinanceType.income;
                  final isSelected = state.selectedFinanceIds.contains(finance.id);

                  return GestureDetector(
                    // 🆕 Long press untuk masuk selection mode
                    onLongPress: () {
                      if (!isSelectionMode) {
                        context.read<FinanceBloc>().add(const ToggleSelectionMode());
                      }
                      context.read<FinanceBloc>().add(
                        ToggleFinanceSelection(finance.id!.toString()),
                      );
                    },
                    // 🆕 Tap untuk toggle selection jika dalam mode selection
                    onTap: isSelectionMode
                        ? () => context.read<FinanceBloc>().add(
                      ToggleFinanceSelection(finance.id!.toString()),
                    )
                        : null,
                    child: Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 1,
                      color: isSelected
                          ? primaryGreenColor.withOpacity(0.1)
                          : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isSelected
                              ? primaryGreenColor
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: isSelectionMode ? 8 : 16,
                          vertical: 8,
                        ),
                        // 🆕 Checkbox di leading saat selection mode
                        leading: isSelectionMode
                            ? Checkbox(
                          value: isSelected,
                          onChanged: (_) {
                            context.read<FinanceBloc>().add(
                              ToggleFinanceSelection(finance.id!.toString()),
                            );
                          },
                          activeColor: primaryGreenColor,
                        )
                            : Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isIncome
                                ? Colors.green.withOpacity(0.1)
                                : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            isIncome
                                ? Icons.arrow_downward
                                : Icons.arrow_upward,
                            color: isIncome ? Colors.green : Colors.red,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          finance.name,
                          style: const TextStyle(
                            fontFamily: fontType,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              _formatDate(finance.date),
                              style: const TextStyle(
                                fontFamily: fontType,
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            if (finance.description != null &&
                                finance.description!.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                finance.description!,
                                style: const TextStyle(
                                  fontFamily: fontType,
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                        trailing: Text(
                          '${isIncome ? '+' : '-'} ${_formatCurrency(finance.amount.toInt())}',
                          style: TextStyle(
                            fontFamily: fontType,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: isIncome ? Colors.green : Colors.red,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, int count) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Hapus Catatan Terpilih?',
          style: TextStyle(
            fontFamily: fontType,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Anda akan menghapus $count catatan keuangan. Tindakan ini tidak dapat dibatalkan.',
          style: const TextStyle(
            fontFamily: fontType,
            fontSize: 14,
          ),
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
              context.read<FinanceBloc>().add(const DeleteSelectedFinances());
              Navigator.pop(dialogContext);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}