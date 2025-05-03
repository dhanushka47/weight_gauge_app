import 'dart:io';
import 'package:flutter/material.dart';
import '../db/expense_database.dart';
import '../db/printer_database.dart';
import '../models/expense.dart';
import '../models/printer.dart';

class ExpensesPage extends StatefulWidget {
  const ExpensesPage({super.key});

  @override
  State<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> {
  final _rentalController = TextEditingController();
  final _unitPriceController = TextEditingController();
  final Map<int, TextEditingController> _maintenanceControllers = {};
  List<Printer> _printers = [];
  List<Expense> _savedExpenses = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final printerList = await PrinterDatabase.instance.getAllPrinters();
    final expenseList = await ExpenseDatabase.instance.getAllExpenses();

    setState(() {
      _printers = printerList;
      _savedExpenses = expenseList;

      for (var printer in _printers) {
        _maintenanceControllers[printer.id!] = TextEditingController();
      }

      if (_savedExpenses.isNotEmpty) {
        _rentalController.text = _savedExpenses.first.rentalCost.toString();
        _unitPriceController.text = _savedExpenses.first.unitPrice.toString();

        for (var exp in _savedExpenses) {
          _maintenanceControllers[exp.printerId]?.text = exp.maintenanceCost.toString();
        }
      }
    });
  }

  Future<void> _saveExpenses() async {
    final rental = double.tryParse(_rentalController.text.trim()) ?? 0.0;
    final unitPrice = double.tryParse(_unitPriceController.text.trim()) ?? 0.0;

    await ExpenseDatabase.instance.clearAll();

    for (var printer in _printers) {
      final cost = double.tryParse(_maintenanceControllers[printer.id!]!.text.trim()) ?? 0.0;
      final expense = Expense(
        printerId: printer.id!,
        printerName: printer.name,
        imagePath: printer.imagePath,
        maintenanceCost: cost,
        rentalCost: rental,
        unitPrice: unitPrice,
      );
      await ExpenseDatabase.instance.insertExpense(expense);
    }

    await _loadData();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Expenses saved!')),
    );
  }

  @override
  void dispose() {
    _rentalController.dispose();
    _unitPriceController.dispose();
    for (var controller in _maintenanceControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Expenses')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('General Costs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: _rentalController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Building Rental Cost'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _unitPriceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Current Unit Price'),
            ),
            const SizedBox(height: 20),
            const Divider(thickness: 1),
            const Text('Per-Printer Maintenance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ..._printers.map((printer) => Card(
              color: Colors.orange.shade50,
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(File(printer.imagePath), width: 50, height: 50, fit: BoxFit.cover),
                ),
                title: Text(printer.name),
                subtitle: TextField(
                  controller: _maintenanceControllers[printer.id!]!,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Monthly Maintenance Cost'),
                ),
              ),
            )),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _saveExpenses,
              icon: const Icon(Icons.save),
              label: const Text('Save'),
            ),
            const SizedBox(height: 20),
            const Divider(thickness: 1),
            const Text('Saved Costs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ..._savedExpenses.map((exp) => Card(
              color: Colors.orange.shade50,
              child: ListTile(
                leading: Image.file(File(exp.imagePath), width: 50, height: 50, fit: BoxFit.cover),
                title: Text(exp.printerName),
                subtitle: Text('Maintenance: \$${exp.maintenanceCost.toStringAsFixed(2)}'),
              ),
            )),
          ],
        ),
      ),
    );
  }
}
