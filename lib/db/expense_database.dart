import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/expense.dart';

class ExpenseDatabase {
  static final ExpenseDatabase instance = ExpenseDatabase._init();
  static Database? _database;

  ExpenseDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('expenses.db');
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

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        printerId INTEGER,
        printerName TEXT,
        imagePath TEXT,
        maintenanceCost REAL,
        rentalCost REAL,
        unitPrice REAL
      )
    ''');
  }

  Future<void> insertExpense(Expense expense) async {
    final db = await instance.database;
    await db.insert('expenses', expense.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Expense>> getAllExpenses() async {
    final db = await instance.database;
    final result = await db.query('expenses');
    return result.map((e) => Expense.fromMap(e)).toList();
  }

  Future<void> clearAll() async {
    final db = await instance.database;
    await db.delete('expenses');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
