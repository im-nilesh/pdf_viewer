import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:pdf_viewer/screens/signatureScreem.dart';
import 'package:pdf_viewer/widgets/DrawingPainter.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.file.path.split('/').last),
        actions: [
          IconButton(
            icon: Icon(Icons.rotate_right),
            onPressed: _rotatePdf,
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
                  _currentDrawing
                      .add(renderBox.globalToLocal(details.globalPosition));
                });
              },
              onPanEnd: (details) {
                setState(() {
                  _drawings.add(List.from(_currentDrawing));
                  _currentDrawing = [];
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
                SizedBox(width: 16),
                FloatingActionButton(
                  child: Icon(Icons.save),
                  onPressed: () {
                    _savePdfWithSignature();
                  },
                ),
              ],
            )
          : _isSignatureVisible
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
