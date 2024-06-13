import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class DrawingPainter extends CustomPainter {
  final List<List<Offset>> drawings;
  final List<Offset> currentDrawing;

  DrawingPainter(this.drawings, this.currentDrawing);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;

    for (var drawing in drawings) {
      for (int i = 0; i < drawing.length - 1; i++) {
        if (drawing[i] != Offset.zero && drawing[i + 1] != Offset.zero) {
          canvas.drawLine(drawing[i], drawing[i + 1], paint);
        } else if (drawing[i] != Offset.zero && drawing[i + 1] == Offset.zero) {
          canvas.drawPoints(ui.PointMode.points, [drawing[i]], paint);
        }
      }
    }

    for (int i = 0; i < currentDrawing.length - 1; i++) {
      if (currentDrawing[i] != Offset.zero &&
          currentDrawing[i + 1] != Offset.zero) {
        canvas.drawLine(currentDrawing[i], currentDrawing[i + 1], paint);
      } else if (currentDrawing[i] != Offset.zero &&
          currentDrawing[i + 1] == Offset.zero) {
        canvas.drawPoints(ui.PointMode.points, [currentDrawing[i]], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
