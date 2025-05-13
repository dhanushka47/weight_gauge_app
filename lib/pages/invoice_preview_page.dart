import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quotation.dart';
import '../models/account.dart';
import 'package:permission_handler/permission_handler.dart';

class InvoicePreviewPage extends StatelessWidget {
  final Quotation quotation;

  const InvoicePreviewPage({super.key, required this.quotation});

  Future<Uint8List> _generateInvoicePdf() async {
    final pdf = pw.Document();
    final prefs = await SharedPreferences.getInstance();

    final bizName = prefs.getString('bizName') ?? '';
    final bizAddress = prefs.getString('bizAddress') ?? '';
    final bizContact = prefs.getString('bizContact') ?? '';
    final logoPath = prefs.getString('logoPath');
    final logo = (logoPath != null && File(logoPath).existsSync())
        ? File(logoPath).readAsBytesSync()
        : null;

    final List<BankAccount> accounts = (prefs.getStringList('bizAccounts') ?? [])
        .map((e) => BankAccount.fromJsonString(e))
        .toList();

    final List<dynamic> items = jsonDecode(quotation.itemsJson);

    final Map<String, List<Map<String, dynamic>>> groupedByPrinter = {};
    for (var item in items) {
      final printer = (item['printer']['name']);
      groupedByPrinter.putIfAbsent(printer, () => []).add(item);
    }

    final double total = items.fold(0.0, (sum, item) {
      return sum + ((item['weight'] as num) * (item['price'] as num));
    });

    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Center(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    if (logo != null) pw.Image(pw.MemoryImage(logo), width: 80),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(bizName, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text(bizAddress, style: pw.TextStyle(fontSize: 10)),
                        pw.Text('Contact: $bizContact', style: pw.TextStyle(fontSize: 10)),
                        pw.Text('INVOICE', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text('ID: ${quotation.id ?? "N/A"}'),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 12),
                pw.Text('Customer: ${quotation.customer}'),
                pw.Text('Phone: ${quotation.phone}'),
                pw.Text('Delivery Date: ${quotation.deliveryDate}',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),

                ...groupedByPrinter.entries.map((entry) {
                  final printer = entry.key;
                  final data = entry.value;

                  return pw.Column(children: [
                    pw.SizedBox(height: 8),
                    pw.Text('Printer: $printer', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Table.fromTextArray(
                      headers: ['No', 'Item', 'Material', 'Infill %', 'Weight(g)', 'Price/g', 'Total'],
                      data: List.generate(data.length, (index) {
                        final item = data[index];
                        final material = item['material'];
                        final itemTotal = (item['weight'] as num) * (item['price'] as num);
                        return [
                          '${index + 1}',
                          item['description'],
                          '${material['type']} • ${material['color']}',
                          '${item['infill']}%',
                          '${item['weight']}g',
                          'Rs. ${item['price'].toStringAsFixed(2)}',
                          'Rs. ${itemTotal.toStringAsFixed(2)}',
                        ];
                      }),
                    ),
                  ]);
                }),

                pw.SizedBox(height: 10),
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text(
                    'Grand Total: Rs. ${total.toStringAsFixed(2)}',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ),

                if (accounts.isNotEmpty) ...[
                  pw.SizedBox(height: 20),
                  pw.Text(
                      'You can make bank transfer to the following accounts and send the proof of slip:',
                      style: pw.TextStyle(fontSize: 10)),
                  pw.SizedBox(height: 6),
                  pw.Table.fromTextArray(
                    headers: ['Bank', 'Branch', 'Account No'],
                    data: accounts.map((a) => [a.bankName, a.branch, a.accountNumber]).toList(),
                  ),
                ],

                pw.Spacer(),
                pw.Divider(),
                pw.Center(
                  child: pw.Text(
                    'All rights reserved ©2025 brainwavetech.lk',
                    style: pw.TextStyle(fontSize: 8, color: PdfColors.grey),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  Future<void> _saveAndSharePdf(BuildContext context) async {
    final pdfBytes = await _generateInvoicePdf();

    final permission = await Permission.manageExternalStorage.request();
    debugPrint('🔐 Storage permission granted: ${permission.isGranted}');
    if (!permission.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Storage permission denied.')),
      );
      return;
    }

    try {
      final externalDir = Directory('/storage/emulated/0/Download/Weight Gauge/pdfs');
      if (!await externalDir.exists()) {
        await externalDir.create(recursive: true);
        debugPrint('📁 Created folder: ${externalDir.path}');
      } else {
        debugPrint('📁 Folder exists: ${externalDir.path}');
      }

      final filePath = '${externalDir.path}/invoice_${quotation.id}.pdf';
      final file = File(filePath);
      await file.writeAsBytes(pdfBytes);
      debugPrint('💾 Attempting to save PDF to: $filePath');

      final exists = await file.exists();
      if (exists) {
        debugPrint('✅ PDF successfully saved to: $filePath');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ PDF saved to: $filePath')),
        );
      } else {
        debugPrint('❌ File does not exist after writing!');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Failed to save PDF.')),
        );
        return;
      }

      // Now share it
      await Printing.sharePdf(
        bytes: pdfBytes,
        filename: 'invoice_${quotation.id}.pdf',
      );
    } catch (e) {
      debugPrint('❌ Error saving PDF: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save PDF: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice Preview'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _saveAndSharePdf(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Invoice deleted")),
              );
            },
          ),
        ],
      ),
      body: PdfPreview(
        build: (format) => _generateInvoicePdf(),
        canChangePageFormat: false,
        canChangeOrientation: false,
        allowSharing: false,   // <- prevent conflict
        allowPrinting: false,
        pdfFileName: 'invoice.pdf',
      )
    );
  }
}
