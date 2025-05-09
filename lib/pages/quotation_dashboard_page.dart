import 'dart:convert';
import 'package:flutter/material.dart';
import '../db/quotation_database.dart';
import '../models/quotation.dart';
import 'package:weight_gauge/pages/invoice_preview_page.dart';

class QuotationDashboardPage extends StatefulWidget {
  const QuotationDashboardPage({super.key});

  @override
  State<QuotationDashboardPage> createState() => _QuotationDashboardPageState();
}

class _QuotationDashboardPageState extends State<QuotationDashboardPage> {
  List<Quotation> _quotations = [];

  @override
  void initState() {
    super.initState();
    _loadQuotations();
  }

  Future<void> _loadQuotations() async {
    final data = await QuotationDatabase.instance.getAllQuotations();
    setState(() => _quotations = data);
  }

  void _deleteQuotation(int id) async {
    await QuotationDatabase.instance.deleteQuotation(id);
    _loadQuotations();
  }

  void _markAsPrinted(int index) {
    setState(() {
      _quotations[index].status = 'running';
    });
  }

  void _finishPrinting(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InvoicePreviewPage(quotation: _quotations[index]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Quotations')),
      body: _quotations.isEmpty
          ? const Center(child: Text('No quotations saved'))
          : ListView.builder(
        itemCount: _quotations.length,
        itemBuilder: (context, index) {
          final q = _quotations[index];
          final items = (jsonDecode(q.itemsJson) as List).cast<Map<String, dynamic>>();
          final totalWeight = items.fold<double>(0, (sum, i) => sum + (i['weight'] as num));
          return Card(
            margin: const EdgeInsets.all(10),
            child: ListTile(
              title: Text(q.customer),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Phone: ${q.phone}'),
                  Text('Delivery: ${q.deliveryDate}'),
                  Text('Items: ${items.length}'),
                  Text('Weight: ${totalWeight.toStringAsFixed(2)}g'),
                ],
              ),
              trailing: Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteQuotation(q.id!),
                  ),
                  q.status == 'running'
                      ? ElevatedButton(
                    onPressed: () => _finishPrinting(index),
                    child: const Text('Finish'),
                  )
                      : ElevatedButton(
                    onPressed: () => _markAsPrinted(index),
                    child: const Text('Start Printing'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
