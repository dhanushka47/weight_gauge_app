import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

Future<void> generateQuotationPDF({
  required String customerName,
  required String itemDescription,
  required int quantity,
  required double rate,
}) async {
  final pdf = pw.Document();
  final total = quantity * rate;
  final date = DateTime.now();

  pdf.addPage(
    pw.Page(
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text("Quotation", style: pw.TextStyle(fontSize: 30, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.Text("Date: ${date.day}/${date.month}/${date.year}", style: pw.TextStyle(fontSize: 20)),
          pw.SizedBox(height: 5),
          pw.Text("Customer: $customerName", style: pw.TextStyle(fontSize: 10)),
          pw.SizedBox(height: 20),

          pw.Text("Item: $itemDescription", style: pw.TextStyle(fontSize: 12)),
          pw.Text("Quantity: $quantity", style: pw.TextStyle(fontSize: 12)),
          pw.Text("Rate: Rs. ${rate.toStringAsFixed(2)}", style: pw.TextStyle(fontSize: 12)),
          pw.Divider(),
          pw.Text("Total: Rs. ${total.toStringAsFixed(2)}",
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),

          pw.SizedBox(height: 30),
          pw.Text("Thank you!", style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic)),
        ],
      ),
    ),
  );

  // Display the print preview
  await Printing.layoutPdf(onLayout: (format) => pdf.save());
}
