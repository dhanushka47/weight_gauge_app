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
          return Card(
            color: mat.isOutOfStock ? Colors.grey[300] : null,
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
                  ? const Text('Out of Stock',
                  style: TextStyle(color: Colors.red))
                  : TextButton(
                child: const Text('Mark Out'),
                onPressed: () => _markOutOfStock(mat.id!),

              ),
            ),
          );
        },
      ),
    );
  }
}
