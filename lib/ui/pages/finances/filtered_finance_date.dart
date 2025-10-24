import 'package:flutter/material.dart';

class FilteredFinancesPage extends StatefulWidget {
  const FilteredFinancesPage({super.key});

  @override
  State<FilteredFinancesPage> createState() => _FilteredFinancesPageState();
}

class _FilteredFinancesPageState extends State<FilteredFinancesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filter Keuangan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            FilterDateSection(),
            SizedBox(height: 20),
            FilterTypeSection(),
            SizedBox(height: 20),
            FilterOrderSection(),
            Spacer(),
            ApplyButton(),
          ],
        ),
      ),
    );
  }
}

// -------------------- Filter Date --------------------
class FilterDateSection extends StatefulWidget {
  const FilterDateSection({super.key});

  @override
  State<FilterDateSection> createState() => _FilterDateSectionState();
}

class _FilterDateSectionState extends State<FilterDateSection> {
  DateTime? _startDate;
  DateTime? _endDate;

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final textColor =
    (_startDate == null || _endDate == null) ? Colors.grey : Colors.black;

    return InkWell(
      onTap: () => _selectDateRange(context),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _startDate == null || _endDate == null
                    ? 'tanggal awal - tanggal akhir'
                    : '${_formatDate(_startDate)} - ${_formatDate(_endDate)}',
                style: TextStyle(color: textColor, fontSize: 16),
              ),
            ),
            const Icon(Icons.calendar_today_outlined, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}


// -------------------- Filter Jenis --------------------
class FilterTypeSection extends StatefulWidget {
  const FilterTypeSection({super.key});

  @override
  State<FilterTypeSection> createState() => _FilterTypeSectionState();
}

class _FilterTypeSectionState extends State<FilterTypeSection> {
  String _selectedJenis = 'Semua';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Jenis',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(),
        RadioListTile<String>(
          title: const Text('Semua'),
          value: 'Semua',
          groupValue: _selectedJenis,
          onChanged: (value) {
            setState(() {
              _selectedJenis = value!;
            });
          },
          contentPadding: EdgeInsets.zero,
          dense: true,
        ),
        RadioListTile<String>(
          title: const Text('Pemasukan'),
          value: 'Pemasukan',
          groupValue: _selectedJenis,
          onChanged: (value) {
            setState(() {
              _selectedJenis = value!;
            });
          },
          contentPadding: EdgeInsets.zero,
          dense: true,
        ),
        RadioListTile<String>(
          title: const Text('Pengeluaran'),
          value: 'Pengeluaran',
          groupValue: _selectedJenis,
          onChanged: (value) {
            setState(() {
              _selectedJenis = value!;
            });
          },
          contentPadding: EdgeInsets.zero,
          dense: true,
        ),
      ],
    );
  }
}

// urutan
class FilterOrderSection extends StatefulWidget {
  const FilterOrderSection({super.key});
  @override
  State<FilterOrderSection> createState() => _FilterOrderSectionState();
}

class _FilterOrderSectionState extends State<FilterOrderSection> {
  String _selectedUrutan = 'Transaksi (Terbaru - Lama)';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Urutan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        RadioListTile<String>(
          title: const Text('Transaksi (Terbaru - Lama)'),
          value: 'Transaksi (Terbaru - Lama)',
          groupValue: _selectedUrutan,
          onChanged: (value) {
            setState(() {
              _selectedUrutan = value!;
            });
          },
          contentPadding: EdgeInsets.zero,
          dense: true,
        ),
        RadioListTile<String>(
          title: const Text('Transaksi (Lama - Terbaru)'),
          value: 'Transaksi (Lama - Terbaru)',
          groupValue: _selectedUrutan,
          onChanged: (value) {
            setState(() {
              _selectedUrutan = value!;
            });
          },
          contentPadding: EdgeInsets.zero,
          dense: true,
        ),
        RadioListTile<String>(
          title: const Text('Nominal Paling Banyak'),
          value: 'Nominal Paling Banyak',
          groupValue: _selectedUrutan,
          onChanged: (value) {
            setState(() {
              _selectedUrutan = value!;
            });
          },
          contentPadding: EdgeInsets.zero,
          dense: true,
        ),
        RadioListTile<String>(
          title: const Text('Nominal Paling Sedikit'),
          value: 'Nominal Paling Sedikit',
          groupValue: _selectedUrutan,
          onChanged: (value) {
            setState(() {
              _selectedUrutan = value!;
            });
          },
          contentPadding: EdgeInsets.zero,
          dense: true,
        ),
      ],
    );
  }
}

// -------------------- Button Terapkan --------------------
class ApplyButton extends StatelessWidget {
  const ApplyButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // Aksi ketika tombol ditekan
          Navigator.pop(context);
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: const Text('Terapkan'),
      ),
    );
  }
}