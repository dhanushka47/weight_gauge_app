import 'dart:io';
import 'dart:typed_data';
import 'package:permission_handler/permission_handler.dart';

class StorageHelper {
  static Future<Directory> getAppStorageDirectory() async {
    // Request storage permission if not already granted
    final status = await Permission.manageExternalStorage.request();
    if (!status.isGranted) {
      throw Exception('Storage permission denied');
    }

    // Set root path
    final Directory baseDir = Directory('/storage/emulated/0/Weight Gauge');
    if (!await baseDir.exists()) {
      await baseDir.create(recursive: true);
    }
    return baseDir;
  }

  static Future<File> savePdfFile(Uint8List pdfBytes, String filename) async {
    final dir = await getAppStorageDirectory();
    final pdfDir = Directory('${dir.path}/pdfs');
    if (!await pdfDir.exists()) {
      await pdfDir.create(recursive: true);
    }

    final filePath = '${pdfDir.path}/$filename';
    final file = File(filePath);
    await file.writeAsBytes(pdfBytes);
    return file;
  }
}
