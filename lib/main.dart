import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'theme.dart';
import 'dashboard.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// ✅ 1. Place setupAppDirectories here
Future<void> setupAppDirectories() async {
  final status = await Permission.manageExternalStorage.request();
  if (!status.isGranted) return;

  final rootDir = Directory('/storage/emulated/0/Weight Gauge');
  final pdfDir = Directory('${rootDir.path}/pdfs');
  final dbDir = Directory('${rootDir.path}/database');
  final logDir = Directory('${rootDir.path}/logs');

  for (var dir in [rootDir, pdfDir, dbDir, logDir]) {
    if (!await dir.exists()) {
      await dir.create(recursive: true);
      debugPrint('📁 Created: ${dir.path}');
    } else {
      debugPrint('📁 Exists: ${dir.path}');
    }
  }
}

Future<void> deleteLocalMaterialDB() async {
  final dbPath = await getDatabasesPath();
  final path = join(dbPath, 'materials.db');
  await deleteDatabase(path);
}

// ✅ 2. Now main() can use it
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupAppDirectories(); // ✅ No longer undefined
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: appTheme,
      home: const DashboardPage(),
    );
  }
}

// The rest of your MyHomePage code stays unchanged
