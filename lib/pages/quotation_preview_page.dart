import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/account.dart';
import '../models/printer.dart' as app;
import '../models/material.dart';
import '../db/quotation_database.dart';
import '../models/quotation.dart';

class QuotationPreviewPage extends StatefulWidget {
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

  @override
  State<QuotationPreviewPage> createState() => _QuotationPreviewPageState();
}

class _QuotationPreviewPageState extends State<QuotationPreviewPage> {
  int? _quotationId;

  Future<Uint8List> _generatePdf(int idForDisplay) async {
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

    final groupedByPrinter = <String, List<Map<String, dynamic>>>{};
    for (var item in widget.items) {
      final printer = (item['printer'] as app.Printer).name;
      groupedByPrinter.putIfAbsent(printer, () => []).add(item);
    }

    final total = widget.items.fold<double>(0, (sum, i) => sum + (i['weight'] * i['price']));

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
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
                    pw.Text('ID: $idForDisplay', style: pw.TextStyle(fontSize: 10)),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 10),
            pw.Text('Customer: ${widget.customerName}'),
            pw.Text('Phone: ${widget.customerPhone}'),
            pw.Text('Location: ${widget.customerLocation}'),
            pw.Text('Proposed Delivery Date: ${widget.deliveryDate}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
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
                    return [
                      '${index + 1}',
                      item['description'],
                      '${mat.type} - ${mat.color}',
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
                'Grand Total: Rs. ${total.toStringAsFixed(2)}',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
            if (accounts.isNotEmpty) ...[
              pw.SizedBox(height: 20),
              pw.Text('Bank transfer details:', style: pw.TextStyle(fontSize: 10)),
              pw.SizedBox(height: 6),
              pw.Table.fromTextArray(
                headers: ['Name', 'Bank', 'Branch', 'Account No'],
                data: accounts.map((a) => [
                  a.accountName,
                  a.bankName,
                  a.branch,
                  a.accountNumber,
                ]).toList(),
              ),
            ],

            pw.Spacer(),
            pw.Divider(),
            pw.Center(
              child: pw.Text(
                '©2025 brainwavetech.lk',
                style: pw.TextStyle(fontSize: 8, color: PdfColors.grey),
              ),
            ),
          ],
        ),
      ),
    );

    return pdf.save();
  }

  Future<void> _saveQuotation(BuildContext context) async {
    if (_quotationId != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Quotation already saved.")),
      );
      return;
    }

    final total = widget.items.fold<double>(0, (sum, i) => sum + (i['weight'] * i['price']));

    final encodedItems = widget.items.map((item) {
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
      customer: widget.customerName,
      phone: widget.customerPhone,
      location: widget.customerLocation,
      deliveryDate: widget.deliveryDate,
      total: total,
      createdAt: DateTime.now().toIso8601String(),
      itemsJson: jsonEncode(encodedItems),
      status: 'pending',
    );

    final int savedId = await QuotationDatabase.instance.insertQuotation(quotation);
    setState(() {
      _quotationId = savedId;
    });

    final pdfBytes = await _generatePdf(savedId);

    final permission = await Permission.manageExternalStorage.request();
    if (permission.isGranted) {
      final dir = Directory('/storage/emulated/0/Weight Gauge/quotations');
      if (!await dir.exists()) await dir.create(recursive: true);

      final filePath = '${dir.path}/quotation_$savedId.pdf';
      final file = File(filePath);
      await file.writeAsBytes(pdfBytes);
    }

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Quotation saved with ID $savedId and PDF generated')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final previewId = _quotationId ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quotation Preview'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () async {
              final pdfData = await _generatePdf(previewId);
              await Printing.sharePdf(bytes: pdfData, filename: 'quotation_$previewId.pdf');
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
      body: Center(
        child: PdfPreview(
          build: (format) => _generatePdf(previewId),
          canChangePageFormat: false,
          canChangeOrientation: false,
          allowSharing: false,
          allowPrinting: false,
          actions: const [],
          pdfFileName: 'quotation_$previewId.pdf',
        ),
      ),
    );
  }
}
