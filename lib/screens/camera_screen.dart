// lib/screens/camera_screen.dart

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final ImagePicker _picker = ImagePicker();
  List<File> _images = [];

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _images.add(File(image.path));
      });
    }
  }

  Future<void> _convertToPdf() async {
    final pdf = pw.Document();
    for (var img in _images) {
      final image = pw.MemoryImage(img.readAsBytesSync());
      pdf.addPage(pw.Page(build: (pw.Context context) {
        return pw.Center(child: pw.Image(image));
      }));
    }
    final output = await getExternalStorageDirectory();
    final file = File("${output?.path}/document.pdf");
    await file.writeAsBytes(await pdf.save());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('PDF saved to ${file.path}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: const Color(0xFF3C3C3C),
      body: Column(
        children: [
          Expanded(
            child: _images.isEmpty
                ? const Center(
                    child: Text('No images taken',
                        style: TextStyle(color: Colors.white)))
                : GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3),
                    itemCount: _images.length,
                    itemBuilder: (context, index) {
                      return Image.file(_images[index]);
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 32),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  onPressed: _pickImage,
                  child: const Text('Take Picture'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 32),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  onPressed: _images.isNotEmpty ? _convertToPdf : null,
                  child: const Text('Convert to PDF'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
