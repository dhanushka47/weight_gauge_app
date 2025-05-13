import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/invoice.dart';

class InvoiceDatabase {
  static final InvoiceDatabase instance = InvoiceDatabase._init();
  static Database? _database;

  InvoiceDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('invoice.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE invoices (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer TEXT NOT NULL,
        phone TEXT NOT NULL,
        date TEXT NOT NULL,
        total REAL NOT NULL,
        itemsJson TEXT NOT NULL,
        paidAmount REAL,
        paidDate TEXT,
        reelUsed TEXT,
        usedMaterialAmount REAL
      )
    ''');
  }

  Future<List<Invoice>> getAllInvoices() async {
    final db = await instance.database;
    final result = await db.query('invoices', orderBy: 'date DESC');
    return result.map((json) => Invoice.fromMap(json)).toList();
  }

  Future<void> insertInvoice(Invoice invoice) async {
    final db = await instance.database;
    await db.insert('invoices', invoice.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateInvoice(Invoice invoice) async {
    final db = await instance.database;
    await db.update(
      'invoices',
      invoice.toMap(),
      where: 'id = ?',
      whereArgs: [invoice.id],
    );
  }

  Future<void> deleteInvoice(int id) async {
    final db = await instance.database;
    await db.delete(
      'invoices',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }

  Future<int> getInvoiceCount() async {
    final db = await instance.database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM invoices');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getPaidInvoiceCount() async {
    final db = await instance.database;
    final result = await db.rawQuery(
        'SELECT COUNT(*) FROM invoices WHERE paidAmount IS NOT NULL AND paidAmount > 0'
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getUnpaidInvoiceCount() async {
    final db = await instance.database;
    final result = await db.rawQuery(
        'SELECT COUNT(*) FROM invoices WHERE paidAmount IS NULL OR paidAmount = 0'
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
