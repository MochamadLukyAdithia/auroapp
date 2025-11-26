import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../blocs/financials/finance_bloc.dart';
import '../../../../blocs/financials/finance_event.dart';
import '../../../../blocs/financials/finance_state.dart';
import '../../../../core/theme/theme.dart';
import '../../../../data/models/finance_model.dart';
import '../../../widgets/custom_app_bar.dart';

class FilteredFinancesPage extends StatefulWidget {
  const FilteredFinancesPage({super.key});

  @override
  State<FilteredFinancesPage> createState() => _FilteredFinancesPageState();
}

class _FilteredFinancesPageState extends State<FilteredFinancesPage> {
  DateTime? _startDate;
  DateTime? _endDate;
  FinanceType? _selectedType;
  String _selectedSort = 'date_desc';

  @override
  void initState() {
    super.initState();
    // Load current filter state
    final state = context.read<FinanceBloc>().state;
    if (state is FinanceLoaded) {
      _startDate = state.startDate;
      _endDate = state.endDate;
      _selectedType = state.filterType;
      _selectedSort = state.sortBy ?? 'date_desc';
    }
  }

  void _applyFilter() {
    context.read<FinanceBloc>().add(FilterFinances(
      type: _selectedType,
      startDate: _startDate,
      endDate: _endDate,
      sortBy: _selectedSort,
    ));
    Navigator.pop(context);
  }

  void _resetFilter() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _selectedType = null;
      _selectedSort = 'date_desc';
    });

    context.read<FinanceBloc>().add(const FilterFinances(
      type: null,
      startDate: null,
      endDate: null,
      sortBy: 'date_desc',
    ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Filter Keuangan',
          style: TextStyle(
            fontFamily: fontType,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _resetFilter,
            child: const Text(
              'Reset',
              style: TextStyle(
                fontFamily: fontType,
                color: primaryGreenColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            FilterDateSection(
              startDate: _startDate,
              endDate: _endDate,
              onDateRangeSelected: (start, end) {
                setState(() {
                  _startDate = start;
                  _endDate = end;
                });
              },
            ),
            const SizedBox(height: 24),
            FilterTypeSection(
              selectedType: _selectedType,
              onTypeChanged: (type) {
                setState(() {
                  _selectedType = type;
                });
              },
            ),
            const SizedBox(height: 24),
            FilterOrderSection(
              selectedSort: _selectedSort,
              onSortChanged: (sort) {
                setState(() {
                  _selectedSort = sort;
                });
              },
            ),
            const Spacer(),
            ApplyButton(onPressed: _applyFilter),
          ],
        ),
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

// -------------------- Filter Type --------------------
class FilterTypeSection extends StatelessWidget {
  final FinanceType? selectedType;
  final Function(FinanceType?) onTypeChanged;

  const FilterTypeSection({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Jenis Transaksi',
          style: TextStyle(
            fontFamily: fontType,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        RadioListTile<FinanceType?>(
          title: const Text(
            'Semua',
            style: TextStyle(fontFamily: fontType),
          ),
          value: null,
          groupValue: selectedType,
          onChanged: onTypeChanged,
          contentPadding: EdgeInsets.zero,
          dense: true,
          activeColor: primaryGreenColor,
        ),
        RadioListTile<FinanceType?>(
          title: Row(
            children: [
              Icon(
                Icons.arrow_downward,
                size: 16,
                color: Colors.green[700],
              ),
              const SizedBox(width: 8),
              const Text(
                'Pemasukan',
                style: TextStyle(fontFamily: fontType),
              ),
            ],
          ),
          value: FinanceType.income,
          groupValue: selectedType,
          onChanged: onTypeChanged,
          contentPadding: EdgeInsets.zero,
          dense: true,
          activeColor: primaryGreenColor,
        ),
        RadioListTile<FinanceType?>(
          title: Row(
            children: [
              Icon(
                Icons.arrow_upward,
                size: 16,
                color: Colors.red[700],
              ),
              const SizedBox(width: 8),
              const Text(
                'Pengeluaran',
                style: TextStyle(fontFamily: fontType),
              ),
            ],
          ),
          value: FinanceType.outcome,
          groupValue: selectedType,
          onChanged: onTypeChanged,
          contentPadding: EdgeInsets.zero,
          dense: true,
          activeColor: primaryGreenColor,
        ),
      ],
    );
  }
}

// -------------------- Filter Order --------------------
class FilterOrderSection extends StatelessWidget {
  final String selectedSort;
  final Function(String) onSortChanged;

  const FilterOrderSection({
    super.key,
    required this.selectedSort,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Urutkan Berdasarkan',
          style: TextStyle(
            fontFamily: fontType,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        RadioListTile<String>(
          title: const Text(
            'Tanggal (Terbaru - Lama)',
            style: TextStyle(fontFamily: fontType),
          ),
          value: 'date_desc',
          groupValue: selectedSort,
          onChanged: (value) => onSortChanged(value!),
          contentPadding: EdgeInsets.zero,
          dense: true,
          activeColor: primaryGreenColor,
        ),
        RadioListTile<String>(
          title: const Text(
            'Tanggal (Lama - Terbaru)',
            style: TextStyle(fontFamily: fontType),
          ),
          value: 'date_asc',
          groupValue: selectedSort,
          onChanged: (value) => onSortChanged(value!),
          contentPadding: EdgeInsets.zero,
          dense: true,
          activeColor: primaryGreenColor,
        ),
        RadioListTile<String>(
          title: const Text(
            'Nominal (Tertinggi - Terendah)',
            style: TextStyle(fontFamily: fontType),
          ),
          value: 'amount_desc',
          groupValue: selectedSort,
          onChanged: (value) => onSortChanged(value!),
          contentPadding: EdgeInsets.zero,
          dense: true,
          activeColor: primaryGreenColor,
        ),
        RadioListTile<String>(
          title: const Text(
            'Nominal (Terendah - Tertinggi)',
            style: TextStyle(fontFamily: fontType),
          ),
          value: 'amount_asc',
          groupValue: selectedSort,
          onChanged: (value) => onSortChanged(value!),
          contentPadding: EdgeInsets.zero,
          dense: true,
          activeColor: primaryGreenColor,
        ),
      ],
    );
  }
}

// -------------------- Apply Button --------------------
class ApplyButton extends StatelessWidget {
  final VoidCallback onPressed;

  const ApplyButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreenColor,
          foregroundColor: Colors.white,
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
        onPressed: onPressed,
        child: const Text('Terapkan Filter'),
      ),
    );
  }
}