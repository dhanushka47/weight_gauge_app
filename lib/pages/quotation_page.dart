import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weight_gauge/utils/pdf_generator.dart';

class QuotationPage extends StatefulWidget {
  const QuotationPage({super.key});

  @override
  State<QuotationPage> createState() => _QuotationPageState();
}

class _QuotationPageState extends State<QuotationPage> {
  final customerController = TextEditingController();
  final itemController = TextEditingController();
  final quantityController = TextEditingController();
  final rateController = TextEditingController();

  @override
  void dispose() {
    customerController.dispose();
    itemController.dispose();
    quantityController.dispose();
    rateController.dispose();
    super.dispose();
  }

  Future<void> _generatePDF() async {
    final quantity = int.tryParse(quantityController.text) ?? 0;
    final rate = double.tryParse(rateController.text) ?? 0.0;
    final total = quantity * rate;

    if (customerController.text.isEmpty ||
        itemController.text.isEmpty ||
        quantity <= 0 ||
        rate <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields correctly")),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final logoPath = prefs.getString('logoPath'); // You must store it earlier

    if (logoPath == null || !File(logoPath).existsSync()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please set a logo in app settings.")),
      );
      return;
    }

    final pdfData = await generateQuotationPdf(
      logoFile: File(logoPath),
      customerName: customerController.text.trim(),
      date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
      description: '${itemController.text.trim()}\nQty: $quantity\nRate: Rs. ${rate.toStringAsFixed(2)}',
      total: total,
    );

    await Printing.layoutPdf(onLayout: (_) async => pdfData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Quotation")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: customerController,
              decoration: const InputDecoration(labelText: "Customer Name"),
            ),
            TextField(
              controller: itemController,
              decoration: const InputDecoration(labelText: "Item Description"),
            ),
            TextField(
              controller: quantityController,
              decoration: const InputDecoration(labelText: "Quantity"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: rateController,
              decoration: const InputDecoration(labelText: "Rate per Unit (Rs)"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text("Generate Quotation PDF"),
              onPressed: _generatePDF,
            ),
          ],
        ),
      ),
    );
  }
}
