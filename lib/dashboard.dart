import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'pages/add_printer_page.dart';
import 'pages/expenses_page.dart';
import 'pages/add_material_page.dart'; // ✅ import the material page

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    _requestPermissions(); // 👈 Ask for permissions on app launch
  }

  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      final version = int.tryParse(Platform.version.split('.')[0]) ?? 0;
      final permission = version >= 13 ? Permission.photos : Permission.storage;

      if (!await permission.isGranted) {
        await permission.request();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome to Weight Gauge!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _dashboardButton(context, 'Add Printer', Icons.print),
                _dashboardButton(context, 'Expenses', Icons.money),
                _dashboardButton(context, 'Make Quotation', Icons.description),
                _dashboardButton(context, 'Make Invoice', Icons.receipt),
                _dashboardButton(context, 'Per Gram Calculator', Icons.scale),
                _dashboardButton(context, 'Add Material Stock', Icons.inventory), // ✅ New
              ],
            ),
            const SizedBox(height: 30),
            const Text(
              'Quick Insights',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.amber.shade100,
                ),
                child: const Center(child: Text('📈 Graph area (coming soon)')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dashboardButton(BuildContext context, String label, IconData icon) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
      onPressed: () {
        if (label == 'Add Printer') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddPrinterPage()),
          );
        } else if (label == 'Expenses') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ExpensesPage()),
          );
        } else if (label == 'Add Material Stock') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddMaterialPage()),
          );
        }
      },
      icon: Icon(icon),
      label: Text(label),
    );
  }
}
