import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UpdateFinance extends StatefulWidget {
  const UpdateFinance({super.key});

  @override
  State<UpdateFinance> createState() => _UpdateFinanceState();
}

class _UpdateFinanceState extends State<UpdateFinance> {
  String _selectedType = 'Pemasukan';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Catatan Keuangan'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            FinanceTypeSelector(
              selectedType: _selectedType,
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedType = val);
                }
              },
            ),
            const SizedBox(height: 16),
            const TransactionNameField(),
            const SizedBox(height: 16),
            const NominalField(),
            const SizedBox(height: 16),
            const DatePickerField(),
            const SizedBox(height: 16),
            const NotesField(),
            const SizedBox(height: 24),
            const SaveButton(),
          ],
        ),
      ),
    );
  }
}

// ---------------- Widget ----------------

// radiobutton
class FinanceTypeSelector extends StatelessWidget {
  final String selectedType;
  final ValueChanged<String?> onChanged;

  const FinanceTypeSelector({
    super.key,
    required this.selectedType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: RadioListTile<String>(
            title: const Text('Pemasukan'),
            value: 'Pemasukan',
            groupValue: selectedType,
            onChanged: onChanged,
          ),
        ),
        Expanded(
          child: RadioListTile<String>(
            title: const Text('Pengeluaran'),
            value: 'Pengeluaran',
            groupValue: selectedType,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

// nama transaksi
class TransactionNameField extends StatelessWidget {
  const TransactionNameField({super.key});
  @override
  Widget build(BuildContext context) {
    return const TextField(
      decoration: InputDecoration(
        labelText: 'Nama Transaksi',
        hintText: 'Contoh: Promosi',
        border: OutlineInputBorder(),
        isDense: true,
      ),
    );
  }
}

// nominal
class NominalField extends StatelessWidget {
  const NominalField({super.key});
  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: const InputDecoration(
        labelText: 'Nominal',
        hintText: 'Rp 0',
        border: OutlineInputBorder(),
        isDense: true,
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
    );
  }
}

// tanggal
class DatePickerField extends StatefulWidget {
  const DatePickerField({super.key});
  @override
  State<DatePickerField> createState() => _DatePickerFieldState();
}

class _DatePickerFieldState extends State<DatePickerField> {
  DateTime selectedDate = DateTime.now();

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDate) {
      setState(() => selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      readOnly: true,
      decoration: InputDecoration(
        labelText: 'Tanggal',
        hintText:
        '${selectedDate.day} ${_monthName(selectedDate.month)} ${selectedDate.year}',
        border: const OutlineInputBorder(),
        isDense: true,
        suffixIcon: IconButton(
          icon: const Icon(Icons.calendar_today_outlined),
          onPressed: () => _pickDate(context),
        ),
      ),
    );
  }

  String _monthName(int month) {
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
    return months[month - 1];
  }
}

// keterangan
class NotesField extends StatelessWidget {
  const NotesField({super.key});

  @override
  Widget build(BuildContext context) {
    return const TextField(
      decoration: InputDecoration(
        labelText: 'Keterangan',
        hintText: 'Contoh: Lunas',
        border: OutlineInputBorder(),
        isDense: true,
      ),
    );
  }
}

// button simpan
class SaveButton extends StatelessWidget {
  const SaveButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {},
        child: const Text('Simpan'),
      ),
    );
  }
}
