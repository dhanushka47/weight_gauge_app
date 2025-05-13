import 'dart:convert';
import 'package:flutter/material.dart';
import '../db/quotation_database.dart';
import '../db/material_database.dart';
import '../db/invoice_database.dart'; // ✅ import invoice DB
import '../models/quotation.dart';
import '../models/invoice.dart'; // ✅ import invoice model
import 'invoices_page.dart'; // ✅ page to show finished invoices

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

  Future<void> _deleteQuotation(int id) async {
    await QuotationDatabase.instance.deleteQuotation(id);
    await _loadQuotations();
  }

  Future<void> _markAsRunning(int index) async {
    final q = _quotations[index];
    final updated = q.copyWith(status: 'running');
    await QuotationDatabase.instance.updateQuotation(updated);
    await _loadQuotations();
  }

  Future<void> _finishPrinting(int index) async {
    final q = _quotations[index];
    final items = (jsonDecode(q.itemsJson) as List).cast<Map<String, dynamic>>();

    for (var item in items) {
      final matMap = item['material'] as Map<String, dynamic>;
      final matId = matMap['id'] as int?;
      final usedWeight = (item['weight'] as num).toDouble();

      if (matId != null) {
        final material = await MaterialDatabase.instance.getMaterialById(matId);
        if (material != null) {
          final newWeight = material.weight - usedWeight;
          final updatedMat = material.copyWith(weight: newWeight < 0 ? 0 : newWeight);
          await MaterialDatabase.instance.updateMaterial(updatedMat);
        }
      }
    }

    final total = items.fold<double>(0, (sum, i) => sum + (i['weight'] * i['price']));

    await InvoiceDatabase.instance.insertInvoice(
      Invoice(
        id: q.id!,
        customer: q.customer,
        phone: q.phone,
        date: q.deliveryDate,
        total: total,
        itemsJson: q.itemsJson,
        paidAmount: null,
        paidDate: null,
        reelUsed: null,
        usedMaterialAmount: null,
      ),
    );


    await QuotationDatabase.instance.deleteQuotation(q.id!);

    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const InvoicesPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Quotations')),
      body: SafeArea(
        child: _quotations.isEmpty
            ? const Center(child: Text('No quotations saved'))
            : ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: _quotations.length,
          itemBuilder: (context, index) {
            final q = _quotations[index];
            final items = (jsonDecode(q.itemsJson) as List).cast<Map<String, dynamic>>();
            final totalWeight = items.fold<double>(0, (sum, i) => sum + (i['weight'] as num));

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info section
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            q.customer,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text('Phone: ${q.phone}'),
                          Text('Delivery: ${q.deliveryDate}'),
                          Text('Items: ${items.length}'),
                          Text('Weight: ${totalWeight.toStringAsFixed(2)}g'),
                        ],
                      ),
                    ),

                    // Action section
                    Column(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteQuotation(q.id!),
                        ),
                        const SizedBox(height: 4),
                        q.status == 'running'
                            ? TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            minimumSize: const Size(0, 28),
                          ),
                          onPressed: () => _finishPrinting(index),
                          child: const Text(
                            'Finish',
                            style: TextStyle(fontSize: 10, color: Colors.white),
                          ),
                        )
                            : TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            minimumSize: const Size(0, 28),
                          ),
                          onPressed: () => _markAsRunning(index),
                          child: const Text(
                            'Start',
                            style: TextStyle(fontSize: 10, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
