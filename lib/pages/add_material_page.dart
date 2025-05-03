import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../db/material_database.dart';
import '../models/material.dart';

class AddMaterialPage extends StatefulWidget {
  const AddMaterialPage({super.key});

  @override
  State<AddMaterialPage> createState() => _AddMaterialPageState();
}

class _AddMaterialPageState extends State<AddMaterialPage> {
  final _formKey = GlobalKey<FormState>();
  final _colorController = TextEditingController();
  final _priceController = TextEditingController();
  final _weightController = TextEditingController();
  final _brandController = TextEditingController();
  final _typeController = TextEditingController();
  final _sourceController = TextEditingController();
  final _dateController = TextEditingController();

  File? _imageFile;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  Future<void> _saveMaterial() async {
    if (_formKey.currentState?.validate() != true || _imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields and select an image.')),
      );
      return;
    }

    final item = MaterialItem(
      imagePath: _imageFile!.path,
      color: _colorController.text.trim(),
      price: double.parse(_priceController.text.trim()),
      weight: double.parse(_weightController.text.trim()),
      brand: _brandController.text.trim(),
      type: _typeController.text.trim(),
      source: _sourceController.text.trim(),
      purchaseDate: _dateController.text.trim(),
    );

    final newId = await MaterialDatabase.instance.insertMaterial(item);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Material Saved'),
        content: Text('Material ID: $newId'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    _formKey.currentState?.reset();
    _colorController.clear();
    _priceController.clear();
    _weightController.clear();
    _brandController.clear();
    _typeController.clear();
    _sourceController.clear();
    _dateController.clear();
    setState(() => _imageFile = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Material Stock')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
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
              const SizedBox(height: 16),
              TextFormField(
                controller: _colorController,
                decoration: const InputDecoration(labelText: 'Material Color'),
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _weightController,
                decoration: const InputDecoration(labelText: 'Weight'),
                keyboardType: TextInputType.number,
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _brandController,
                decoration: const InputDecoration(labelText: 'Brand'),
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _typeController,
                decoration: const InputDecoration(labelText: 'Material Type'),
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _sourceController,
                decoration: const InputDecoration(labelText: 'Buy From'),
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _dateController,
                readOnly: true,
                onTap: _pickDate,
                decoration: const InputDecoration(labelText: 'Purchase Date'),
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _saveMaterial,
                icon: const Icon(Icons.save),
                label: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
