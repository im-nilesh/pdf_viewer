import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_viewer/screens/SearchScreen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'PdfViewerScreen.dart';

class PdfListScreen extends StatefulWidget {
  @override
  _PdfListScreenState createState() => _PdfListScreenState();
}

class _PdfListScreenState extends State<PdfListScreen> {
  List<File> _pdfFiles = [];

  @override
  void initState() {
    super.initState();
    _fetchPdfFiles();
  }

  Future<void> _fetchPdfFiles() async {
    if (await Permission.storage.request().isGranted) {
      // Get various common directories
      List<Directory?> directories = [
        await getExternalStorageDirectory(),
        await getApplicationDocumentsDirectory(),
        Directory('/storage/emulated/0/Download'),
        Directory('/storage/emulated/0/Documents'),
        Directory('/storage/emulated/0/'),
      ];

      for (Directory? directory in directories) {
        if (directory != null) {
          _searchForPdfs(directory);
        }
      }
    }
  }

  void _searchForPdfs(Directory directory) {
    try {
      List<FileSystemEntity> files = directory.listSync(recursive: true);
      List<File> pdfFiles = files
          .where((file) => file is File && file.path.endsWith('.pdf'))
          .map((file) => File(file.path))
          .toList();

      setState(() {
        _pdfFiles.addAll(pdfFiles);
      });
    } catch (e) {
      // Handle any exceptions that occur during the file search
      print('Error while searching for PDFs: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'PDF Files',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Icon(
              Icons.search,
              color: Colors.white,
            ),
            onPressed: () {
              showSearch(
                context: context,
                delegate: PdfSearchDelegate(_pdfFiles),
              );
            },
          ),
        ],
      ),
      backgroundColor: const Color(0xFF3C3C3C),
      body: _pdfFiles.isEmpty
          ? const Center(
              child: Text(
                'No PDF files found',
                style: TextStyle(color: Colors.white),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(10),
              child: ListView.builder(
                itemCount: _pdfFiles.length,
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                    ),
                    child: ListTile(
                      leading: Icon(
                        Icons.picture_as_pdf,
                        color: Colors.white,
                        size: 48, // Adjusted the size of the PDF icon
                      ),
                      title: Text(
                        _pdfFiles[index].path.split('/').last,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20, // Adjusted the font size of the title
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PdfViewerScreen(file: _pdfFiles[index]),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
    );
  }
}
