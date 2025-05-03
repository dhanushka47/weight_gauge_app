import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

Future<Uint8List> generateQuotationPdf({
  required File logoFile,
  required String customerName,
  required String date,
  required String description,
  required double total,
}) async {
  final pdf = pw.Document();
  final image = pw.MemoryImage(logoFile.readAsBytesSync());

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Header with logo and title
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Image(image, width: 80), // Logo on left
                pw.Text('Quotation', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Text('Date: $date'),
            pw.Text('Customer: $customerName'),
            pw.SizedBox(height: 20),
            pw.Text(description),
            pw.Divider(),
            pw.Text('Total: Rs. ${total.toStringAsFixed(2)}'),
          ],
        );
      },
    ),
  );

  return pdf.save();
}
