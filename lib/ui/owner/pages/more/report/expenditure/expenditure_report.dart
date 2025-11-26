// ui/pages/finance/expenditure_report/expenditure_report_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:month_year_picker/month_year_picker.dart';
import '../../../../../../blocs/financials/finance_bloc.dart';
import '../../../../../../blocs/financials/finance_event.dart';
import '../../../../../../blocs/financials/finance_state.dart';
import '../../../../../../core/theme/theme.dart';
import '../../../../../../data/models/finance_model.dart';
import '../../../../../widgets/custom_app_bar.dart';
import 'expenditure_detail.dart';

class ExpenditureReportPage extends StatefulWidget {
  const ExpenditureReportPage({super.key});

  @override
  State<ExpenditureReportPage> createState() => _ExpenditureReportPageState();
}

class _ExpenditureReportPageState extends State<ExpenditureReportPage> {
  DateTime _selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    context.read<FinanceBloc>().add(const FetchFinances());
  }

  List<Finance> _filteredExpenses(List<Finance> finances) {
    return finances
        .where(
          (f) =>
      f.type == FinanceType.outcome &&
          f.date.month == _selectedMonth.month &&
          f.date.year == _selectedMonth.year,
    )
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Laporan Pengeluaran'),
      body: BlocBuilder<FinanceBloc, FinanceState>(
        builder: (context, state) {
          if (state is FinanceLoading) {
            return const Center(
              child: CircularProgressIndicator(color: primaryGreenColor),
            );
          }

          if (state is FinanceLoaded) {
            final expenses = _filteredExpenses(state.finances);

            return RefreshIndicator(
              onRefresh: () async {
                context.read<FinanceBloc>().add(const FetchFinances());
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    MonthSelector(
                      selectedMonth: _selectedMonth,
                      onMonthSelected: (newMonth) {
                        setState(() {
                          _selectedMonth = newMonth;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    if (expenses.isEmpty)
                      const EmptyExpenditureSection()
                    else ...[
                      ExpenditureChart(expenses: expenses),
                      const SizedBox(height: 20),
                      ExpenditureSummaryCard(
                        totalExpense: expenses.fold<double>(
                          0.0, // ✅ Ubah dari 0 ke 0.0
                              (sum, item) => sum + item.amount, // ✅ Langsung pakai amount (double)
                        ),
                        transactionCount: expenses.length,
                      ),
                      const SizedBox(height: 20),
                      ExpenditureListSection(expenses: expenses),
                    ],
                  ],
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// ===================================================================
// SECTION: EXPENDITURE CHART
// ===================================================================

class ExpenditureChart extends StatelessWidget {
  final List<Finance> expenses;

  const ExpenditureChart({super.key, required this.expenses});

  List<FlSpot> _chartData() {
    final Map<int, double> daily = {};
    for (var e in expenses) {
      final d = e.date.day;
      daily[d] = (daily[d] ?? 0) + e.amount; // ✅ Sudah double
    }
    return daily.entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList()
      ..sort((a, b) => a.x.compareTo(b.x));
  }

  @override
  Widget build(BuildContext context) {
    final chartData = _chartData();

    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: AbsorbPointer(
        child: LineChart(
          LineChartData(
            gridData: FlGridData(show: false),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      value.toInt().toString(),
                      style: const TextStyle(fontSize: 10),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: chartData,
                isCurved: true,
                color: primaryGreenColor,
                barWidth: 3,
                dotData: FlDotData(show: true),
                belowBarData: BarAreaData(
                  show: true,
                  color: primaryGreenColor.withOpacity(0.2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===================================================================
// SECTION: SUMMARY CARD
// ===================================================================

class ExpenditureSummaryCard extends StatelessWidget {
  final double totalExpense; // ✅ Ubah dari int ke double
  final int transactionCount;

  const ExpenditureSummaryCard({
    super.key,
    required this.totalExpense,
    required this.transactionCount,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [primaryGreenColor, Color(0xFF059669)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total Pengeluaran',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                currencyFormat.format(totalExpense), // ✅ Format double
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$transactionCount Transaksi',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.trending_down,
              color: Colors.white,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }
}

// ===================================================================
// SECTION: LIST SECTION
// ===================================================================

class ExpenditureListSection extends StatelessWidget {
  final List<Finance> expenses;

  const ExpenditureListSection({super.key, required this.expenses});

  Map<String, Map<String, dynamic>> _groupByDate(List<Finance> finances) {
    final Map<String, Map<String, dynamic>> grouped = {};

    for (var f in finances) {
      final dateKey = DateFormat('yyyy-MM-dd').format(f.date);

      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = {
          'date': f.date,
          'count': 0,
          'totalAmount': 0.0, // ✅ Ubah ke 0.0
          'finances': <Finance>[],
        };
      }

      grouped[dateKey]!['count'] += 1;
      grouped[dateKey]!['totalAmount'] += f.amount; // ✅ Sudah double
      (grouped[dateKey]!['finances'] as List<Finance>).add(f);
    }

    return grouped;
  }

  String _formatCurrency(double value) { // ✅ Ubah parameter dari int ke double
    return NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0)
        .format(value);
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupByDate(expenses);
    final dateKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Riwayat Pengeluaran',
              style: TextStyle(
                fontFamily: fontType,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${expenses.length} transaksi',
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
          final financesForDate = data['finances'] as List<Finance>;

          return _ExpenditureCard(
            date: data['date'] as DateTime,
            transactionCount: data['count'] as int,
            totalAmount: data['totalAmount'] as double, // ✅ Cast ke double
            formatCurrency: _formatCurrency,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ExpenditureDetailPage(
                    date: data['date'] as DateTime,
                    finances: financesForDate,
                    formatCurrency: _formatCurrency,
                  ),
                ),
              );
            },
          );
        }),
      ],
    );
  }
}

// ===================================================================
// SECTION: EMPTY STATE
// ===================================================================

class EmptyExpenditureSection extends StatelessWidget {
  const EmptyExpenditureSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          const Text(
            'Belum Ada Data Pengeluaran',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

// ===================================================================
// SECTION: EXPENDITURE CARD (Summary per tanggal)
// ===================================================================

class _ExpenditureCard extends StatelessWidget {
  final DateTime date;
  final int transactionCount;
  final double totalAmount; // ✅ Ubah dari int ke double
  final String Function(double) formatCurrency; // ✅ Ubah parameter dari int ke double
  final VoidCallback onTap;

  const _ExpenditureCard({
    Key? key,
    required this.date,
    required this.transactionCount,
    required this.totalAmount,
    required this.formatCurrency,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
                        mainAxisAlignment: MainAxisAlignment.center,
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
            Expanded(
              flex: 3,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Total Pengeluaran',
                      style: TextStyle(
                        fontFamily: fontType,
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatCurrency(totalAmount),
                      style: const TextStyle(
                        fontFamily: fontType,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.red,
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
}

// ===================================================================
// SECTION: MONTH SELECTOR
// ===================================================================

class MonthSelector extends StatelessWidget {
  final DateTime selectedMonth;
  final Function(DateTime) onMonthSelected;

  const MonthSelector({
    super.key,
    required this.selectedMonth,
    required this.onMonthSelected,
  });

  Future<void> _selectMonth(BuildContext context) async {
    final selected = await showMonthYearPicker(
      context: context,
      initialDate: selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('id'),
    );

    if (selected != null) {
      onMonthSelected(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _selectMonth(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_month, color: primaryGreenColor, size: 20),
                const SizedBox(width: 12),
                Text(
                  DateFormat('MMMM yyyy', 'id').format(selectedMonth),
                  style: const TextStyle(
                    fontFamily: fontType,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
          ],
        ),
      ),
    );
  }
}