import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:pdf_viewer/screens/signatureScreem.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';

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
  List<List<Offset>> _drawings = [];
  List<Offset> _currentDrawing = [];
  bool isSignSelected = false;
  bool isDrawSelected = false;
  double _signatureScale = 1.0;
  Offset _lastFocalPoint = Offset.zero;
  Offset _startFocalPoint = Offset.zero;

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
      isDrawSelected = _isDrawing;
      if (!_isDrawing) {
        _currentDrawing = [];
      }
    });
  }

  void _undoLastDrawing() {
    setState(() {
      if (_drawings.isNotEmpty) {
        _drawings.removeLast();
      }
    });
  }

  void _selectOption(String option) async {
    switch (option) {
      case 'Sign':
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
            isSignSelected = true;
          });
        }
        break;
      case 'Draw':
        _toggleDrawing();
        break;
    }
  }

  void _increaseSize() {
    setState(() {
      _signatureScale += 0.1;
    });
  }

  void _decreaseSize() {
    setState(() {
      _signatureScale -= 0.1;
    });
  }

  void _rotateSignature() {
    setState(() {
      _rotationAngle = (_rotationAngle + 90) % 360;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.file.path.split('/').last),
        actions: [
          if (_isSignatureVisible)
            IconButton(
              icon: Icon(Icons.rotate_right),
              onPressed: _rotateSignature,
            ),
          PopupMenuButton<String>(
            onSelected: _selectOption,
            itemBuilder: (BuildContext context) {
              return {'Sign', 'Draw'}.map((String choice) {
                bool isSelected = (choice == 'Sign' && isSignSelected) ||
                    (choice == 'Draw' && isDrawSelected);
                return PopupMenuItem<String>(
                  value: choice,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(choice),
                      if (isSelected)
                        Icon(
                          Icons.check,
                          color: Colors.green,
                        ),
                    ],
                  ),
                );
              }).toList();
            },
          ),
          if (_isSignatureVisible)
            IconButton(
              icon: Icon(Icons.add),
              onPressed: _increaseSize,
            ),
          if (_isSignatureVisible)
            IconButton(
              icon: Icon(Icons.remove),
              onPressed: _decreaseSize,
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
                  _currentPage = page! + 1;
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
              child: GestureDetector(
                onScaleStart: (ScaleStartDetails details) {
                  _startFocalPoint = details.focalPoint;
                  _lastFocalPoint = details.focalPoint;
                },
                onScaleUpdate: (ScaleUpdateDetails details) {
                  setState(() {
                    _signatureScale *= details.scale;
                    _signaturePosition += details.focalPoint - _lastFocalPoint;
                    _lastFocalPoint = details.focalPoint;
                  });
                },
                child: Transform.scale(
                  scale: _signatureScale,
                  child: Transform.rotate(
                    angle: _rotationAngle * 3.1415926535 / 180,
                    child: Image.memory(
                      widget.signatureData!,
                      width: 150,
                      height: 100,
                    ),
                  ),
                ),
              ),
            ),
          if (_isDrawing)
            GestureDetector(
              onPanStart: (DragStartDetails details) {
                RenderBox renderBox = context.findRenderObject() as RenderBox;
                Offset localPosition =
                    renderBox.globalToLocal(details.globalPosition);
                setState(() {
                  _currentDrawing = [localPosition];
                  _drawings.add(_currentDrawing);
                });
              },
              onPanUpdate: (DragUpdateDetails details) {
                RenderBox renderBox = context.findRenderObject() as RenderBox;
                Offset localPosition =
                    renderBox.globalToLocal(details.globalPosition);
                setState(() {
                  _currentDrawing.add(localPosition);
                });
              },
              onPanEnd: (DragEndDetails details) {
                setState(() {
                  _currentDrawing.clear();
                });
              },
              child: CustomPaint(
                size: Size.infinite,
                painter: DrawingPainter(_drawings, _currentDrawing),
              ),
            ),
        ],
      ),
      floatingActionButton: _isDrawing
          ? Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  child: Icon(Icons.undo),
                  onPressed: _undoLastDrawing,
                ),
              ],
            )
          : null,
    );
  }
}

class DrawingPainter extends CustomPainter {
  final List<List<Offset>> drawings;
  final List<Offset> currentDrawing;

  DrawingPainter(this.drawings, this.currentDrawing);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    for (var drawing in drawings) {
      if (drawing.isNotEmpty) {
        final path = Path()..moveTo(drawing.first.dx, drawing.first.dy);
        for (var point in drawing) {
          path.lineTo(point.dx, point.dy);
        }
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
