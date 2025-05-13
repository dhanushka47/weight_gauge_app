import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:restart_app/restart_app.dart';
import 'package:path/path.dart' as p;

import '../models/account.dart';

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
  List<BankAccount> _accounts = [];

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
      _logoFile = File(path);
    }
    final accountsJson = prefs.getStringList('bizAccounts') ?? [];
    _accounts = accountsJson.map((e) => BankAccount.fromMap(json.decode(e))).toList();
    setState(() {});
  }

  Future<void> _saveBusinessDetails() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('bizName', _nameController.text.trim());
    await prefs.setString('bizAddress', _addressController.text.trim());
    await prefs.setString('bizContact', _contactController.text.trim());
    await _saveAccounts();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Business details saved")),
    );
  }

  Future<void> _saveAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = _accounts.map((e) => json.encode(e.toMap())).toList();
    await prefs.setStringList('bizAccounts', encoded);
  }

  Future<void> _pickLogo() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('logoPath', picked.path);
      setState(() => _logoFile = File(picked.path));
    }
  }

  void _addAccountPopup() {
    final accountNameController = TextEditingController();
    final bankController = TextEditingController();
    final branchController = TextEditingController();
    final accountNoController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Bank Account'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: accountNameController, decoration: const InputDecoration(labelText: 'Account Name')),
            TextField(controller: bankController, decoration: const InputDecoration(labelText: 'Bank Name')),
            TextField(controller: branchController, decoration: const InputDecoration(labelText: 'Branch')),
            TextField(controller: accountNoController, decoration: const InputDecoration(labelText: 'Account Number')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final account = BankAccount(
                accountName: accountNameController.text.trim(),
                bankName: bankController.text.trim(),
                branch: branchController.text.trim(),
                accountNumber: accountNoController.text.trim(),
              );
              setState(() => _accounts.add(account));
              await _saveAccounts();
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount(int index) async {
    setState(() => _accounts.removeAt(index));
    await _saveAccounts();
  }

  Future<void> _resetEntireApp() async {
    final _pwController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reset Confirmation'),
        content: TextField(
          controller: _pwController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Enter Admin Password',
            hintText: 'Default: 1234@',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (_pwController.text.trim() == '1234@') {
                Navigator.pop(context, true);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('❌ Incorrect password')),
                );
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      final dbPath = await getDatabasesPath();
      final dbNames = ['invoice.db', 'quotation.db', 'customer.db', 'material.db'];
      for (final name in dbNames) {
        final path = p.join(dbPath, name);
        if (await File(path).exists()) {
          await deleteDatabase(path);
        }
      }

      final rootDir = Directory('/storage/emulated/0/Weight Gauge');
      if (await rootDir.exists()) {
        await rootDir.delete(recursive: true);
      }

      // Recreate folders
      for (final folder in ['pdfs', 'logs', 'database']) {
        final dir = Directory('${rootDir.path}/$folder');
        if (!await dir.exists()) {
          await dir.create(recursive: true);
        }
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ App reset successful. Restarting...')),
      );

      await Future.delayed(const Duration(seconds: 2));
      Restart.restartApp();

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Reset failed: $e')),
      );
    }
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: GestureDetector(
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
            const Divider(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Payment Accounts', style: TextStyle(fontWeight: FontWeight.bold)),
                TextButton.icon(
                  onPressed: _addAccountPopup,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Account'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_accounts.isEmpty)
              const Text('No accounts added')
            else
              ..._accounts.asMap().entries.map((entry) {
                final i = entry.key;
                final acc = entry.value;
                return Card(
                  child: ListTile(
                    title: Text('${acc.accountName} - ${acc.bankName} (${acc.branch})'),
                    subtitle: Text('Account No: ${acc.accountNumber}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteAccount(i),
                    ),
                  ),
                );
              }),
            const SizedBox(height: 30),
            const Divider(),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.delete_forever),
                label: const Text('Reset Entire App'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: _resetEntireApp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
