import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/quotation.dart';

class QuotationDatabase {
  static final QuotationDatabase instance = QuotationDatabase._init();
  static Database? _database;

  QuotationDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('quotation.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
  CREATE TABLE quotations (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    customer TEXT NOT NULL,
    phone TEXT NOT NULL,
    location TEXT NOT NULL,
    deliveryDate TEXT NOT NULL,
    total REAL NOT NULL,
    createdAt TEXT NOT NULL,
    itemsJson TEXT NOT NULL,
    status TEXT NOT NULL
  )
''');
  }

  Future<void> insertQuotation(Quotation q) async {
    final db = await instance.database;
    await db.insert('quotations', q.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Quotation>> getAllQuotations() async {
    final db = await instance.database;
    final result = await db.query('quotations');
    return result.map((e) => Quotation.fromMap(e)).toList();
  }

  Future<void> updateQuotation(Quotation quotation) async {
    final db = await instance.database;
    await db.update(
      'quotations',
      quotation.toMap(),
      where: 'id = ?',
      whereArgs: [quotation.id],
    );
  }

  Future<void> deleteQuotation(int id) async {
    final db = await instance.database;
    await db.delete('quotations', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
