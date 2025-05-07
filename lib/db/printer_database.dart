import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/printer.dart';

class PrinterDatabase {
  static final PrinterDatabase instance = PrinterDatabase._init();
  static Database? _database;

  PrinterDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('printers.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE printers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        power REAL NOT NULL,
        imagePath TEXT NOT NULL
      )
    ''');
  }

  Future<void> insertPrinter(Printer printer) async {
    final db = await instance.database;
    await db.insert('printers', printer.toMap());
  }

  Future<List<Printer>> getAllPrinters() async {
    final db = await instance.database;
    final result = await db.query('printers');
    return result.map((e) => Printer.fromMap(e)).toList();
  }


  Future<List<Printer>> fetchPrinters() async {
    return await getAllPrinters(); // Alias for consistency
  }
}