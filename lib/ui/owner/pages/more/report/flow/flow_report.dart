import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../../../blocs/flow_report/flow_report_cubit.dart';
import '../../../../../../core/theme/theme.dart';
import '../../../../../../data/models/finance_model.dart';
import '../../../../../widgets/custom_app_bar.dart';
import 'flow_detail.dart';

class FlowReportPage extends StatefulWidget {
  const FlowReportPage({super.key});

  @override
  State<FlowReportPage> createState() => _FlowReportPageState();
}

class _FlowReportPageState extends State<FlowReportPage> {
  @override
  void initState() {
    super.initState();
    context.read<FinancialReportCubit>().loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: const CustomAppBar(title: 'Laporan Arus Kas'),
      body: BlocBuilder<FinancialReportCubit, FinancialReportState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // === FILTER DATE RANGE === ← TAMBAH INI
                  FilterDateSection(
                    startDate: state.startDate,
                    endDate: state.endDate,
                    onDateRangeSelected: (start, end) {
                      context.read<FinancialReportCubit>().setDateRange(start, end);
                    },
                  ),
                  // Reset button jika ada custom date
                  if (state.startDate != null && state.endDate != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: TextButton.icon(
                        onPressed: () {
                          final cubit = context.read<FinancialReportCubit>();
                          cubit.setDateRange(null, null);
                          cubit.loadData();
                        },
                        icon: const Icon(Icons.clear, size: 16),
                        label: const Text('Reset ke Periode'),
                        style: TextButton.styleFrom(
                          foregroundColor: primaryGreenColor,
                        ),
                      ),
                    ),

                  const SizedBox(height: 16,),

                  // === FILTER PERIODE ===
                  _PeriodSelector(
                    selectedPeriod: state.selectedPeriod,
                    onPeriodChanged: (period) {
                      context.read<FinancialReportCubit>()
                        ..setPeriod(period)
                        ..setDateRange(null, null);
                    },
                  ),

                  const SizedBox(height: 20),

                  // Summary cards
                  _buildSummaryCards(state),
                  const SizedBox(height: 16),

                  // Net income card
                  _buildNetIncomeCard(state),
                  const SizedBox(height: 16),

                  // Transaction list
                  _buildTransactionList(state),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCards(FinancialReportState state) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        children: [
          // Total Pemasukan & Total Pengeluaran
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Pemasukan',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      currencyFormat.format(state.totalRevenue),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Pengeluaran',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      currencyFormat.format(state.totalExpense),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE57373),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, color: Colors.grey[300]),
          ),

          // Pemasukan & Pengeluaran
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pemasukan',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currencyFormat.format(state.totalSales),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pengeluaran',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currencyFormat.format(state.totalExpense),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Pemasukan Lain
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pemasukan Lain',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currencyFormat.format(state.totalIncome),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              const Expanded(child: SizedBox()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNetIncomeCard(FinancialReportState state) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final isPositive = state.netIncome >= 0;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withOpacity(0.3), // outline tipis
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Column(
          children: [
            Text(
              currencyFormat.format(state.netIncome),
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: isPositive ? primaryGreenColor : Colors.red,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Pendapatan Neto',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, Map<String, dynamic>> _groupByDate(
      List<Map<String, dynamic>> items
      ) {
    final Map<String, Map<String, dynamic>> grouped = {};

    for (var item in items) {
      final date = item['date'] as DateTime;
      final dateKey = DateFormat('yyyy-MM-dd').format(date);

      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = {
          'date': date,
          'count': 0,
          'totalRevenue': 0,
          'totalExpense': 0,
          'items': <Map<String, dynamic>>[],
        };
      }

      grouped[dateKey]!['count'] += 1;
      grouped[dateKey]!['items'].add(item);

      final type = item['type'] as String;
      final amount = item['amount'] as int;

      if (type == 'expense') {
        grouped[dateKey]!['totalExpense'] += amount;
      } else {
        grouped[dateKey]!['totalRevenue'] += amount;
      }
    }

    return grouped;
  }

  Widget _buildTransactionList(FinancialReportState state) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    // Gabungkan transaksi penjualan dan keuangan
    final List<Map<String, dynamic>> items = [];

    // Tambahkan transaksi penjualan - PERBAIKI INI
    for (var transaction in state.filteredTransactions) {
      items.add({
        'date': DateTime.parse(transaction.tanggal), // ✅ Parse dari string
        'type': 'sales',
        'description': 'Penjualan #${transaction.kodeTransaksi}',
        'amount': transaction.bayar.toInt(), // ✅ Convert ke int untuk grouping
        'profit': transaction.keuntungan.toInt(),
        'transaction': transaction, // ✅ Simpan object asli
      });
    }

    // Tambahkan transaksi keuangan
    for (var finance in state.filteredFinances) {
      items.add({
        'date': finance.date,
        'type': finance.type == FinanceType.income ? 'income' : 'expense',
        'description': finance.name,
        'amount': finance.amount.toInt(),
        'notes': finance.description,
        'finance': finance, // ✅ Simpan object asli
      });
    }

    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(48),
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
        child: Center(
          child: Column(
            children: [
              Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text(
                'Belum ada transaksi',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Group by date
    final grouped = _groupByDate(items);
    final dateKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Riwayat Transaksi',
              style: TextStyle(
                fontFamily: fontType,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${items.length} transaksi',
              style: TextStyle(
                fontFamily: fontType,
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...dateKeys.map((dateKey) {
          final data = grouped[dateKey]!;
          final itemsForDate = data['items'] as List<Map<String, dynamic>>;

          return _buildDateCard(
            date: data['date'] as DateTime,
            transactionCount: data['count'] as int,
            totalRevenue: data['totalRevenue'] as int,
            totalExpense: data['totalExpense'] as int,
            items: itemsForDate,
            currencyFormat: currencyFormat,
          );
        }),
      ],
    );
  }

  Widget _buildDateCard({
    required DateTime date,
    required int transactionCount,
    required int totalRevenue,
    required int totalExpense,
    required List<Map<String, dynamic>> items,
    required NumberFormat currencyFormat,
  }) {
    final netIncome = totalRevenue - totalExpense;

    return GestureDetector(
      onTap: () => _showTransactionDetail(context, items.first),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Tanggal
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '*tekan untuk melihat detail',
                    style: TextStyle(
                      fontFamily: fontType,
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('dd').format(date),
                        style: const TextStyle(
                          fontFamily: fontType,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            DateFormat('MMMM', 'id').format(date),
                            style: TextStyle(
                              fontFamily: fontType,
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            DateFormat('yyyy').format(date),
                            style: TextStyle(
                              fontFamily: fontType,
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$transactionCount Transaksi',
                    style: const TextStyle(
                      fontFamily: fontType,
                      fontSize: 12,
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            // Total
            Expanded(
              flex: 3,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Pendapatan Neto',
                      style: TextStyle(
                        fontFamily: fontType,
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      currencyFormat.format(netIncome),
                      style: TextStyle(
                        fontFamily: fontType,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: netIncome >= 0 ? primaryGreenColor : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  void _showTransactionDetail(BuildContext context, Map<String, dynamic> item) {
    final date = item['date'] as DateTime;

    // Filter transaksi dan finance untuk hari ini
    final state = context.read<FinancialReportCubit>().state;

    final transactionsOnDate = state.filteredTransactions.where((t) {
      final transactionDate = DateTime.parse(t.tanggal); // ✅ Parse dari string
      return transactionDate.year == date.year &&
          transactionDate.month == date.month &&
          transactionDate.day == date.day;
    }).toList();

    final financesOnDate = state.filteredFinances.where((f) {
      return f.date.year == date.year &&
          f.date.month == date.month &&
          f.date.day == date.day;
    }).toList();

    // Navigate ke detail page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FlowDetailPage(
          date: date,
          transactions: transactionsOnDate,
          finances: financesOnDate,
        ),
      ),
    );
  }
  }


class FilterDateSection extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final Function(DateTime?, DateTime?) onDateRangeSelected;

  const FilterDateSection({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.onDateRangeSelected,
  });

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: startDate != null && endDate != null
          ? DateTimeRange(start: startDate!, end: endDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryGreenColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onDateRangeSelected(picked.start, picked.end);
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final hasDate = startDate != null && endDate != null;
    final textColor = hasDate ? Colors.black87 : Colors.grey[600];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Rentang Tanggal',
          style: TextStyle(
            fontFamily: fontType,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectDateRange(context),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    hasDate
                        ? '${_formatDate(startDate)} - ${_formatDate(endDate)}'
                        : 'Pilih rentang tanggal',
                    style: TextStyle(
                      fontFamily: fontType,
                      color: textColor,
                      fontSize: 15,
                    ),
                  ),
                ),
                Icon(
                  Icons.calendar_today_outlined,
                  color: Colors.grey[600],
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  final ReportPeriod selectedPeriod;
  final Function(ReportPeriod) onPeriodChanged;

  const _PeriodSelector({
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ReportPeriod.values.map((period) {
          final isSelected = period == selectedPeriod;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onPeriodChanged(period),
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? primaryGreenColor : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color:
                    isSelected ? primaryGreenColor : Colors.grey.shade300,
                  ),
                ),
                child: Text(
                  period.displayName,
                  style: TextStyle(
                    fontFamily: fontType,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color:
                    isSelected ? Colors.white : Colors.grey.shade700,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
