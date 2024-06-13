import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf_viewer/screens/pdf_list_screen.dart';
import 'PdfViewerScreen.dart';

class PdfSearchDelegate extends SearchDelegate<File> {
  final List<File> pdfFiles;

  PdfSearchDelegate(this.pdfFiles);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        // Close the search without returning any specific value
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = pdfFiles
        .where((file) => file.path
            .split('/')
            .last
            .toLowerCase()
            .contains(query.toLowerCase()))
        .toList();

    return Container(
      color: const Color(0xFF3C3C3C), // Set the background color to grey

      child: ListView.builder(
        itemCount: results.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Icon(Icons.picture_as_pdf, color: Colors.white),
            title: Text(
              results[index].path.split('/').last,
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PdfViewerScreen(file: results[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = pdfFiles
        .where((file) => file.path
            .split('/')
            .last
            .toLowerCase()
            .contains(query.toLowerCase()))
        .toList();

    return Container(
      color: Colors.black, // Set the background color to black
      child: ListView.builder(
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Icon(Icons.picture_as_pdf, color: Colors.white),
            title: Text(
              suggestions[index].path.split('/').last,
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              query = suggestions[index].path.split('/').last;
              showResults(context);
            },
          );
        },
      ),
    );
  }
}
