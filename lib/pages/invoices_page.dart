import 'package:flutter/material.dart';
import '../db/invoice_database.dart'; // Make sure this exists or use the appropriate DB
import '../models/invoice.dart';     // Adjust based on your model (could reuse `Quotation`)
import 'invoice_detail_page.dart';   // Optional: for viewing individual invoice

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
    final data = await InvoiceDatabase.instance.getAllInvoices(); // Adjust this to your DB logic
    setState(() => _invoices = data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Completed Invoices')),
      body: SafeArea(
        child: _invoices.isEmpty
            ? const Center(child: Text('No completed invoices found'))
            : ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: _invoices.length,
          itemBuilder: (context, index) {
            final inv = _invoices[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                title: Text(inv.customer),
                subtitle: Text('Date: ${inv.date}'),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => InvoiceDetailPage(invoice: inv),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
