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
    setState(() => _invoices = data.where((i) => i.paidDate == null).toList());
  }

  Future<void> _markAsPaid(Invoice invoice) async {
    final updated = invoice.copyWith(paidDate: DateTime.now().toIso8601String());

    await InvoiceDatabase.instance.updateInvoice(updated);

    final filePath = '/storage/emulated/0/Weight Gauge/quotations/quotation_${invoice.id}.pdf';
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
      debugPrint('🗑 Deleted PDF: $filePath');
    }

    await _loadInvoices();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Marked as paid')));
    }
  }

  Future<void> _deleteInvoice(Invoice invoice) async {
    await InvoiceDatabase.instance.deleteInvoice(invoice.id);

    final filePath = '/storage/emulated/0/Weight Gauge/quotations/quotation_${invoice.id}.pdf';
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
      debugPrint('🗑 Deleted PDF: $filePath');
    }

    await _loadInvoices();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invoice deleted')));
    }
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
              title: Text(invoice.customer, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Phone: ${invoice.phone}'),
                  Text('Date: ${invoice.date}'),
                  Text('Items: $itemCount'),
                  Text('Total Payment: Rs. ${invoice.total.toStringAsFixed(2)}'),
                ],
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'share') {
                    _sharePdf(invoice);
                  } else if (value == 'delete') {
                    _deleteInvoice(invoice);
                  } else if (value == 'paid') {
                    _markAsPaid(invoice);
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'share', child: Text('📤 Share')),
                  const PopupMenuItem(value: 'paid', child: Text('✅ Mark as Paid')),
                  const PopupMenuItem(value: 'delete', child: Text('🗑 Delete')),
                ],
              ),
              onTap: () {
                // Optionally show details here
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _sharePdf(Invoice invoice) async {
    final filePath = '/storage/emulated/0/Weight Gauge/quotations/quotation_${invoice.id}.pdf';
    final file = File(filePath);

    debugPrint('📄 Checking for PDF at: $filePath');

    if (await file.exists()) {
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      await Printing.sharePdf(bytes: bytes, filename: 'quotation_${invoice.id}.pdf');
    } else {
      if (!mounted) return;
      debugPrint('❌ PDF NOT FOUND at: $filePath');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF not found at:\n$filePath')),
      );
    }
  }
}
