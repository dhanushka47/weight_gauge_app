import 'package:flutter/material.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'theme.dart';
import 'pages/splash_screen.dart'; // ✅ Add this

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
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupAppDirectories();
  runApp(const WeightGaugeApp());
}

class WeightGaugeApp extends StatelessWidget {
  const WeightGaugeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weight Gauge',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      home: const SplashScreen(), // ✅ Load splash first
    );
  }
}
