import 'package:flutter/material.dart';
import '../models/invoice.dart';

class InvoiceDetailPage extends StatelessWidget {
  final Invoice invoice;

  const InvoiceDetailPage({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Invoice Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Customer: ${invoice.customer}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('Date: ${invoice.date}', style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
