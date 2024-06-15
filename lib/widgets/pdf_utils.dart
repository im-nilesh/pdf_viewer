import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

Future<File?> createAndSavePdf() async {
  // Check storage permission
  if (await Permission.storage.request().isGranted) {
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
    final directory = await getExternalStorageDirectory();
    if (directory != null) {
      final filePath = '${directory.path}/example.pdf';
      final file = File(filePath);

      // Save the PDF file
      await file.writeAsBytes(await pdf.save());

      return file;
    }
  } else {
    // If permission is denied, show a snackbar or a dialog to the user
    return null;
  }
}
