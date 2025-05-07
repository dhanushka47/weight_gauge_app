import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/customer_database.dart';
import '../db/material_database.dart';
import '../db/printer_database.dart';
import '../models/customer.dart';
import '../models/material.dart';
import '../models/printer.dart';
import 'quotation_preview_page.dart';

class QuotationPage extends StatefulWidget {
  const QuotationPage({super.key});

  @override
  State<QuotationPage> createState() => _QuotationPageState();
}

class _QuotationPageState extends State<QuotationPage> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _descController = TextEditingController();
  final _weightController = TextEditingController();
  final _pricePerGramController = TextEditingController();
  double _infill = 20;

  DateTime? _deliveryDate;
  Customer? _selectedCustomer;
  Printer? _selectedPrinter;
  MaterialItem? _selectedMaterial;

  List<Customer> _customers = [];
  List<Printer> _printers = [];
  List<MaterialItem> _materials = [];
  final List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    _loadCustomers();
    _loadPrinters();
    _loadMaterials();
  }

  Future<void> _loadCustomers() async {
    final data = await CustomerDatabase.instance.getAllCustomers();
    setState(() => _customers = data);
  }

  Future<void> _loadPrinters() async {
    final data = await PrinterDatabase.instance.getAllPrinters();
    setState(() => _printers = data);
  }

  Future<void> _loadMaterials() async {
    final data = await MaterialDatabase.instance.getAllMaterials();
    setState(() => _materials = data);
  }

  Future<void> _saveCustomer() async {
    if (_nameController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _locationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fill all customer fields')),
      );
      return;
    }

    final customer = Customer(
      name: _nameController.text,
      phone: _phoneController.text,
      location: _locationController.text,
    );

    await CustomerDatabase.instance.insertCustomer(customer);
    _nameController.clear();
    _phoneController.clear();
    _locationController.clear();
    await _loadCustomers();
  }

  void _addItem() {
    final weight = double.tryParse(_weightController.text.trim());
    final price = double.tryParse(_pricePerGramController.text.trim());

    if (_descController.text.isEmpty ||
        _selectedPrinter == null ||
        _selectedMaterial == null ||
        weight == null ||
        price == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fill all item fields correctly')),
      );
      return;
    }

    setState(() {
      _items.add({
        'description': _descController.text.trim(),
        'printer': _selectedPrinter!,
        'material': _selectedMaterial!,
        'infill': _infill.toInt(),
        'weight': weight,
        'price': price,
      });

      _descController.clear();
      _weightController.clear();
      _pricePerGramController.clear();
      _selectedPrinter = null;
      _selectedMaterial = null;
      _infill = 20;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Make Quotation')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('1. Add or Select Customer', style: TextStyle(fontWeight: FontWeight.bold)),
          TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Name')),
          TextField(controller: _phoneController, decoration: const InputDecoration(labelText: 'Phone')),
          TextField(controller: _locationController, decoration: const InputDecoration(labelText: 'Location')),
          ElevatedButton.icon(
            onPressed: _saveCustomer,
            icon: const Icon(Icons.save),
            label: const Text('Save Customer'),
          ),
          const Divider(),

          const Text('Proposed Delivery Date'),
          Row(
            children: [
              Expanded(
                child: Text(
                  _deliveryDate == null
                      ? 'No date selected'
                      : DateFormat('yyyy-MM-dd').format(_deliveryDate!),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => _deliveryDate = picked);
                },
                icon: const Icon(Icons.date_range),
                label: const Text('Pick Date'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              ),
            ],
          ),
          const Divider(),

          const Text('Select Existing Customer'),
          DropdownButton<Customer>(
            isExpanded: true,
            value: _selectedCustomer,
            hint: const Text('Select Customer'),
            items: _customers.map((c) {
              return DropdownMenuItem(value: c, child: Text('${c.name} (${c.location})'));
            }).toList(),
            onChanged: (val) => setState(() => _selectedCustomer = val),
          ),

          const Divider(height: 30),
          const Text('2. Add Printing Items', style: TextStyle(fontWeight: FontWeight.bold)),
          TextField(controller: _descController, decoration: const InputDecoration(labelText: 'Item Name')),
          DropdownButton<Printer>(
            isExpanded: true,
            value: _selectedPrinter,
            hint: const Text('Select Printer'),
            items: _printers.map((printer) {
              return DropdownMenuItem(
                value: printer,
                child: Row(children: [
                  Image.file(File(printer.imagePath), width: 30, height: 30),
                  const SizedBox(width: 8),
                  Text(printer.name),
                ]),
              );
            }).toList(),
            onChanged: (val) => setState(() => _selectedPrinter = val),
          ),
          DropdownButton<MaterialItem>(
            isExpanded: true,
            value: _selectedMaterial,
            hint: const Text('Select Material Reel'),
            items: _materials.map((mat) {
              return DropdownMenuItem(
                value: mat,
                child: Text('${mat.materialId} • ${mat.weight}g'),
              );
            }).toList(),
            onChanged: (val) => setState(() => _selectedMaterial = val),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Infill:'),
              Text('${_infill.toInt()}%'),
            ],
          ),
          Slider(
            value: _infill,
            min: 0,
            max: 100,
            divisions: 20,
            label: '${_infill.toInt()}%',
            onChanged: (val) => setState(() => _infill = val),
          ),
          TextField(
            controller: _weightController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Material Weight (g)'),
          ),
          TextField(
            controller: _pricePerGramController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Per Gram Price (Rs)'),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: _addItem,
            icon: const Icon(Icons.add),
            label: const Text('Add Item'),
          ),

          const Divider(height: 30),
          const Text('Quotation Items'),
          const SizedBox(height: 8),
          ..._items.asMap().entries.map((e) {
            final i = e.value;
            final total = (i['weight'] * i['price']);

            return Card(
              color: Colors.orange.shade50,
              child: ListTile(
                title: Text(i['description'] ?? ''),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${i['material'].materialId} • ${i['infill']}% • ${i['weight']}g • Rs: ${i['price'].toStringAsFixed(2)}'),
                    Text('Total: Rs: ${total.toStringAsFixed(2)}'),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => setState(() => _items.removeAt(e.key)),
                ),
              ),
            );
          }),

          const SizedBox(height: 30),
          Center(
            child: ElevatedButton.icon(
              onPressed: () {
                if (_selectedCustomer == null || _items.isEmpty || _deliveryDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Select customer, add items and pick delivery date')),
                  );
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => QuotationPreviewPage(
                      customerName: _selectedCustomer!.name,
                      customerPhone: _selectedCustomer!.phone,
                      customerLocation: _selectedCustomer!.location,
                      deliveryDate: DateFormat('yyyy-MM-dd').format(_deliveryDate!),
                      items: _items,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Generate Quotation'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}