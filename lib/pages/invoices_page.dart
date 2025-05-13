import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../db/invoice_database.dart';
import '../models/invoice.dart';

class InvoicesPage extends StatefulWidget {
  const InvoicesPage({super.key});

  @override
  State<InvoicesPage> createState() => _InvoicesPageState();
}

class _InvoicesPageState extends State<InvoicesPage> {
  List<Invoice> _invoices = [];

  @override
  void initState() {
    super.initState();
    _loadInvoices();
  }

  Future<void> _loadInvoices() async {
    final data = await InvoiceDatabase.instance.getAllInvoices();
    if (!mounted) return;
    setState(() => _invoices = data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Completed Invoices')),
      body: _invoices.isEmpty
          ? const Center(child: Text('No completed invoices found'))
          : ListView.builder(
        itemCount: _invoices.length,
        padding: const EdgeInsets.all(12),
        itemBuilder: (context, index) {
          final invoice = _invoices[index];

          int itemCount = 0;
          try {
            final parsedItems = jsonDecode(invoice.itemsJson) as List;
            itemCount = parsedItems.length;
          } catch (_) {}

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            color: Colors.orange.shade50,
            child: ListTile(
              title: Text(
                invoice.customer,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Phone: ${invoice.phone}'),
                  Text('Date: ${invoice.date}'),
                  Text('Items: $itemCount'),
                  Text('Total Payment: Rs. ${invoice.total.toStringAsFixed(2)}'),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.share),
                onPressed: () async {
                  final filePath =
                      '/storage/emulated/0/Weight Gauge/quotations/quotation_${invoice.id}.pdf';
                  final file = File(filePath);

                  debugPrint('📄 Checking for PDF at: $filePath');

                  if (await file.exists()) {
                    final bytes = await file.readAsBytes();
                    if (!mounted) return;
                    await Printing.sharePdf(
                      bytes: bytes,
                      filename: 'quotation_${invoice.id}.pdf',
                    );
                  } else {
                    if (!mounted) return;
                    debugPrint('❌ PDF NOT FOUND at: $filePath');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('PDF not found at:\n$filePath')),
                    );
                  }
                },
              ),
              onTap: () {
                // TODO: Navigate to details page if needed
              },
            ),
          );
        },
      ),
    );
  }
}
