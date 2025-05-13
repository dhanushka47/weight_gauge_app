import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fl_chart/fl_chart.dart';
import 'db/material_database.dart';
import 'models/material.dart';
import 'pages/add_printer_page.dart';
import 'pages/expenses_page.dart';
import 'pages/add_material_page.dart';
import 'pages/view_material_page.dart';
import 'pages/quotation_page.dart';
import 'pages/business_details_page.dart';
import 'pages/quotation_dashboard_page.dart';
import 'pages/invoices_page.dart';
import 'dart:async';
import 'db/invoice_database.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<MaterialModel> _materials = [];
  List<Map<String, String>> _summaryData = [];
  Timer? _refreshTimer;



  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _loadMaterials();
    // Auto-refresh every 5 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _loadMaterials();
      _loadSummaryData();

    });
  }
  Future<void> _loadSummaryData() async {
    final totalInvoices = await InvoiceDatabase.instance.getInvoiceCount();
    final paidInvoices = await InvoiceDatabase.instance.getPaidInvoiceCount();
    final unpaidInvoices = await InvoiceDatabase.instance.getUnpaidInvoiceCount();

    setState(() {
      _summaryData = [
        {'label': 'All Invoices', 'value': '$totalInvoices'},
        {'label': 'Paid', 'value': '$paidInvoices'},
        {'label': 'Unpaid', 'value': '$unpaidInvoices'},
      ];
    });
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


  Future<void> _loadMaterials() async {
    final data = await MaterialDatabase.instance.getAllMaterials();
    setState(() => _materials = data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Quick Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _summaryData.map((e) {
                return Expanded(
                  child: Card(
                    margin: const EdgeInsets.all(6),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Text(e['value']!, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          Text(e['label']!, style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            const Text('Material Stock (grams)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: _materials.isEmpty
                      ? const Center(child: Text('No data'))
                      : BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        gridData: FlGridData(show: true), // ✅ Show grid lines
                        borderData: FlBorderData(show: true), // ✅ Show borders

                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 32,
                              getTitlesWidget: (value, _) => Text(
                                value.toInt().toString(),
                                style: const TextStyle(fontSize: 10),
                              ),
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (double value, _) {
                                final index = value.toInt();
                                if (index < 0 || index >= _materials.length) return const SizedBox();
                                return Text(
                                  _materials[index].materialId,
                                  style: const TextStyle(fontSize: 10),
                                );
                              },
                            ),
                          ),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),



                        barGroups: _materials.asMap().entries.map((entry) {
                          final index = entry.key;
                          final mat = entry.value;
                          return BarChartGroupData(x: index, barRods: [
                            BarChartRodData(toY: mat.availableGrams, width: 12),
                          ]);
                        }).toList(),
                      )



                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _dashboardButton(context, 'Add Printer', Icons.print),
                _dashboardButton(context, 'Add Material Stock', Icons.inventory),
                _dashboardButton(context, 'Make Quotation', Icons.description),
              //  _dashboardButton(context, 'Expenses', Icons.money),
                //  _dashboardButton(context, 'Make Invoice', Icons.receipt),
             //   _dashboardButton(context, 'Per Gram Calculator', Icons.scale),

                _dashboardButton(context, 'View Material Stock', Icons.storage),

                _dashboardButton(context, 'Saved Quotations', Icons.folder_copy),
                _dashboardButton(context, 'Invoices', Icons.receipt_long),
                _dashboardButton(context, 'Business Details', Icons.settings),
              ],
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
        switch (label) {
          case 'Add Printer':
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AddPrinterPage()));
            break;
          case 'Expenses':
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ExpensesPage()));
            break;
          case 'Make Quotation':
            Navigator.push(context, MaterialPageRoute(builder: (_) => const QuotationPage()));
            break;
          case 'Add Material Stock':
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AddMaterialPage()));
            break;
          case 'View Material Stock':
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ViewMaterialPage()));
            break;
          case 'Business Details':
            Navigator.push(context, MaterialPageRoute(builder: (_) => const BusinessDetailsPage()));
            break;
          case 'Saved Quotations':
            Navigator.push(context, MaterialPageRoute(builder: (_) => const QuotationDashboardPage()));
            break;
          case 'Make Invoice':
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Invoice page coming soon!')),
            );
            break;
          case 'Invoices':
            Navigator.push(context, MaterialPageRoute(builder: (_) => const InvoicesPage()));
            break;
        }
      },
      icon: Icon(icon),
      label: Text(label),
    );
  }
}
