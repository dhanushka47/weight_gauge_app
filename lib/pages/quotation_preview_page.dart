import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../models/account.dart';
import '../models/printer.dart' as app;
import '../models/material.dart'; // <- This contains MaterialModel
import '../db/quotation_database.dart';
import '../models/quotation.dart';

class QuotationPreviewPage extends StatelessWidget {
  final String customerName;
  final String customerPhone;
  final String customerLocation;
  final String deliveryDate;
  final List<Map<String, dynamic>> items;

  const QuotationPreviewPage({
    super.key,
    required this.customerName,
    required this.customerPhone,
    required this.customerLocation,
    required this.deliveryDate,
    required this.items,
  });

  Future<Uint8List> _generatePdf() async {
    final pdf = pw.Document();
    final prefs = await SharedPreferences.getInstance();

    final bizName = prefs.getString('bizName') ?? '';
    final bizAddress = prefs.getString('bizAddress') ?? '';
    final bizContact = prefs.getString('bizContact') ?? '';
    final logoPath = prefs.getString('logoPath');
    final logo = (logoPath != null && File(logoPath).existsSync()) ? File(logoPath).readAsBytesSync() : null;

    final List<BankAccount> accounts = (prefs.getStringList('bizAccounts') ?? [])
        .map((e) => BankAccount.fromJsonString(e))
        .toList();

    final Map<String, List<Map<String, dynamic>>> groupedByPrinter = {};
    for (var item in items) {
      final printer = (item['printer'] as app.Printer).name;
      groupedByPrinter.putIfAbsent(printer, () => []).add(item);
    }

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Center(
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
                      pw.Text('Quotation', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('ID: QT${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}'),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 12),
              pw.Text('Customer: $customerName'),
              pw.Text('Phone: $customerPhone'),
              pw.Text('Location: $customerLocation'),
              pw.Text('Proposed Delivery Date: $deliveryDate', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),

              ...groupedByPrinter.entries.map((entry) {
                final printerName = entry.key;
                final printerItems = entry.value;

                return pw.Column(children: [
                  pw.SizedBox(height: 10),
                  pw.Text('Printer: $printerName', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Table.fromTextArray(
                    headers: ['No', 'Item', 'Material', 'Infill %', 'Weight(g)', 'Price/g', 'Total'],
                    data: List.generate(printerItems.length, (index) {
                      final item = printerItems[index];
                      final total = item['weight'] * item['price'];
                      final mat = item['material'] as MaterialModel;
                      final materialText = '${mat.type} - ${mat.color}';
                      return [
                        '${index + 1}',
                        item['description'],
                        materialText,
                        '${item['infill']}%',
                        '${item['weight']}g',
                        'Rs. ${item['price'].toStringAsFixed(2)}',
                        'Rs. ${total.toStringAsFixed(2)}',
                      ];
                    }),
                  ),
                ]);
              }),

              pw.SizedBox(height: 10),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  'Grand Total: Rs. ${items.fold<double>(0, (sum, i) => sum + (i['weight'] * i['price'])).toStringAsFixed(2)}',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
              ),

              if (accounts.isNotEmpty) ...[
                pw.SizedBox(height: 20),
                pw.Text('You can make bank transfer to the following accounts and send the proof of slip:',
                    style: pw.TextStyle(fontSize: 10)),
                pw.SizedBox(height: 8),
                pw.Table.fromTextArray(
                  headers: ['Bank', 'Branch', 'Account No'],
                  data: accounts.map((acc) => [acc.bankName, acc.branch, acc.accountNumber]).toList(),
                ),
              ],

              pw.Spacer(),
              pw.Divider(),
              pw.Center(
                child: pw.Text(
                  'Generated by ALL rights reserved © 2025 brainwavetech.lk',
                  style: pw.TextStyle(fontSize: 8, color: const PdfColor(0.5, 0.5, 0.5)),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return pdf.save();
  }

  Future<void> _saveQuotation(BuildContext context) async {
    final double total = items.fold<double>(0, (sum, i) => sum + (i['weight'] * i['price']));

    final encodedItems = items.map((item) {
      final newItem = Map<String, dynamic>.from(item);
      newItem['printer'] = (item['printer'] as app.Printer).name;
      final mat = newItem['material'] as MaterialModel;
      newItem['material'] = {
        'materialId': mat.materialId,
        'type': mat.type,
        'color': mat.color,
        'availableGrams': mat.availableGrams,
      };
      return newItem;
    }).toList();

    final quotation = Quotation(
      customer: customerName,
      phone: customerPhone,
      location: customerLocation,
      deliveryDate: deliveryDate,
      total: total,
      createdAt: DateTime.now().toIso8601String(),
      itemsJson: jsonEncode(encodedItems),
      status: 'pending',
    );

    await QuotationDatabase.instance.insertQuotation(quotation);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quotation saved to database')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quotation Preview'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () async {
              final pdfData = await _generatePdf();
              await Printing.sharePdf(bytes: pdfData, filename: 'quotation.pdf');
            },
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () => _saveQuotation(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Quotation discarded")),
              );
            },
          ),
        ],
      ),
      body: PdfPreview(
        build: (format) => _generatePdf(),
        canChangePageFormat: false,
        canChangeOrientation: false,
        allowSharing: true,
        allowPrinting: false,
        pdfFileName: 'quotation.pdf',
      ),
    );
  }
}
