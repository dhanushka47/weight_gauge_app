import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/material.dart';

class MaterialDatabase {
  static final MaterialDatabase instance = MaterialDatabase._init();
  static Database? _database;

  MaterialDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'materials.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
    return _database!;
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE materials (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        imagePath TEXT NOT NULL,
        color TEXT NOT NULL,
        price REAL NOT NULL,
        weight REAL NOT NULL,
        brand TEXT NOT NULL,
        type TEXT NOT NULL,
        source TEXT NOT NULL,
        purchaseDate TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertMaterial(MaterialItem item) async {
    final db = await instance.database;
    return await db.insert('materials', item.toMap());
  }

  Future<List<MaterialItem>> getAllMaterials() async {
    final db = await instance.database;
    final result = await db.query('materials');
    return result.map((e) => MaterialItem.fromMap(e)).toList();
  }

  Future close() async {
    final db = await database;
    db?.close();
  }
}
