import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

Future<File?> createAndSavePdf() async {
  try {
    final pdf = pw.Document();

    // Add content to the PDF
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Center(
          child: pw.Text('Hello World'),
        ),
      ),
    );

    // Get the directory to save the file
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/example.pdf';
    final file = File(filePath);

    // Save the PDF file
    await file.writeAsBytes(await pdf.save());

    return file;
  } catch (e) {
    print('Error creating PDF: $e');
    return null;
  }
}
