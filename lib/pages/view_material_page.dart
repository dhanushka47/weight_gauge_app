import 'dart:io';
import 'package:flutter/material.dart';
import '../db/material_database.dart';
import '../models/material.dart';

class ViewMaterialPage extends StatefulWidget {
  const ViewMaterialPage({super.key});

  @override
  State<ViewMaterialPage> createState() => _ViewMaterialPageState();
}

class _ViewMaterialPageState extends State<ViewMaterialPage> {
  List<MaterialItem> _materials = [];

  @override
  void initState() {
    super.initState();
    _loadMaterials();
  }

  Future<void> _loadMaterials() async {
    final data = await MaterialDatabase.instance.getAllMaterials();
    setState(() => _materials = data);
  }

  Future<void> _markOutOfStock(int id) async {
    await MaterialDatabase.instance.markOutOfStock(id);
    await _loadMaterials(); // refresh UI
  }

  void _showMaterialDetails(MaterialItem mat) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(mat.materialId),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Brand: ${mat.brand}'),
            Text('Bought From: ${mat.source}'),
            Text('Price: \$${mat.price.toStringAsFixed(2)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Material Stock')),
      body: _materials.isEmpty
          ? const Center(child: Text('No materials found'))
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _materials.length,
        itemBuilder: (_, i) {
          final mat = _materials[i];
          return GestureDetector(
            onTap: () => _showMaterialDetails(mat),
            child: Card(
              color: mat.isOutOfStock ? Colors.grey[300] : Colors.orange.shade50,
              child: ListTile(
                leading: Image.file(
                  File(mat.imagePath),
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
                title: Text('${mat.materialId} • ${mat.type} (${mat.color})'),
                subtitle: Text('Weight: ${mat.weight}g'),
                trailing: mat.isOutOfStock
                    ? const Text(
                  'Out of Stock',
                  style: TextStyle(color: Colors.red),
                )
                    : TextButton(
                  child: const Text('Mark Out'),
                  onPressed: () => _markOutOfStock(mat.id!),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
