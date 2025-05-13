import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/material.dart';

class MaterialDatabase {
  static final MaterialDatabase instance = MaterialDatabase._init();
  static Database? _database;

  MaterialDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('material.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE materials (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        materialId TEXT,
        type TEXT,
        color TEXT,
        brand TEXT,
        source TEXT,
        price REAL,
        shippingCost REAL,
        weight REAL,
        purchaseDate TEXT,
        imagePath TEXT,
        isOutOfStock INTEGER,
        availableGrams REAL
      )
    ''');
  }

  Future<void> insertMaterial(MaterialModel mat) async {
    final db = await instance.database;
    await db.insert('materials', mat.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<MaterialModel?> getMaterialById(int id) async {
    final db = await instance.database;
    final result = await db.query('materials', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      return MaterialModel.fromMap(result.first);
    }
    return null;
  }

  Future<void> updateMaterial(MaterialModel mat) async {
    final db = await instance.database;
    await db.update('materials', mat.toMap(), where: 'id = ?', whereArgs: [mat.id]);
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
  Future<String> generateMaterialId(String type) async {
    final db = await instance.database;
    final result = await db.query(
      'materials',
      where: 'type = ?',
      whereArgs: [type],
    );
    final count = result.length + 1;
    final shortType = type.replaceAll(RegExp(r'\s+'), '').substring(0, 3).toUpperCase();
    return '$shortType${count.toString().padLeft(4, '0')}';
  }
  Future<List<MaterialModel>> getAllMaterials() async {
    final db = await instance.database;
    final result = await db.query('materials');
    return result.map((map) => MaterialModel.fromMap(map)).toList();
  }
  Future<void> markOutOfStock(int id) async {
    final db = await instance.database;
    await db.update(
      'materials',
      {'isOutOfStock': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  Future<void> deleteMaterial(int id) async {
    final db = await instance.database;
    await db.delete('materials', where: 'id = ?', whereArgs: [id]);
  }

}
