import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:permission_handler/permission_handler.dart';

class PdfUtils {
  static Future<void> savePdfUsingSaf(pw.Document pdf, String fileName) async {
    final status = await Permission.storage.request();
    if (status == PermissionStatus.granted) {
      final output = Directory('/storage/emulated/0/Download');
      final pdfFile = File("${output.path}/$fileName.pdf");
      await pdfFile.writeAsBytes(await pdf.save());
    } else {
      throw Exception('Permission denied');
    }
  }
}
