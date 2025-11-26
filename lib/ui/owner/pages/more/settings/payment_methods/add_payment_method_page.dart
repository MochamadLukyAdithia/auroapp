// import 'package:dropdown_search/dropdown_search.dart';
// import 'package:flutter/material.dart';
// import 'package:pos_mobile/ui/widgets/custom_app_bar.dart';
//
// import '../../../../../../core/theme/theme.dart';
//
// class AddPaymentMethodPage extends StatefulWidget {
//   const AddPaymentMethodPage({super.key});
//
//   @override
//   State<AddPaymentMethodPage> createState() => _AddPaymentMethodPageState();
// }
//
// class _AddPaymentMethodPageState extends State<AddPaymentMethodPage> {
//   String? selectedBank;
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: const CustomAppBar(title: 'Tambah Rekening'),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const PaymentMethodName(),
//             const SizedBox(height: 16),
//             BankSelectionField(
//               selectedBank: selectedBank,
//               onChanged: (value) {
//                 setState(() {
//                   selectedBank = value;
//                 });
//               },
//               errorText: selectedBank == null ? 'Wajib dipilih' : null,
//             ),
//             const SizedBox(height: 16),
//             const PaymentMethodNumber(),
//             // const SizedBox(height: 16),
//             // const BankPhotoSection(),
//             const SizedBox(height: 24),
//             const SavePaymentMethodButton(),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
//
// //foto bank nya
// // class BankPhotoSection extends StatelessWidget {
// //   const BankPhotoSection({super.key});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         const Text(
// //           'Foto cover depan tabungan bank',
// //           style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, fontFamily: fontType),
// //         ),
// //         const SizedBox(height: 8),
// //         Container(
// //           width: 60,
// //           height: 60,
// //           decoration: BoxDecoration(
// //             color: Colors.grey[200],
// //             borderRadius: BorderRadius.circular(8),
// //           ),
// //           child: Column(
// //             mainAxisAlignment: MainAxisAlignment.center,
// //             children: [
// //               Icon(Icons.add_photo_alternate_outlined, color: Colors.grey[600], size: 24),
// //               const SizedBox(height: 2),
// //               Text(
// //                 'Upload',
// //                 style: TextStyle(fontSize: 10, color: Colors.grey[600], fontFamily: fontType),
// //               ),
// //             ],
// //           ),
// //         ),
// //         // const SizedBox(height: 4),
// //         // Text(
// //         //   'Format gambar .jpg .jpeg .png dan Ukuran file 5MB (Gunakan ukuran minimum 500 x 500 pxl).',
// //         //   style: TextStyle(fontSize: 11, color: Colors.grey[600], fontFamily: fontType, fontWeight: FontWeight.w300),
// //         // ),
// //       ],
// //     );
// //   }
// // }
//
// // nama pemilik bank nya
// class PaymentMethodName extends StatelessWidget {
//   const PaymentMethodName({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Nama Pemilik',
//           style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, fontFamily: fontType),
//         ),
//         const SizedBox(height: 8),
//         TextFormField(
//           decoration: InputDecoration(
//             hintText: "Contoh: Owner's",
//             hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14, fontFamily: fontType),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: BorderSide(color: Colors.grey[300]!),
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: BorderSide(color: Colors.grey[300]!),
//             ),
//             contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// // pilih bank
// class BankSelectionField extends StatelessWidget {
//   final String? selectedBank;
//   final ValueChanged<String?>? onChanged;
//   final String? errorText;
//
//   const BankSelectionField({
//     super.key,
//     this.selectedBank,
//     this.onChanged,
//     this.errorText,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final List<String> banks = [
//       'Bank BCA',
//       'Bank Mandiri',
//       'Bank BRI',
//       'Bank BNI',
//       'Bank CIMB Niaga',
//       'Bank Danamon',
//       'Bank Permata',
//       'Bank BTN',
//       'Bank Mega',
//       'Bank Jago',
//       'SeaBank',
//     ];
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Nama Bank',
//           style: TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         const SizedBox(height: 8),
//         DropdownSearch<String>(
//           items: (filter, infiniteScrollProps) async => banks,
//           selectedItem: selectedBank,
//           popupProps: const PopupProps.menu(
//             showSearchBox: false,
//             fit: FlexFit.loose,
//           ),
//           decoratorProps: DropDownDecoratorProps(
//             decoration: InputDecoration(
//               hintText: 'Cari atau pilih bank',
//               contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//               border: const OutlineInputBorder(),
//               errorText: errorText,
//             ),
//           ),
//           onChanged: onChanged,
//           compareFn: (item1, item2) => item1 == item2,
//           filterFn: (item, filter) {
//             return item.toLowerCase().contains(filter.toLowerCase());
//           },
//           dropdownBuilder: (context, selectedItem) {
//             return Text(
//               selectedItem ?? '',
//               style: const TextStyle(fontSize: 14),
//             );
//           },
//         ),
//       ],
//     );
//   }
// }
//
// // nomor rekening
// class PaymentMethodNumber extends StatelessWidget {
//   const PaymentMethodNumber({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Nomor Rekening',
//           style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, fontFamily: fontType),
//         ),
//         const SizedBox(height: 8),
//         TextFormField(
//           decoration: InputDecoration(
//             hintText: "Contoh: 5432523",
//             hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14, fontFamily: fontType),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: BorderSide(color: Colors.grey[300]!),
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: BorderSide(color: Colors.grey[300]!),
//             ),
//             contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
//           ),
//           keyboardType: TextInputType.number,
//         ),
//       ],
//     );
//   }
// }
//
// // save button
// class SavePaymentMethodButton extends StatelessWidget {
//   const SavePaymentMethodButton({super.key});
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: double.infinity,
//       height: 48,
//       child: ElevatedButton(
//         onPressed: () {
//
//         },
//         style: ElevatedButton.styleFrom(
//           backgroundColor: primaryGreenColor,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(8),
//           ),
//         ),
//         child: const Text(
//           'Simpan',
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//             color: Colors.white,
//             fontFamily: fontType,
//           ),
//         ),
//       ),
//     );
//   }
// }