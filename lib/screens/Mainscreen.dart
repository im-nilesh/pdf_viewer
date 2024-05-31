import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MainScreen extends StatelessWidget {
  final String username;

  const MainScreen({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        title: Center(
          child: Text(
            'Pdf Viewer',
            style: GoogleFonts.dmSerifDisplay(
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
            SizedBox(height: 20),
            const CircleAvatar(
              backgroundImage: NetworkImage(
                  'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQdi6qPKPphfLuH_-nqSiMKQ2NqGMZHlEBO-Q&s'),
              radius: 40,
            ),
            SizedBox(height: 20),
            Text(
              'Greetings, $username!',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
