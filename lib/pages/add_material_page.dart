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
  final _brandController = TextEditingController();
  final _sourceController = TextEditingController();
  final _priceController = TextEditingController();
  final _shippingController = TextEditingController();
  final _weightController = TextEditingController();
  final _quantityController = TextEditingController();

  DateTime? _purchaseDate;
  File? _imageFile;

  String? _selectedType;
  String? _selectedColor;

  List<MaterialModel> _materials = [];

  final List<String> _materialTypes = [
    'PLA', 'ABS', 'PETG', 'TPU', 'TPE', 'Nylon', 'PC', 'HIPS',
    'PVA', 'ASA', 'Carbon Fiber', 'Wood-filled', 'Metal-filled',
    'Resin', 'Tough Resin', 'Flexible Resin'
  ];

  final List<String> _colors = [
    'Black', 'White', 'Grey', 'Red', 'Blue', 'Green', 'Yellow', 'Orange',
    'Pink', 'Purple', 'Brown', 'Beige', 'Silver', 'Gold', 'Bronze',
    'Clear / Transparent', 'Translucent Tinted', 'Glow-in-the-dark',
    'Marble', 'Wood tones', 'Silk', 'Fluorescent'
  ];

  @override
  void initState() {
    super.initState();
    _loadMaterials();
  }

  Future<void> _loadMaterials() async {
    final data = await MaterialDatabase.instance.getAllMaterials();
    setState(() => _materials = data);
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  Future<void> _saveMaterial() async {
    if (!_formKey.currentState!.validate() ||
        _selectedType == null ||
        _selectedColor == null ||
        _purchaseDate == null ||
        _imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    final quantity = int.tryParse(_quantityController.text.trim()) ?? 1;
    final double weight = double.parse(_weightController.text.trim());
    final List<String> generatedIds = [];

    for (int i = 0; i < quantity; i++) {
      final id = await MaterialDatabase.instance.generateMaterialId(_selectedType!);

      final item = MaterialModel(
        materialId: id,
        type: _selectedType!,
        color: _selectedColor!,
        brand: _brandController.text.trim(),
        source: _sourceController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        shippingCost: double.parse(_shippingController.text.trim()),
        weight: weight,
        purchaseDate: DateFormat('yyyy-MM-dd').format(_purchaseDate!),
        imagePath: _imageFile!.path,
        isOutOfStock: false,
        availableGrams: weight,
      );

      await MaterialDatabase.instance.insertMaterial(item);
      generatedIds.add(id);
    }

    _formKey.currentState!.reset();
    _brandController.clear();
    _sourceController.clear();
    _priceController.clear();
    _shippingController.clear();
    _weightController.clear();
    _quantityController.clear();

    setState(() {
      _selectedColor = null;
      _selectedType = null;
      _purchaseDate = null;
      _imageFile = null;
    });

    await _loadMaterials();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Material(s) Saved'),
        content: Text('Saved ${generatedIds.length} reels:\n\n${generatedIds.join('\n')}'),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
      ),
    );
  }

  Future<void> _markAsOutAndDelete(MaterialModel mat) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Mark Out of Stock'),
        content: const Text('Are you sure you want to mark and delete this material?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Confirm')),
        ],
      ),
    );

    if (confirm == true) {
      await MaterialDatabase.instance.deleteMaterial(mat.id!);
      await _loadMaterials();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${mat.materialId} deleted as out of stock')),
      );
    }
  }

  @override
  void dispose() {
    _brandController.dispose();
    _sourceController.dispose();
    _priceController.dispose();
    _shippingController.dispose();
    _weightController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Material Stock')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: _imageFile == null
                        ? Container(
                      width: 150,
                      height: 150,
                      color: Colors.grey[300],
                      child: const Icon(Icons.add_a_photo, size: 40),
                    )
                        : Image.file(_imageFile!, height: 150),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedType,
                    hint: const Text('Select Material Type'),
                    items: _materialTypes
                        .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                        .toList(),
                    onChanged: (val) => setState(() => _selectedType = val),
                    validator: (val) => val == null ? 'Required' : null,
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _selectedColor,
                    hint: const Text('Select Color'),
                    items: _colors
                        .map((color) => DropdownMenuItem(value: color, child: Text(color)))
                        .toList(),
                    onChanged: (val) => setState(() => _selectedColor = val),
                    validator: (val) => val == null ? 'Required' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _brandController,
                    decoration: const InputDecoration(labelText: 'Brand'),
                    validator: (val) => val!.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: _sourceController,
                    decoration: const InputDecoration(labelText: 'Bought From'),
                    validator: (val) => val!.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Price Per Reel'),
                    validator: (val) =>
                    val!.isEmpty || double.tryParse(val) == null ? 'Enter valid price' : null,
                  ),
                  TextFormField(
                    controller: _shippingController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Shipping Cost'),
                    validator: (val) => val!.isEmpty || double.tryParse(val) == null
                        ? 'Enter valid shipping cost'
                        : null,
                  ),
                  TextFormField(
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Weight (g)'),
                    validator: (val) =>
                    val!.isEmpty || double.tryParse(val) == null ? 'Enter valid weight' : null,
                  ),
                  TextFormField(
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    decoration:
                    const InputDecoration(labelText: 'Quantity (No. of Reels)'),
                    validator: (val) =>
                    val!.isEmpty || int.tryParse(val) == null ? 'Enter valid quantity' : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _purchaseDate == null
                              ? 'No date selected'
                              : DateFormat('yyyy-MM-dd').format(_purchaseDate!),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setState(() => _purchaseDate = picked);
                          }
                        },
                        child: const Text('Pick Date'),
                      ),
                    ],
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
            const SizedBox(height: 30),
            const Divider(),
            const Text('Current Stock', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ..._materials.map((mat) {
              return Card(
                child: ListTile(
                  leading: Image.file(
                    File(mat.imagePath),
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  title: Text('${mat.materialId} • ${mat.type} (${mat.color})'),
                  subtitle: Text('Available: ${mat.availableGrams}g'),
                  trailing: IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    onPressed: () => _markAsOutAndDelete(mat),
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
