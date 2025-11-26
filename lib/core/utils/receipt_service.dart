// core/utils/receipt_service.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:share_plus/share_plus.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../data/models/transaction_model.dart';

class ReceiptService {
  // Format rupiah sederhana
  static String _formatCurrency(int amount) {
    final s = amount.abs().toString();
    final chars = <String>[];
    var cnt = 0;
    for (var i = s.length - 1; i >= 0; i--) {
      chars.insert(0, s[i]);
      cnt++;
      if (cnt == 3 && i != 0) {
        chars.insert(0, '.');
        cnt = 0;
      }
    }
    return 'Rp${amount < 0 ? '-' : ''}${chars.join()}';
  }

  // Build PDF document (returns bytes)
  static Future<Uint8List> _buildPdfBytes(TransactionModel transaction) async {
    final doc = pw.Document();
    final date = transaction.transactionDate.toLocal();
    final formattedDate =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final formattedTime =
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.roll80, // cocokkan jika thermal printer; bisa ganti
        build: (context) {
          return <pw.Widget>[
            pw.Header(
                level: 0,
                child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text('Cafe Indonesia', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Jl. Kalimantan', style: pw.TextStyle(fontSize: 10)),
                    ])),
            pw.SizedBox(height: 6),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(formattedDate, style: pw.TextStyle(fontSize: 9)),
                pw.Text(formattedTime, style: pw.TextStyle(fontSize: 9)),
              ],
            ),
            pw.SizedBox(height: 4),
            pw.Divider(),
            pw.SizedBox(height: 4),

            // Items
            ...transaction.items.map((item) {
              return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Expanded(child: pw.Text(item.productName, style: pw.TextStyle(fontSize: 10))),
                          pw.Text(_formatCurrency(item.totalPrice), style: pw.TextStyle(fontSize: 10)),
                        ]),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('${item.quantity} x ${_formatCurrency(item.sellingPrice.toInt())}',
                            style: pw.TextStyle(fontSize: 9)),
                        pw.SizedBox(), // spacer
                      ],
                    ),
                    pw.SizedBox(height: 4),
                  ]);
            }),

            pw.Divider(),

            // Summary
            pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
              pw.Text('Sub Total', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
              pw.Text(_formatCurrency(transaction.subtotal), style: pw.TextStyle(fontSize: 10)),
            ]),
            if (transaction.discount > 0)
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                pw.Text('Diskon', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                pw.Text('-${_formatCurrency(transaction.discount)}', style: pw.TextStyle(fontSize: 10)),
              ]),
            if (transaction.otherCosts > 0)
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                pw.Text('Biaya Lain', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                pw.Text(_formatCurrency(transaction.otherCosts), style: pw.TextStyle(fontSize: 10)),
              ]),
            pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
              pw.Text('Total', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
              pw.Text(_formatCurrency(transaction.totalPayment), style: pw.TextStyle(fontSize: 12)),
            ]),
            pw.SizedBox(height: 6),
            pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
              pw.Text('Bayar (${transaction.paymentMethod})', style: pw.TextStyle(fontSize: 10)),
              pw.Text(_formatCurrency(transaction.receivedAmount), style: pw.TextStyle(fontSize: 10)),
            ]),
            pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
              pw.Text('Kembalian', style: pw.TextStyle(fontSize: 10)),
              pw.Text(_formatCurrency(transaction.changeAmount), style: pw.TextStyle(fontSize: 10)),
            ]),

            pw.SizedBox(height: 12),
            pw.Divider(),
            pw.Center(child: pw.Text('Terima kasih!', style: pw.TextStyle(fontSize: 11))),
            if (transaction.customer != null) pw.SizedBox(height: 4),
            if (transaction.customer != null)
              pw.Text('Pelanggan: ${transaction.customer!.name}', style: pw.TextStyle(fontSize: 9)),
          ];
        },
      ),
    );

    return doc.save();
  }

  // Cetak struk langsung
  static Future<void> printReceipt(TransactionModel transaction) async {
    try {
      final bytes = await _buildPdfBytes(transaction);
      await Printing.layoutPdf(onLayout: (_) => bytes);
    } catch (e) {
      // tangani error cetak
      print('Error printReceipt: $e');
    }
  }

  // Share struk sebagai PDF
  static Future<void> shareReceipt(TransactionModel transaction) async {
    try {
      final bytes = await _buildPdfBytes(transaction);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/receipt_${transaction.id}.pdf');
      await file.writeAsBytes(bytes);

      await Share.shareXFiles([XFile(file.path)], text: 'Struk Transaksi ${transaction.id}');
    } catch (e) {
      print('Error shareReceipt: $e');
    }
  }

  // Generate file untuk preview
  static Future<File> generateReceiptFile(TransactionModel transaction) async {
    final bytes = await _buildPdfBytes(transaction);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/receipt_${transaction.id}.pdf');
    await file.writeAsBytes(bytes);
    return file;
  }
}
