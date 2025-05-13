import 'package:flutter/material.dart';
import '../db/customer_database.dart';
import '../models/customer.dart';

class ManageCustomersPage extends StatefulWidget {
  const ManageCustomersPage({super.key});

  @override
  State<ManageCustomersPage> createState() => _ManageCustomersPageState();
}

class _ManageCustomersPageState extends State<ManageCustomersPage> {
  List<Customer> _customers = [];

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    final data = await CustomerDatabase.instance.getAllCustomers();
    setState(() => _customers = data);
  }

  Future<void> _deleteCustomer(int id) async {
    await CustomerDatabase.instance.deleteCustomer(id);
    await _loadCustomers();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Customer deleted')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Customers')),
      body: _customers.isEmpty
          ? const Center(child: Text('No customers found'))
          : ListView.builder(
        itemCount: _customers.length,
        itemBuilder: (context, index) {
          final customer = _customers[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text(customer.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Phone: ${customer.phone}\nLocation: ${customer.location}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteCustomer(customer.id!),
              ),
            ),
          );
        },
      ),
    );
  }
}
