// quotation_page.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'pdf_generator.dart';

class QuotationPage extends StatefulWidget {
  @override
  _QuotationPageState createState() => _QuotationPageState();
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

    if (customerController.text.isEmpty ||
        itemController.text.isEmpty ||
        quantity <= 0 ||
        rate <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all fields correctly")),
      );
      return;
    }

    await generateQuotationPDF(
      customerName: customerController.text,
      itemDescription: itemController.text,
      quantity: quantity,
      rate: rate,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create Quotation"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: customerController,
              decoration: InputDecoration(labelText: "Customer Name"),
            ),
            TextField(
              controller: itemController,
              decoration: InputDecoration(labelText: "Item Description"),
            ),
            TextField(
              controller: quantityController,
              decoration: InputDecoration(labelText: "Quantity"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: rateController,
              decoration: InputDecoration(labelText: "Rate per Unit (Rs)"),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: _generatePDF,
              child: Text("Generate Quotation PDF"),
            ),
          ],
        ),
      ),
    );
  }
}
