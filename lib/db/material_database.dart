import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/material.dart';

class MaterialDatabase {
  static final MaterialDatabase instance = MaterialDatabase._init();
  static Database? _database;

  MaterialDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('materials.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
  CREATE TABLE materials (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    materialId TEXT,
    type TEXT,
    color TEXT,
    brand TEXT,
    source TEXT,
    price REAL,
    shippingCost REAL, -- ✅ add this line
    weight REAL,
    purchaseDate TEXT,
    imagePath TEXT,
    isOutOfStock INTEGER DEFAULT 0
  )
''');

  }


  Future<void> insertMaterial(MaterialItem item) async {
    final db = await instance.database;
    await db.insert('materials', item.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<MaterialItem>> getAllMaterials() async {
    final db = await instance.database;
    final result = await db.query('materials');
    return result.map((map) => MaterialItem.fromMap(map)).toList();
  }

  Future<String> generateMaterialId(String type) async {
    final db = await instance.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM materials WHERE type = ?',
      [type],
    );

    int count = Sqflite.firstIntValue(result) ?? 0;
    String prefix = type.substring(0, 3).toUpperCase();
    String id = '$prefix${(count + 1).toString().padLeft(4, '0')}';
    return id;
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


  Future<List<MaterialItem>> fetchMaterials() async {
    return await getAllMaterials(); // Alias for consistency
  }



}

