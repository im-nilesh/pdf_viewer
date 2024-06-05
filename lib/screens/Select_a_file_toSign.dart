import 'package:flutter/material.dart';
import 'package:pdf_viewer/screens/pdf_list_screen.dart'; // Import the PDF list screen

class PdfViewScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Select PDF',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      backgroundColor: const Color(0xFF3C3C3C),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Select a Document to Sign',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: () {
                // Navigate to the PDF list screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PdfListScreen(),
                  ),
                );
              },
              child: const Text('Select PDF'),
            ),
          ],
        ),
      ),
    );
  }
}
