import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BusinessDetailsPage extends StatefulWidget {
  const BusinessDetailsPage({Key? key}) : super(key: key);

  @override
  State<BusinessDetailsPage> createState() => _BusinessDetailsPageState();
}

class _BusinessDetailsPageState extends State<BusinessDetailsPage> {
  final nameController = TextEditingController();
  final addressController = TextEditingController();
  File? logoImage;

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    nameController.text = prefs.getString('business_name') ?? '';
    addressController.text = prefs.getString('business_address') ?? '';
    final logoPath = prefs.getString('business_logo');
    if (logoPath != null && File(logoPath).existsSync()) {
      setState(() => logoImage = File(logoPath));
    }
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('business_name', nameController.text);
    await prefs.setString('business_address', addressController.text);
    if (logoImage != null) {
      await prefs.setString('business_logo', logoImage!.path);
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Saved successfully')));
  }

  Future<void> _pickLogo() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => logoImage = File(picked.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Business Details')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(controller: nameController, decoration: InputDecoration(labelText: 'Business Name')),
            TextField(controller: addressController, decoration: InputDecoration(labelText: 'Business Address')),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _pickLogo,
              icon: Icon(Icons.image),
              label: Text('Pick Business Logo'),
            ),
            if (logoImage != null) Image.file(logoImage!, height: 100),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveData,
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
