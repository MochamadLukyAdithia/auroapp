// core/utils/receipt_service.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pos_mobile/core/utils/auth_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../data/models/transaction_model.dart';
import '../../data/models/company_model.dart';
import '../../data/models/transaction_sales_report_model.dart'; // ✅ Import Company

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
  static Future<Uint8List> _buildPdfBytes(
      TransactionModel transaction,
      Company company,
      ) async {
    final doc = pw.Document();
    final date = transaction.transactionDate.toLocal();
    final formattedDate =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final formattedTime =
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

    // ✅ Hitung dynamic height berdasarkan konten
    double calculateHeight() {
      double height = 0;

      // Header (nama toko, alamat, telp)
      height += 60;

      // Tanggal, waktu, no transaksi
      height += 30;

      // Items (estimasi 25 per item)
      height += transaction.detailTransaction.length * 25;

      // Divider + Summary section
      height += 20;

      // Sub total, diskon, pajak, biaya lain, total (5-8 baris)
      height += 100;

      // Payment info
      height += 40;

      // Footer (terima kasih, pelanggan, kasir)
      height += 50;

      // Padding/margin
      height += 40;

      return height;
    }

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80.copyWith(
          height: calculateHeight(), // ✅ Dynamic height
        ),
        margin: pw.EdgeInsets.all(8), // Margin kecil untuk thermal
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // ========== HEADER ==========
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      company.name,
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      company.address,
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(fontSize: 9),
                    ),
                    if (company.phone.isNotEmpty) ...[
                      pw.SizedBox(height: 1),
                      pw.Text(
                        company.phone,
                        style: pw.TextStyle(fontSize: 9),
                      ),
                    ],
                  ],
                ),
              ),

              pw.SizedBox(height: 8),
              pw.Divider(height: 1),
              pw.SizedBox(height: 6),

              // ========== TRANSACTION INFO ==========
              pw.Text(
                'No: ${transaction.transactionNumber}',
                style: pw.TextStyle(fontSize: 9),
              ),
              pw.SizedBox(height: 2),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(formattedDate, style: pw.TextStyle(fontSize: 9)),
                  pw.Text(formattedTime, style: pw.TextStyle(fontSize: 9)),
                ],
              ),

              pw.SizedBox(height: 2),

              // Ganti bagian ini (sekitar baris 145-152):

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Kasir:',
                    style: pw.TextStyle(fontSize: 9),
                  ),
                  pw.Text(
                    transaction.user.fullname,
                    style: pw.TextStyle(fontSize: 9),
                  ),
                ],
              ),


              pw.SizedBox(height: 2),

              if (transaction.customer != null) ...[
                pw.SizedBox(height: 2),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Pelanggan:',
                      style: pw.TextStyle(fontSize: 9),
                    ),
                    pw.Text(
                      transaction.customer!.name,
                      style: pw.TextStyle(fontSize: 9),
                    ),
                  ],
                ),
              ],

              pw.SizedBox(height: 6),
              pw.Divider(height: 1),
              pw.SizedBox(height: 6),

              // ========== ITEMS ==========
              ...transaction.detailTransaction.map((item) {
                return pw.Container(
                  margin: pw.EdgeInsets.only(bottom: 6),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Nama produk & subtotal
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Expanded(
                            child: pw.Text(
                              item.product.productName,
                              style: pw.TextStyle(
                                fontSize: 10,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ),
                          pw.SizedBox(width: 8),
                          pw.Text(
                            _formatCurrency(item.subtotal.toInt()),
                            style: pw.TextStyle(
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 2),

                      // Quantity & price detail
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            '${item.quantity} x ${_formatCurrency(item.unitPrice.toInt())}',
                            style: pw.TextStyle(fontSize: 8),
                          ),
                          if (item.discount > 0)
                            pw.Text(
                              'Disc ${item.discount.toStringAsFixed(0)}%',
                              style: pw.TextStyle(fontSize: 8),
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              }),

              pw.Divider(height: 1),
              pw.SizedBox(height: 6),

              // ========== SUMMARY ==========
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Sub Total', style: pw.TextStyle(fontSize: 10)),
                  pw.Text(
                    _formatCurrency(transaction.subtotal.toInt()),
                    style: pw.TextStyle(fontSize: 10),
                  ),
                ],
              ),

              if (transaction.transactionDiscount != null &&
                  transaction.transactionDiscount! > 0) ...[
                pw.SizedBox(height: 3),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Diskon', style: pw.TextStyle(fontSize: 10)),
                    pw.Text(
                      '-${_formatCurrency(transaction.transactionDiscount!.toInt())}',
                      style: pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ],

              if (transaction.transactionTax > 0) ...[
                pw.SizedBox(height: 3),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Pajak', style: pw.TextStyle(fontSize: 10)),
                    pw.Text(
                      _formatCurrency(transaction.transactionTax.toInt()),
                      style: pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ],

              if (transaction.otherCost > 0) ...[
                pw.SizedBox(height: 3),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      transaction.nameOtherCost ?? 'Biaya Lain',
                      style: pw.TextStyle(fontSize: 10),
                    ),
                    pw.Text(
                      _formatCurrency(transaction.otherCost.toInt()),
                      style: pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ],

              pw.SizedBox(height: 6),
              pw.Divider(height: 1),
              pw.SizedBox(height: 6),

              // TOTAL
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'TOTAL',
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    _formatCurrency(transaction.totalTransaction.toInt()),
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 8),
              pw.Divider(height: 1),
              pw.SizedBox(height: 6),

              // ========== PAYMENT ==========
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Bayar (${transaction.companyPaymentMethod.paymentMethod.paymentMethodName})',
                    style: pw.TextStyle(fontSize: 10),
                  ),
                  pw.Text(
                    _formatCurrency(transaction.totalPayment.toInt()),
                    style: pw.TextStyle(fontSize: 10),
                  ),
                ],
              ),

              if (transaction.changeAmount > 0) ...[
                pw.SizedBox(height: 3),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Kembalian', style: pw.TextStyle(fontSize: 10)),
                    pw.Text(
                      _formatCurrency(transaction.changeAmount.toInt()),
                      style: pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ],

              pw.SizedBox(height: 10),
              pw.Divider(height: 1),
              pw.SizedBox(height: 8),

              // ========== FOOTER ==========
              pw.Center(
                child: pw.Text(
                  'Terima kasih!',
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),


              // pw.Center(
              //   child: pw.Text(
              //     'ID: #${transaction.id}',
              //     style: pw.TextStyle(fontSize: 8),
              //   ),
              // ),
            ],
          );
        },
      ),
    );

    return doc.save();
  }

  // ✅ Print ke printer (thermal/bluetooth/network)
  static Future<void> printReceipt(
      TransactionModel transaction,
      Company company,
      ) async {
    try {
      final bytes = await _buildPdfBytes(transaction, company);
      // Printing.layoutPdf akan buka dialog untuk pilih printer
      await Printing.layoutPdf(onLayout: (_) => bytes);
    } catch (e) {
      rethrow;
    }
  }

  // ✅ Share sebagai PDF (WhatsApp, Email, dll)
  static Future<void> shareReceipt(
      TransactionModel transaction,
      Company company,
      ) async {
    try {
      final bytes = await _buildPdfBytes(transaction, company);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/receipt_${transaction.transactionNumber}.pdf');
      await file.writeAsBytes(bytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Struk Transaksi ${transaction.transactionNumber}',
      );
    } catch (e) {
      rethrow;
    }
  }

  // Generate file untuk preview (opsional)
  static Future<File> generateReceiptFile(
      TransactionModel transaction,
      Company company,
      ) async {
    final bytes = await _buildPdfBytes(transaction, company);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/receipt_${transaction.transactionNumber}.pdf');
    await file.writeAsBytes(bytes);
    return file;
  }


  // ===== HISTORY RECEIPT METHODS =====

// Format currency untuk history (sama seperti yang ada)
  static String _formatCurrencyHistory(double amount) {
    final s = amount.abs().toInt().toString();
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

// Build PDF untuk History Transaction
  static Future<Uint8List> _buildHistoryPdfBytes(
      TransactionReportDetail detail,
      Company company,
      ) async {
    final doc = pw.Document();
    final transaction = detail.transaction;
    final products = detail.products;

    // Hitung dynamic height
    double calculateHeight() {
      double height = 0;
      height += 60; // Header
      height += 30; // Info transaksi
      height += products.length * 25; // Items
      height += 20; // Divider
      height += 100; // Summary
      height += 40; // Payment
      height += 50; // Footer
      height += 40; // Padding
      return height;
    }

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80.copyWith(
          height: calculateHeight(),
        ),
        margin: pw.EdgeInsets.all(8),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // ========== HEADER ==========
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      company.name,
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      company.address,
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(fontSize: 9),
                    ),
                    if (company.phone.isNotEmpty) ...[
                      pw.SizedBox(height: 1),
                      pw.Text(
                        company.phone,
                        style: pw.TextStyle(fontSize: 9),
                      ),
                    ],
                  ],
                ),
              ),

              pw.SizedBox(height: 8),
              pw.Divider(height: 1),
              pw.SizedBox(height: 6),

              // ========== TRANSACTION INFO ==========
              pw.Text(
                'No: ${transaction.kodeTransaksi}',
                style: pw.TextStyle(fontSize: 9),
              ),
              pw.SizedBox(height: 2),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(transaction.tanggal, style: pw.TextStyle(fontSize: 9)),
                  pw.Text(transaction.waktu, style: pw.TextStyle(fontSize: 9)),
                ],
              ),

              if (transaction.pelanggan != 'Tanpa pelanggan') ...[
                pw.SizedBox(height: 2),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Pelanggan:',
                      style: pw.TextStyle(fontSize: 9),
                    ),
                    pw.Text(
                      transaction.pelanggan,
                      style: pw.TextStyle(fontSize: 9),
                    ),
                  ],
                ),
              ],

              pw.SizedBox(height: 2),
              // Ganti bagian ini (sekitar baris 145-152):

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Kasir:',
                    style: pw.TextStyle(fontSize: 8),
                  ),
                  pw.Text(
                    transaction.kasir,
                    style: pw.TextStyle(fontSize: 8),
                  ),
                ],
              ),

              pw.SizedBox(height: 6),
              pw.Divider(height: 1),
              pw.SizedBox(height: 6),

              // ========== ITEMS ==========
              ...products.map((item) {
                return pw.Container(
                  margin: pw.EdgeInsets.only(bottom: 6),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Nama produk & subtotal
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Expanded(
                            child: pw.Text(
                              item.namaProduk,
                              style: pw.TextStyle(
                                fontSize: 10,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ),
                          pw.SizedBox(width: 8),
                          pw.Text(
                            _formatCurrencyHistory(item.subtotal),
                            style: pw.TextStyle(
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 2),

                      // Quantity & price detail
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            '${item.jumlah} x ${_formatCurrencyHistory(item.hargaSatuan)}',
                            style: pw.TextStyle(fontSize: 8),
                          ),
                          if (item.diskon > 0)
                            pw.Text(
                              'Disc ${item.diskon.toStringAsFixed(0)}%',
                              style: pw.TextStyle(fontSize: 8),
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              }),

              pw.Divider(height: 1),
              pw.SizedBox(height: 6),

              // ========== SUMMARY ==========
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Sub Total', style: pw.TextStyle(fontSize: 10)),
                  pw.Text(
                    _formatCurrencyHistory(transaction.totalPenjualan),
                    style: pw.TextStyle(fontSize: 10),
                  ),
                ],
              ),

              if (transaction.diskon > 0) ...[
                pw.SizedBox(height: 3),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Diskon', style: pw.TextStyle(fontSize: 10)),
                    pw.Text(
                      '-${_formatCurrencyHistory(transaction.diskon)}',
                      style: pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ],

              if (transaction.biayaLain > 0) ...[
                pw.SizedBox(height: 3),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Biaya Lain', style: pw.TextStyle(fontSize: 10)),
                    pw.Text(
                      _formatCurrencyHistory(transaction.biayaLain),
                      style: pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ],

              pw.SizedBox(height: 6),
              pw.Divider(height: 1),
              pw.SizedBox(height: 6),

              // TOTAL
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'TOTAL',
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    _formatCurrencyHistory(transaction.bayar),
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 8),
              pw.Divider(height: 1),
              pw.SizedBox(height: 6),

              // ========== PAYMENT ==========
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Bayar (${transaction.metodePembayaran})',
                    style: pw.TextStyle(fontSize: 10),
                  ),
                  pw.Text(
                    _formatCurrencyHistory(transaction.bayar),
                    style: pw.TextStyle(fontSize: 10),
                  ),
                ],
              ),

              if (transaction.kembalian > 0) ...[
                pw.SizedBox(height: 3),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Kembalian', style: pw.TextStyle(fontSize: 10)),
                    pw.Text(
                      _formatCurrencyHistory(transaction.kembalian),
                      style: pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ],

              pw.SizedBox(height: 10),
              pw.Divider(height: 1),
              pw.SizedBox(height: 8),

              // ========== FOOTER ==========
              pw.Center(
                child: pw.Text(
                  'Terima kasih!',
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),

              pw.SizedBox(height: 6),

              if (transaction.catatan.isNotEmpty && transaction.catatan != '-') ...[
                pw.SizedBox(height: 4),
                pw.Center(
                  child: pw.Text(
                    'Catatan: ${transaction.catatan}',
                    style: pw.TextStyle(fontSize: 8),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );

    return doc.save();
  }

// Print History Receipt
  static Future<void> printHistoryReceipt(
      TransactionReportDetail detail,
      Company company,
      ) async {
    try {
      final bytes = await _buildHistoryPdfBytes(detail, company);
      await Printing.layoutPdf(onLayout: (_) => bytes);
    } catch (e) {
      rethrow;
    }
  }

// Share History Receipt
  static Future<void> shareHistoryReceipt(
      TransactionReportDetail detail,
      Company company,
      ) async {
    try {
      final bytes = await _buildHistoryPdfBytes(detail, company);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/receipt_${detail.transaction.kodeTransaksi}.pdf');
      await file.writeAsBytes(bytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Struk Transaksi ${detail.transaction.kodeTransaksi}',
      );
    } catch (e) {
      rethrow;
    }
  }

// Generate file untuk preview (optional)
  static Future<File> generateHistoryReceiptFile(
      TransactionReportDetail detail,
      Company company,
      ) async {
    final bytes = await _buildHistoryPdfBytes(detail, company);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/receipt_${detail.transaction.kodeTransaksi}.pdf');
    await file.writeAsBytes(bytes);
    return file;
  }
}



