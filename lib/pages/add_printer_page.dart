import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../db/printer_database.dart';
import '../models/printer.dart';


class AddPrinterPage extends StatefulWidget {
  const AddPrinterPage({super.key});

  @override
  State<AddPrinterPage> createState() => _AddPrinterPageState();
}

class _AddPrinterPageState extends State<AddPrinterPage> {
  final _nameController = TextEditingController();
  final _powerController = TextEditingController();
  File? _imageFile;

  List<Printer> _printers = [];

  @override
  void initState() {
    super.initState();
    _loadPrinters();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  Future<void> _savePrinter() async {
    if (_imageFile == null || _nameController.text.isEmpty || _powerController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All fields are required.')),
      );
      return;
    }

    final printer = Printer(
      name: _nameController.text,
      power: double.tryParse(_powerController.text) ?? 0.0,
      imagePath: _imageFile!.path,
    );

    await PrinterDatabase.instance.insertPrinter(printer);
    _nameController.clear();
    _powerController.clear();
    setState(() => _imageFile = null);
    await _loadPrinters();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Printer saved successfully!')),
    );
  }

  Future<void> _loadPrinters() async {
    final db = await PrinterDatabase.instance.database;
    final maps = await db.query('printers');
    setState(() {
      _printers = maps.map((e) => Printer.fromMap(e)).toList();
    });
  }

  Future<void> _deletePrinter(int id) async {
    final db = await PrinterDatabase.instance.database;
    await db.delete('printers', where: 'id = ?', whereArgs: [id]);
    await _loadPrinters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Printer')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: _imageFile == null
                  ? Container(
                height: 150,
                width: 150,
                color: Colors.grey[300],
                child: const Icon(Icons.add_a_photo, size: 50),
              )
                  : Image.file(_imageFile!, height: 150),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Printer Name'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _powerController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Power (W)'),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _savePrinter,
              icon: const Icon(Icons.save),
              label: const Text('Save Printer'),
            ),
            const SizedBox(height: 30),
            const Divider(thickness: 1),
            const Text('Saved Printers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ..._printers.map((printer) {
              return Card(
                child: ListTile(
                  leading: Image.file(File(printer.imagePath), width: 50, height: 50, fit: BoxFit.cover),
                  title: Text(printer.name),
                  subtitle: Text('Power: ${printer.power.toStringAsFixed(1)} W'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deletePrinter(printer.id!),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
