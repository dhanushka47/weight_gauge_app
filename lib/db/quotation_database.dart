import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/quotation.dart';

class QuotationDatabase {
  static final QuotationDatabase instance = QuotationDatabase._init();
  static Database? _database;

  QuotationDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('quotations.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
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

  /// Insert a quotation
  Future<int> insertQuotation(Quotation quotation) async {
    final db = await instance.database;
    return await db.insert('quotations', quotation.toMap());
  }

  /// Fetch all quotations
  Future<List<Quotation>> getAllQuotations() async {
    final db = await instance.database;
    final result = await db.query('quotations', orderBy: 'createdAt DESC');
    return result.map((json) => Quotation.fromMap(json)).toList();
  }

  /// Update a quotation
  Future<void> updateQuotation(Quotation quotation) async {
    final db = await instance.database;
    await db.update(
      'quotations',
      quotation.toMap(),
      where: 'id = ?',
      whereArgs: [quotation.id],
    );
  }

  /// Delete a quotation
  Future<void> deleteQuotation(int id) async {
    final db = await instance.database;
    await db.delete('quotations', where: 'id = ?', whereArgs: [id]);
  }

  /// Close database
  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }

  /// ✅ Get quotation count (for dashboard)
  Future<int> getQuotationCount() async {
    final db = await instance.database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM quotations');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
