import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BusinessDetailsPage extends StatefulWidget {
  const BusinessDetailsPage({super.key});

  @override
  State<BusinessDetailsPage> createState() => _BusinessDetailsPageState();
}

class _BusinessDetailsPageState extends State<BusinessDetailsPage> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _contactController = TextEditingController();
  File? _logoFile;

  @override
  void initState() {
    super.initState();
    _loadSavedDetails();
  }

  Future<void> _loadSavedDetails() async {
    final prefs = await SharedPreferences.getInstance();
    _nameController.text = prefs.getString('bizName') ?? '';
    _addressController.text = prefs.getString('bizAddress') ?? '';
    _contactController.text = prefs.getString('bizContact') ?? '';
    final path = prefs.getString('logoPath');
    if (path != null && File(path).existsSync()) {
      setState(() => _logoFile = File(path));
    }
  }

  Future<void> _pickLogo() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('logoPath', picked.path);
      setState(() => _logoFile = File(picked.path));
    }
  }

  Future<void> _saveBusinessDetails() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('bizName', _nameController.text.trim());
    await prefs.setString('bizAddress', _addressController.text.trim());
    await prefs.setString('bizContact', _contactController.text.trim());

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Business details saved")),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Business Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickLogo,
              child: _logoFile == null
                  ? Container(
                width: 100,
                height: 100,
                color: Colors.grey[300],
                child: const Icon(Icons.image, size: 40),
              )
                  : Image.file(_logoFile!, height: 100),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Business Name'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'Address'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _contactController,
              decoration: const InputDecoration(labelText: 'Contact Info'),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('Save Details'),
              onPressed: _saveBusinessDetails,
            ),
          ],
        ),
      ),
    );
  }
}
