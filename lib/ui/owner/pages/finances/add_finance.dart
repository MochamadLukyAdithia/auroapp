import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/theme.dart';
import '../../../widgets/custom_app_bar.dart';

class AddFinance extends StatefulWidget {
  const AddFinance({super.key});

  @override
  State<AddFinance> createState() => _AddFinanceState();
}

class _AddFinanceState extends State<AddFinance> {
  String _selectedType = 'Pemasukan';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Tambah Catatan Keuangan',
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // biar rata kiri
      children: [
        const Text(
          'Tipe Transaksi*',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: fontType,
          ),
        ),
        const SizedBox(height: 8),
        Row(
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nama Transaksi',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, fontFamily: fontType),
        ),
        const SizedBox(height: 8),
        TextFormField(
          decoration: InputDecoration(
            hintText: 'Masukkan nama transaksi',
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14, fontFamily: fontType),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }
}

// nominal
class NominalField extends StatelessWidget {
  const NominalField({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nominal',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: fontType,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          decoration: InputDecoration(
            hintText: 'Masukkan nominal',
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
              fontFamily: fontType,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
        ),
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
  DateTime? selectedDate;
  final TextEditingController _controller = TextEditingController();

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
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
      setState(() {
        selectedDate = picked;
        _controller.text =
        '${picked.day} ${_monthName(picked.month)} ${picked.year}';
      });
    }
  }

  void _clearDate() {
    setState(() {
      selectedDate = null;
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tanggal Transaksi*',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: fontType,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _controller,
          readOnly: true,
          onTap: () => _pickDate(context),
          style: TextStyle(
            // kalau belum pilih, tampilkan teks abu-abu
            color: selectedDate == null ? Colors.grey[400] : Colors.black,
            fontSize: 14,
            fontFamily: fontType,
          ),
          decoration: InputDecoration(
            hintText: 'Pilih tanggal transaksi',
            hintStyle: TextStyle(
              color: Colors.grey[400], // abu-abu untuk hint
              fontSize: 14,
              fontFamily: fontType,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (selectedDate != null)
                  IconButton(
                    icon: const Icon(Icons.clear, size: 20),
                    onPressed: _clearDate,
                    tooltip: 'Hapus tanggal',
                  ),
                IconButton(
                  icon: const Icon(Icons.calendar_today_outlined, size: 20),
                  onPressed: () => _pickDate(context),
                ),
              ],
            ),
          ),
        ),
      ],
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Keterangan',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, fontFamily: fontType),
        ),
        const SizedBox(height: 8),
        TextFormField(
          decoration: InputDecoration(
            hintText: 'Masukan keterangan keuangan',
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14, fontFamily: fontType),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
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
      height: 48,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreenColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          'Simpan',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontFamily: fontType,
          ),
        ),
      ),
    );
  }
}