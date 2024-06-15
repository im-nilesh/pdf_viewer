import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

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

    String pdfName = await _showFileNameDialog();
    if (pdfName.isEmpty) {
      pdfName = 'Document';
    }

    if (await Permission.storage.request().isGranted) {
      final directory = await getExternalStorageDirectory();
      if (directory != null) {
        final filePath = '${directory.path}/$pdfName.pdf';
        final file = File(filePath);

        try {
          await file.writeAsBytes(await pdf.save());
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('PDF Saved Successfully')),
          );
          Navigator.pop(context); // Navigate back to MainScreen
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save PDF')),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permission denied to save PDF')),
      );
    }
  }

  Future<String> _showFileNameDialog() async {
    TextEditingController controller = TextEditingController();
    String fileName = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          title: Text(
            'Save PDF',
            style: TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Enter PDF name',
              hintStyle: TextStyle(color: Colors.white),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(controller.text);
              },
              child: Text(
                'Save',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
    return fileName ?? '';
  }

  Future<void> _deleteImage(int index) async {
    setState(() {
      _images.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Camera',
          style: TextStyle(color: Colors.white),
        ),
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
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: _images.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(
                              4.0), // Reduce the padding around each image
                          child: Stack(
                            children: [
                              SizedBox(
                                width: double
                                    .infinity, // Use the full width available for the image
                                height: double
                                    .infinity, // Use the full height available for the image
                                child: Image.file(
                                  _images[index],
                                  fit: BoxFit
                                      .cover, // Ensure the image covers the entire space
                                ),
                              ),
                              Positioned(
                                right:
                                    10, // Adjust the position of the delete button
                                top:
                                    -2, // Adjust the position of the delete button
                                child: Container(
                                  height: 30,
                                  width: 30,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.close,
                                        color: Colors.white),
                                    onPressed: () => _deleteImage(index),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
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
                  child: const Text(
                    'Take Picture',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 32),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  onPressed: _images.isNotEmpty ? _convertToPdf : null,
                  child: const Text(
                    'Convert to PDF',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
