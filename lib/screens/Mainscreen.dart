import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:pdf_viewer/widgets/customButton.dart';
import 'package:pdf_viewer/widgets/custom_bottom_navigation_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'camera_screen.dart';
import 'pdf_list_screen.dart';
import 'Select_a_file_toSign.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';

class MainScreen extends StatefulWidget {
  final String username;

  const MainScreen({Key? key, required this.username}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    final prefs = await SharedPreferences.getInstance();
    final imagePath = prefs.getString('avatar_image');
    if (imagePath != null) {
      setState(() {
        _imageFile = File(imagePath);
      });
    }
  }

  Future<void> _saveImage(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('avatar_image', path);
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      await _saveImage(pickedFile.path);
    }
  }

  Future<void> _checkStoragePermission() async {
    final status = await Permission.storage.status;
    if (!status.isGranted) {
      final result = await Permission.storage.request();
      if (!result.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Storage permission is required to save the PDF.',
              style: TextStyle(color: Colors.white),
            ),
            action: SnackBarAction(
              label: 'Settings',
              onPressed: () {
                openAppSettings();
              },
            ),
          ),
        );
      }
    }
  }

  void _showChangeImageDialog() {
    showDialog(
      barrierColor: Colors.black.withOpacity(0.6),
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        title: const Text(
          'Change User Image?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Do you want to change the user image?',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _pickImage();
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  Future<void> _createAndSavePdf(BuildContext context) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Center(
          child: pw.Text('Hello World', style: pw.TextStyle(fontSize: 40)),
        ),
      ),
    );

    // Get temporary directory path
    final tempDir = await getTemporaryDirectory();
    final tempPath = tempDir.path;

    // Construct the file path
    final fileName = 'example.pdf';
    final filePath = '$tempPath/$fileName';

    // Save the PDF file
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    // Open the saved PDF file
    OpenFile.open(filePath);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('PDF saved at $filePath'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        title: Center(
          child: Text(
            'Pdf Viewer',
            style: GoogleFonts.dmSans(
              textStyle: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
        backgroundColor: Colors.black,
      ),
      backgroundColor: const Color(0xFF3C3C3C),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Row(
              children: [
                GestureDetector(
                  onTap: _showChangeImageDialog,
                  child: CircleAvatar(
                    backgroundImage: _imageFile != null
                        ? FileImage(_imageFile!)
                        : const NetworkImage(
                            'https://static.vecteezy.com/system/resources/thumbnails/020/765/399/small_2x/default-profile-account-unknown-icon-black-silhouette-free-vector.jpg',
                          ) as ImageProvider,
                    radius: 40,
                  ),
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Greetings,',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      widget.username,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(
              color: Colors.black,
              thickness: 2,
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CustomButton(
                    icon: Icons.document_scanner,
                    text: 'Scan PDF from Camera',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CameraScreen(),
                        ),
                      );
                    },
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.01,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: CustomButton(
                          icon: Icons.search,
                          text: 'View PDF',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PdfListScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: CustomButton(
                          icon: Icons.edit,
                          text: 'Sign a Document',
                          onPressed: () async {
                            await _createAndSavePdf(context);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
