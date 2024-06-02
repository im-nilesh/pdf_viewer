// lib/screens/pdf_viewer_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class PdfViewerScreen extends StatelessWidget {
  final String path;

  const PdfViewerScreen({Key? key, required this.path}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Viewer'),
        backgroundColor: Colors.black,
      ),
      body: PDFView(
        filePath: path,
      ),
    );
  }
}
