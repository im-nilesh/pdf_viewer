import 'dart:typed_data';
import 'dart:ui' as ui; // Import dart:ui for PointMode
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'dart:io';

import 'package:pdf_viewer/screens/signatureScreem.dart';

class PdfViewerScreen extends StatefulWidget {
  final File file;
  Uint8List? signatureData;

  PdfViewerScreen({required this.file, this.signatureData});

  @override
  _PdfViewerScreenState createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  int _totalPages = 0;
  int _currentPage = 0;
  bool _isReady = false;
  String _errorMessage = '';
  Offset _signaturePosition = Offset.zero;
  bool _isSignatureVisible = false;
  int _rotationAngle = 0;
  bool _isDrawing = false;
  List<Offset> _points = [];

  @override
  void initState() {
    super.initState();
    if (widget.signatureData != null) {
      _isSignatureVisible = true;
    }
  }

  void _rotatePdf() {
    setState(() {
      _rotationAngle = (_rotationAngle + 90) % 360;
    });
  }

  void _toggleDrawing() {
    setState(() {
      _isDrawing = !_isDrawing;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.file.path.split('/').last),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () async {
              final signatureImage = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SignatureScreen(),
                ),
              );
              if (signatureImage != null) {
                setState(() {
                  widget.signatureData = signatureImage;
                  _isSignatureVisible = true;
                });
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.rotate_right),
            onPressed: _rotatePdf,
          ),
          IconButton(
            icon: Icon(_isDrawing ? Icons.brush : Icons.edit),
            onPressed: _toggleDrawing,
          ),
          if (_isReady && _totalPages > 0)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Text('$_currentPage/$_totalPages'),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          Transform.rotate(
            angle: _rotationAngle * 3.1415926535 / 180,
            child: PDFView(
              filePath: widget.file.path,
              autoSpacing: false,
              pageFling: false,
              pageSnap: false,
              onRender: (_pages) {
                setState(() {
                  _totalPages = _pages!;
                  _isReady = true;
                });
              },
              onError: (error) {
                setState(() {
                  _errorMessage = error.toString();
                });
                print(error.toString());
              },
              onPageError: (page, error) {
                setState(() {
                  _errorMessage = '$page: ${error.toString()}';
                });
                print('$page: ${error.toString()}');
              },
              onPageChanged: (page, total) {
                setState(() {
                  _currentPage = page! + 1; // page is zero-based, so adding 1
                  _totalPages = total!;
                });
              },
            ),
          ),
          if (!_isReady)
            Center(
              child: CircularProgressIndicator(),
            ),
          if (_errorMessage.isNotEmpty)
            Center(
              child: Text(_errorMessage),
            ),
          if (_isSignatureVisible && widget.signatureData != null)
            Positioned(
              left: _signaturePosition.dx,
              top: _signaturePosition.dy,
              child: Draggable(
                feedback: Image.memory(widget.signatureData!,
                    width: 150, height: 100),
                childWhenDragging: Container(),
                onDraggableCanceled: (velocity, offset) {
                  setState(() {
                    _signaturePosition = offset;
                  });
                },
                child: Image.memory(widget.signatureData!,
                    width: 150, height: 100),
              ),
            ),
          if (_isDrawing)
            GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  RenderBox renderBox = context.findRenderObject() as RenderBox;
                  _points.add(renderBox.globalToLocal(details.globalPosition));
                });
              },
              onPanEnd: (details) {
                _points.add(Offset.zero);
              },
              child: CustomPaint(
                size: Size.infinite,
                painter: DrawingPainter(_points),
              ),
            ),
        ],
      ),
      floatingActionButton: _isSignatureVisible
          ? FloatingActionButton(
              child: Icon(Icons.save),
              onPressed: () {
                _savePdfWithSignature();
              },
            )
          : null,
    );
  }

  void _savePdfWithSignature() {
    // Implement your save PDF functionality here
    // This method should save the signature position and embed it into the PDF file
  }
}

class DrawingPainter extends CustomPainter {
  final List<Offset> points;

  DrawingPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != Offset.zero && points[i + 1] != Offset.zero) {
        canvas.drawLine(points[i], points[i + 1], paint);
      } else if (points[i] != Offset.zero && points[i + 1] == Offset.zero) {
        canvas.drawPoints(ui.PointMode.points, [points[i]],
            paint); // Use PointMode from dart:ui
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
