import 'dart:io';
import 'package:flutter/material.dart';
import '../db/material_database.dart';
import '../models/material.dart'; // must define MaterialModel

class ViewMaterialPage extends StatefulWidget {
  const ViewMaterialPage({super.key});

  @override
  State<ViewMaterialPage> createState() => _ViewMaterialPageState();
}

class _ViewMaterialPageState extends State<ViewMaterialPage> {
  List<MaterialModel> _materials = [];

  @override
  void initState() {
    super.initState();
    _loadMaterials();
  }

  Future<void> _loadMaterials() async {
    final data = await MaterialDatabase.instance.getAllMaterials();
    setState(() => _materials = data);
  }

  Future<void> _deleteMaterial(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this material?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirm == true) {
      await MaterialDatabase.instance.deleteMaterial(id);
      await _loadMaterials();
    }
  }

  void _showMaterialDetails(MaterialModel mat) {
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
            Text('Price: Rs. ${mat.price.toStringAsFixed(2)}'),
            Text('Weight: ${mat.weight}g'),
            Text('Available: ${mat.availableGrams}g'),
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
                subtitle: Text('Available: ${mat.availableGrams}g'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteMaterial(mat.id!),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
