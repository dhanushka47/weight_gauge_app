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

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE quotations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer TEXT,
        phone TEXT,
        location TEXT,
        deliveryDate TEXT,
        createdAt TEXT,
        total REAL,
        itemsJson TEXT,
        status TEXT
      )
    ''');
  }

  Future<int> insertQuotation(Quotation quotation) async {
    final db = await instance.database;
    return await db.insert('quotations', quotation.toMap());
  }

  Future<List<Quotation>> getAllQuotations() async {
    final db = await instance.database;
    final result = await db.query('quotations', orderBy: 'createdAt DESC');
    return result.map((map) => Quotation.fromMap(map)).toList();
  }

  Future<int> deleteQuotation(int id) async {
    final db = await instance.database;
    return await db.delete('quotations', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }

}
