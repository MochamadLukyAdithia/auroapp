// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import '../../../../core/theme/theme.dart';
// import '../../../../data/models/finance_model.dart';
// import '../../../widgets/custom_app_bar.dart';
//
// class UpdateFinancePage extends StatefulWidget {
//   final Finance finance; // ✅ Terima data finance yang akan diupdate
//
//   const UpdateFinancePage({
//     super.key,
//     required this.finance,
//   });
//
//   @override
//   State<UpdateFinancePage> createState() => _UpdateFinancePageState();
// }
//
// class _UpdateFinancePageState extends State<UpdateFinancePage> {
//   final _formKey = GlobalKey<FormState>();
//   late TextEditingController _nameController;
//   late TextEditingController _amountController;
//   late TextEditingController _notesController;
//
//   late FinanceType _selectedType;
//   late DateTime _selectedDate;
//
//   @override
//   void initState() {
//     super.initState();
//     // ✅ Inisialisasi dengan data existing
//     _nameController = TextEditingController(text: widget.finance.name);
//     _amountController = TextEditingController(text: widget.finance.amount.toString());
//     _notesController = TextEditingController(text: widget.finance.notes ?? '');
//     _selectedType = widget.finance.type;
//     _selectedDate = widget.finance.date;
//   }
//
//   @override
//   void dispose() {
//     _nameController.dispose();
//     _amountController.dispose();
//     _notesController.dispose();
//     super.dispose();
//   }
//
//   void _updateFinance() {
//     if (_formKey.currentState!.validate()) {
//       final updatedFinance = widget.finance.copyWith(
//         name: _nameController.text.trim(),
//         amount: int.parse(_amountController.text.trim()),
//         type: _selectedType,
//         date: _selectedDate,
//         notes: _notesController.text.trim().isEmpty
//             ? null
//             : _notesController.text.trim(),
//       );
//
//       Navigator.pop(context, updatedFinance);
//     }
//   }
//
//   void _deleteFinance() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text(
//           'Hapus Catatan',
//           style: TextStyle(
//             fontFamily: fontType,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         content: const Text(
//           'Apakah Anda yakin ingin menghapus catatan keuangan ini?',
//           style: TextStyle(fontFamily: fontType),
//         ),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text(
//               'Batal',
//               style: TextStyle(
//                 fontFamily: fontType,
//                 color: Colors.grey,
//               ),
//             ),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context); // Close dialog
//               Navigator.pop(context, 'delete'); // Return delete action
//             },
//             child: const Text(
//               'Hapus',
//               style: TextStyle(
//                 fontFamily: fontType,
//                 color: Colors.red,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'Update Catatan Keuangan',
//           style: TextStyle(
//             fontFamily: fontType,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.close),
//           onPressed: () => Navigator.pop(context),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.delete_outline, color: Colors.red),
//             onPressed: _deleteFinance,
//             tooltip: 'Hapus',
//           ),
//         ],
//       ),
//       body: Form(
//         key: _formKey,
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24),
//           child: Column(
//             children: [
//               FinanceTypeSelector(
//                 selectedType: _selectedType,
//                 onChanged: (type) {
//                   setState(() => _selectedType = type);
//                 },
//               ),
//               const SizedBox(height: 24),
//               TransactionNameField(controller: _nameController),
//               const SizedBox(height: 24),
//               NominalField(controller: _amountController),
//               const SizedBox(height: 24),
//               DatePickerField(
//                 selectedDate: _selectedDate,
//                 onDateSelected: (date) {
//                   setState(() => _selectedDate = date);
//                 },
//               ),
//               const SizedBox(height: 24),
//               NotesField(controller: _notesController),
//               const SizedBox(height: 32),
//               UpdateButton(onPressed: _updateFinance),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // -------------------- Type Selector --------------------
// class FinanceTypeSelector extends StatelessWidget {
//   final FinanceType selectedType;
//   final ValueChanged<FinanceType> onChanged;
//
//   const FinanceTypeSelector({
//     super.key,
//     required this.selectedType,
//     required this.onChanged,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Tipe Transaksi*',
//           style: TextStyle(
//             fontFamily: fontType,
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//             color: Colors.black87,
//           ),
//         ),
//         const SizedBox(height: 12),
//         Row(
//           children: [
//             Expanded(
//               child: _TypeButton(
//                 label: 'Pemasukan',
//                 icon: Icons.arrow_downward,
//                 isSelected: selectedType == FinanceType.income,
//                 color: Colors.green,
//                 onTap: () => onChanged(FinanceType.income),
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: _TypeButton(
//                 label: 'Pengeluaran',
//                 icon: Icons.arrow_upward,
//                 isSelected: selectedType == FinanceType.expense,
//                 color: Colors.red,
//                 onTap: () => onChanged(FinanceType.expense),
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }
//
// class _TypeButton extends StatelessWidget {
//   final String label;
//   final IconData icon;
//   final bool isSelected;
//   final Color color;
//   final VoidCallback onTap;
//
//   const _TypeButton({
//     required this.label,
//     required this.icon,
//     required this.isSelected,
//     required this.color,
//     required this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(12),
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 16),
//         decoration: BoxDecoration(
//           color: isSelected ? color.withOpacity(0.1) : Colors.grey[100],
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             color: isSelected ? color : Colors.grey[300]!,
//             width: isSelected ? 2 : 1,
//           ),
//         ),
//         child: Column(
//           children: [
//             Icon(
//               icon,
//               color: isSelected ? color : Colors.grey,
//               size: 28,
//             ),
//             const SizedBox(height: 8),
//             Text(
//               label,
//               style: TextStyle(
//                 fontFamily: fontType,
//                 fontSize: 14,
//                 fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
//                 color: isSelected ? color : Colors.grey[600],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // -------------------- Transaction Name --------------------
// class TransactionNameField extends StatelessWidget {
//   final TextEditingController controller;
//
//   const TransactionNameField({
//     super.key,
//     required this.controller,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Nama Transaksi*',
//           style: TextStyle(
//             fontFamily: fontType,
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//             color: Colors.black87,
//           ),
//         ),
//         const SizedBox(height: 8),
//         TextFormField(
//           controller: controller,
//           validator: (value) {
//             if (value == null || value.trim().isEmpty) {
//               return 'Nama transaksi wajib diisi';
//             }
//             return null;
//           },
//           style: const TextStyle(
//             fontFamily: fontType,
//             fontSize: 15,
//           ),
//           decoration: InputDecoration(
//             hintText: 'Contoh: Gaji Bulanan',
//             hintStyle: TextStyle(
//               fontFamily: fontType,
//               color: Colors.grey[400],
//               fontSize: 14,
//             ),
//             contentPadding: const EdgeInsets.symmetric(
//               horizontal: 16,
//               vertical: 14,
//             ),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: BorderSide(color: Colors.grey[300]!),
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: BorderSide(color: Colors.grey[300]!),
//             ),
//             focusedBorder: const OutlineInputBorder(
//               borderRadius: BorderRadius.all(Radius.circular(8)),
//               borderSide: BorderSide(
//                 color: primaryGreenColor,
//                 width: 2,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// // -------------------- Nominal --------------------
// class NominalField extends StatelessWidget {
//   final TextEditingController controller;
//
//   const NominalField({
//     super.key,
//     required this.controller,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Nominal*',
//           style: TextStyle(
//             fontFamily: fontType,
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//             color: Colors.black87,
//           ),
//         ),
//         const SizedBox(height: 8),
//         TextFormField(
//           controller: controller,
//           validator: (value) {
//             if (value == null || value.trim().isEmpty) {
//               return 'Nominal wajib diisi';
//             }
//             if (int.tryParse(value) == null || int.parse(value) <= 0) {
//               return 'Nominal harus lebih dari 0';
//             }
//             return null;
//           },
//           keyboardType: TextInputType.number,
//           inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//           style: const TextStyle(
//             fontFamily: fontType,
//             fontSize: 15,
//           ),
//           decoration: InputDecoration(
//             hintText: 'Contoh: 5000000',
//             prefixText: 'Rp ',
//             hintStyle: TextStyle(
//               fontFamily: fontType,
//               color: Colors.grey[400],
//               fontSize: 14,
//             ),
//             contentPadding: const EdgeInsets.symmetric(
//               horizontal: 16,
//               vertical: 14,
//             ),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: BorderSide(color: Colors.grey[300]!),
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: BorderSide(color: Colors.grey[300]!),
//             ),
//             focusedBorder: const OutlineInputBorder(
//               borderRadius: BorderRadius.all(Radius.circular(8)),
//               borderSide: BorderSide(
//                 color: primaryGreenColor,
//                 width: 2,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// // -------------------- Date Picker --------------------
// class DatePickerField extends StatelessWidget {
//   final DateTime selectedDate;
//   final ValueChanged<DateTime> onDateSelected;
//
//   const DatePickerField({
//     super.key,
//     required this.selectedDate,
//     required this.onDateSelected,
//   });
//
//   Future<void> _pickDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: selectedDate,
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2100),
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: const ColorScheme.light(
//               primary: primaryGreenColor,
//               onPrimary: Colors.white,
//               onSurface: Colors.black,
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );
//
//     if (picked != null) {
//       onDateSelected(picked);
//     }
//   }
//
//   String _formatDate(DateTime date) {
//     const months = [
//       'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
//       'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
//     ];
//     return '${date.day} ${months[date.month - 1]} ${date.year}';
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Tanggal Transaksi*',
//           style: TextStyle(
//             fontFamily: fontType,
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//             color: Colors.black87,
//           ),
//         ),
//         const SizedBox(height: 8),
//         InkWell(
//           onTap: () => _pickDate(context),
//           borderRadius: BorderRadius.circular(8),
//           child: Container(
//             padding: const EdgeInsets.symmetric(
//               horizontal: 16,
//               vertical: 14,
//             ),
//             decoration: BoxDecoration(
//               border: Border.all(color: Colors.grey[300]!),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   _formatDate(selectedDate),
//                   style: const TextStyle(
//                     fontFamily: fontType,
//                     fontSize: 15,
//                     color: Colors.black87,
//                   ),
//                 ),
//                 const Icon(Icons.calendar_today_outlined, size: 20),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// // -------------------- Notes --------------------
// class NotesField extends StatelessWidget {
//   final TextEditingController controller;
//
//   const NotesField({
//     super.key,
//     required this.controller,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Keterangan (Opsional)',
//           style: TextStyle(
//             fontFamily: fontType,
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//             color: Colors.black87,
//           ),
//         ),
//         const SizedBox(height: 8),
//         TextFormField(
//           controller: controller,
//           maxLines: 3,
//           style: const TextStyle(
//             fontFamily: fontType,
//             fontSize: 15,
//           ),
//           decoration: InputDecoration(
//             hintText: 'Tambahkan keterangan (opsional)',
//             hintStyle: TextStyle(
//               fontFamily: fontType,
//               color: Colors.grey[400],
//               fontSize: 14,
//             ),
//             contentPadding: const EdgeInsets.symmetric(
//               horizontal: 16,
//               vertical: 14,
//             ),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: BorderSide(color: Colors.grey[300]!),
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: BorderSide(color: Colors.grey[300]!),
//             ),
//             focusedBorder: const OutlineInputBorder(
//               borderRadius: BorderRadius.all(Radius.circular(8)),
//               borderSide: BorderSide(
//                 color: primaryGreenColor,
//                 width: 2,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// // -------------------- Update Button --------------------
// class UpdateButton extends StatelessWidget {
//   final VoidCallback onPressed;
//
//   const UpdateButton({
//     super.key,
//     required this.onPressed,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: double.infinity,
//       height: 50,
//       child: ElevatedButton(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: primaryGreenColor,
//           foregroundColor: Colors.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(8),
//           ),
//           elevation: 0,
//           textStyle: const TextStyle(
//             fontFamily: fontType,
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         onPressed: onPressed,
//         child: const Text('Update Catatan Keuangan'),
//       ),
//     );
//   }
// }