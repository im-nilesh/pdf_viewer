// pdf_utils.dart

import 'dart:io';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfUtils {
  static Future<void> savePdfUsingSaf(pw.Document pdf, String fileName) async {
    final output = Directory('/storage/emulated/0/Download');
    final pdfFile = File("${output.path}/$fileName.pdf");
    try {
      // Write the PDF data to the file using SAF
      final androidIntent = AndroidIntent(
        action: 'android.intent.action.CREATE_DOCUMENT',
        type: 'application/pdf',
        data: pdfFile.uri.toString(),
        flags: [Flag.FLAG_GRANT_WRITE_URI_PERMISSION],
      );
      await androidIntent.launch();
    } catch (e) {
      throw Exception('Failed to save PDF');
    }
  }
}
