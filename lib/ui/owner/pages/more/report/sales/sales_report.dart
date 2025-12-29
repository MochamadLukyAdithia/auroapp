import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pos_mobile/data/models/transaction_sales_report_model.dart';
import 'package:pos_mobile/ui/owner/pages/more/report/sales/transaction_detail.dart';
import '../../../../../../blocs/sales_report/sales_report_cubit.dart';
import '../../../../../../core/theme/theme.dart';
import '../../../../../../core/utils/auth_service.dart';
import '../../../../../widgets/custom_app_bar.dart';

class SalesReportPage extends StatefulWidget {
  const SalesReportPage({super.key});

  @override
  State<SalesReportPage> createState() => _SalesReportPageState();
}

class _SalesReportPageState extends State<SalesReportPage> {
  bool _isCashier = false; // ✅ Track role
  bool _isLoading = true; // ✅ Loading state

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  // ✅ Check role dan load data yang sesuai
  Future<void> _initializeData() async {
    final isCashier = await AuthService.isCashier();
    setState(() {
      _isCashier = isCashier;
      _isLoading = false;
    });

    if (mounted) {
      if (_isCashier) {
        context.read<SalesReportCubit>().loadCashierTransactions();
      } else {
        context.read<SalesReportCubit>().loadTransactions();
      }
    }
  }

  // Helper
  String _formatCurrency(double value) {
    return NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0)
        .format(value);
  }

  // ✅ Handle refresh berdasarkan role
  Future<void> _handleRefresh() async {
    if (_isCashier) {
      return context.read<SalesReportCubit>().loadCashierTransactions();
    } else {
      return context.read<SalesReportCubit>().loadTransactions();
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Show loading saat check role
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: const CustomAppBar(title: 'Laporan Penjualan'),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: const CustomAppBar(title: 'Laporan Penjualan'),
      body: BlocBuilder<SalesReportCubit, SalesReportState>(
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: _handleRefresh, // ✅ Gunakan handler yang sudah cek role
            color: primaryGreenColor,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✅ BADGE ROLE (Optional - untuk debugging/info)
                  if (_isCashier)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.info_outline, size: 16, color: Colors.blue.shade700),
                          const SizedBox(width: 6),
                          Text(
                            'Menampilkan transaksi Anda saja',
                            style: TextStyle(
                              fontFamily: fontType,
                              fontSize: 12,
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // === FILTER DATE RANGE ===
                  FilterDateSection(
                    startDate: state.startDate,
                    endDate: state.endDate,
                    onDateRangeSelected: (start, end) {
                      context.read<SalesReportCubit>().setDateRange(start, end, isCashier: _isCashier);
                    },
                  ),
                  // Reset button jika ada custom date
                  if (state.startDate != null && state.endDate != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: TextButton.icon(
                        onPressed: () {
                          final cubit = context.read<SalesReportCubit>();
                          cubit.setDateRange(null, null, isCashier: _isCashier);
                        },
                        icon: const Icon(Icons.clear, size: 16),
                        label: const Text('Reset ke Periode'),
                        style: TextButton.styleFrom(
                          foregroundColor: primaryGreenColor,
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // === FILTER PERIODE ===
                  _PeriodSelector(
                    selectedPeriod: state.selectedPeriod,
                    onPeriodChanged: (period) {
                      context.read<SalesReportCubit>().setPeriod(period, isCashier: _isCashier);
                    },
                  ),

                  const SizedBox(height: 20),

                  // === RINGKASAN PENJUALAN ===
                  _SalesSummarySection(state: state, formatCurrency: _formatCurrency),
                  const SizedBox(height: 24),

                  // === GRAFIK PENJUALAN ===
                  _SalesChartSection(
                    data: state.chartData,
                    period: state.selectedPeriod,
                  ),
                  const SizedBox(height: 24),

                  // === RIWAYAT TRANSAKSI ===
                  _TransactionListSection(
                    transactions: state.transactions,
                    formatCurrency: _formatCurrency,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// -------------------- Filter Date --------------------
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

// -------------------- summary section --------------------
class _SalesSummarySection extends StatelessWidget {
  final SalesReportState state;
  final String Function(double) formatCurrency;

  const _SalesSummarySection({
    required this.state,
    required this.formatCurrency,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                title: 'Total Pendapatan',
                value: formatCurrency(state.totalSales),
                icon: Icons.payments,
                color: primaryGreenColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                title: 'Keuntungan',
                value: formatCurrency(state.totalProfit),
                icon: Icons.trending_up,
                color: Colors.amber.shade700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                title: 'Transaksi',
                value: '${state.totalTransactions}',
                icon: Icons.receipt_long,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                title: 'Total Item Terjual',
                value: '${state.totalItemsSold.toInt()} item',
                icon: Icons.shopping_cart,
                color: Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

// -------------------- Graphics (Chart) --------------------
class _SalesChartSection extends StatelessWidget {
  final Map<DateTime, double> data;
  final ReportPeriod period;

  const _SalesChartSection({
    required this.data,
    required this.period,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🆕 Header dengan info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Grafik Penjualan',
                style: TextStyle(
                  fontFamily: fontType,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              // 🆕 Legend
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryGreenColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: primaryGreenColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Pendapatan',
                      style: TextStyle(
                        fontFamily: fontType,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: primaryGreenColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 🆕 Keterangan periode
          Text(
            _getPeriodDescription(period),
            style: TextStyle(
              fontFamily: fontType,
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 220, // Tinggi ditambah sedikit
            child: _SalesChart(data: data, period: period),
          ),
        ],
      ),
    );
  }

  String _getPeriodDescription(ReportPeriod period) {
    switch (period) {
      case ReportPeriod.today:
        return 'Penjualan per jam hari ini';
      case ReportPeriod.week:
        return 'Penjualan 7 hari terakhir';
      case ReportPeriod.month:
        return 'Penjualan bulan ini';
      case ReportPeriod.year:
        return 'Penjualan tahun ini';
      default:
        return 'Penjualan periode dipilih';
    }
  }
}

// ===================================================================
// SECTION: TRANSACTION LIST
// ===================================================================
class _TransactionListSection extends StatelessWidget {
  final List<TransactionReport> transactions;
  final String Function(double) formatCurrency;

  const _TransactionListSection({
    required this.transactions,
    required this.formatCurrency,
  });

  Map<String, Map<String, dynamic>> _groupByDate(List<TransactionReport> transactions) {
    final Map<String, Map<String, dynamic>> grouped = {};
    for (var t in transactions) {
      final dateKey = t.tanggal.split(' ')[0];
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = {
          'date': DateTime.parse(t.tanggal),
          'count': 0,
          'totalRevenue': 0.0,
          'totalProfit': 0.0,
          'transactions': <TransactionReport>[],
        };
      }
      grouped[dateKey]!['count'] += 1;
      grouped[dateKey]!['totalRevenue'] += t.totalPenjualan;
      grouped[dateKey]!['totalProfit'] += t.keuntungan;
      grouped[dateKey]!['transactions'].add(t);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(Icons.receipt_long_outlined,
                  size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                'Belum ada transaksi',
                style: TextStyle(
                  fontFamily: fontType,
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final grouped = _groupByDate(transactions);
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
              '${transactions.length} transaksi',
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
          final transactionsForDate = data['transactions'] as List<TransactionReport>;

          return _TransactionCard(
            date: data['date'],
            transactionCount: data['count'],
            totalRevenue: data['totalRevenue'],
            totalProfit: data['totalProfit'],
            formatCurrency: formatCurrency,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TransactionDetailPage(
                    date: data['date'],
                    transactions: transactionsForDate,
                    formatCurrency: formatCurrency,
                  ),
                ),
              );
            },
          );
        }).toList(),
      ],
    );
  }
}

// ===================================================================
// SECTION: REUSABLE WIDGETS (TIDAK BERUBAH)
// ===================================================================
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? primaryGreenColor : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? primaryGreenColor : Colors.grey.shade300,
                  ),
                ),
                child: Text(
                  period.displayName,
                  style: TextStyle(
                    fontFamily: fontType,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : Colors.grey.shade700,
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

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(title,
              style: TextStyle(
                fontFamily: fontType,
                fontSize: 12,
                color: Colors.grey.shade600,
              )),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                fontFamily: fontType,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              )),
        ],
      ),
    );
  }
}

// ===================================================================
// SECTION: SALES CHART
// ===================================================================
class _SalesChart extends StatelessWidget {
  final Map<DateTime, double> data;
  final ReportPeriod period;

  const _SalesChart({required this.data, required this.period});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty || data.values.every((v) => v == 0)) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart_outlined, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 8),
            Text(
              'Belum ada data penjualan',
              style: TextStyle(
                fontFamily: fontType,
                color: Colors.grey.shade400,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    final sortedEntries = data.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    final maxY = sortedEntries
        .map((e) => e.value)
        .reduce((a, b) => a > b ? a : b);

    final spots = sortedEntries
        .asMap()
        .entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value.value))
        .toList();

    return LineChart(
      LineChartData(
        // 🆕 TOOLTIP INTERAKTIF
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) => Colors.black87,
            tooltipBorder: const BorderSide(color: Colors.transparent),
            tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final index = spot.x.toInt();
                if (index < 0 || index >= sortedEntries.length) {
                  return null;
                }

                final date = sortedEntries[index].key;
                final value = spot.y;

                String dateLabel;
                if (period == ReportPeriod.today) {
                  dateLabel = DateFormat('HH:00').format(date);
                } else if (period == ReportPeriod.week) {
                  dateLabel = DateFormat('EEE, dd MMM', 'id').format(date);
                } else {
                  dateLabel = DateFormat('dd MMM yyyy', 'id').format(date);
                }

                return LineTooltipItem(
                  '$dateLabel\n${NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(value)}',
                  const TextStyle(
                    fontFamily: fontType,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                );
              }).toList();
            },
          ),
          touchCallback: (event, response) {},
          handleBuiltInTouches: true,
        ),

        gridData: FlGridData(
          show: true,
          drawVerticalLine: true, // 🆕 Tampilkan garis vertikal
          verticalInterval: 1,
          horizontalInterval: maxY > 0 ? maxY / 4 : 1000,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey.shade200,
            strokeWidth: 1,
          ),
          getDrawingVerticalLine: (value) => FlLine(
            color: Colors.grey.shade100,
            strokeWidth: 1,
          ),
        ),

        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 55, // Lebih lebar
              interval: maxY > 0 ? maxY / 4 : 1000,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    NumberFormat.compact(locale: 'id').format(value),
                    style: TextStyle(
                      fontFamily: fontType,
                      fontSize: 11,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.right,
                  ),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              interval: _getBottomInterval(sortedEntries.length),
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= sortedEntries.length) {
                  return const SizedBox();
                }

                final date = sortedEntries[index].key;
                String label;

                if (period == ReportPeriod.today) {
                  label = DateFormat('HH:00').format(date);
                } else if (period == ReportPeriod.week) {
                  label = DateFormat('EEE', 'id').format(date);
                } else if (period == ReportPeriod.month) {
                  label = date.day.toString();
                } else {
                  label = DateFormat('MMM', 'id').format(date).substring(0, 3);
                }

                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontFamily: fontType,
                      fontSize: 11,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        borderData: FlBorderData(
          show: true,
          border: Border(
            left: BorderSide(color: Colors.grey.shade300, width: 1),
            bottom: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
        ),

        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.3,
            color: primaryGreenColor,
            barWidth: 3,
            isStrokeCapRound: true,
            // 🆕 Tampilkan dot di setiap titik
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: Colors.white,
                  strokeWidth: 2,
                  strokeColor: primaryGreenColor,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  primaryGreenColor.withOpacity(0.2),
                  primaryGreenColor.withOpacity(0.05),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],

        minY: 0,
        maxY: maxY * 1.15, // Lebih proporsional
      ),
    );
  }

  // 🆕 Helper untuk interval label bawah
  double _getBottomInterval(int dataLength) {
    if (dataLength <= 7) return 1;
    if (dataLength <= 14) return 2;
    if (dataLength <= 31) return 3;
    return 5;
  }
}

// ===================================================================
// SECTION: TRANSACTION CARD (Summary per tanggal)
// ===================================================================
class _TransactionCard extends StatelessWidget {
  final DateTime date;
  final int transactionCount;
  final double totalRevenue;
  final double totalProfit;
  final String Function(double) formatCurrency;
  final VoidCallback onTap;

  const _TransactionCard({
    Key? key,
    required this.date,
    required this.transactionCount,
    required this.totalRevenue,
    required this.totalProfit,
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
                        fontWeight: FontWeight.w600),
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
                        fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Pendapatan',
                        style: TextStyle(
                            fontFamily: fontType,
                            fontSize: 12,
                            color: Colors.black,
                            fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        formatCurrency(totalRevenue),
                        style: const TextStyle(
                          fontFamily: fontType,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF4CAF50),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Keuntungan',
                        style: TextStyle(
                            fontFamily: fontType,
                            fontSize: 12,
                            color: Colors.black,
                            fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        formatCurrency(totalProfit),
                        style: const TextStyle(
                          fontFamily: fontType,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2196F3),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
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