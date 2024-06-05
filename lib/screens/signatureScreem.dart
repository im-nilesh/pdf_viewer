import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_signature_pad/flutter_signature_pad.dart';
import 'dart:ui' as ui;

class SignatureScreen extends StatefulWidget {
  @override
  _SignatureScreenState createState() => _SignatureScreenState();
}

class _SignatureScreenState extends State<SignatureScreen> {
  final GlobalKey<SignatureState> _signatureKey = GlobalKey();
  ByteData? _img;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Draw Signature'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.grey[300],
              child: Signature(
                key: _signatureKey,
                strokeWidth: 3.0,
                color: Colors.black,
                backgroundPainter: null,
                onSign: () async {
                  final signature = _signatureKey.currentState;
                  final image = await signature!.getData();
                  var data =
                      await image.toByteData(format: ui.ImageByteFormat.png);
                  setState(() {
                    _img = data;
                  });
                },
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Save signature and return to previous screen
              if (_img != null) {
                final signatureBytes = _img!.buffer.asUint8List();
                Navigator.pop(context, signatureBytes);
              }
            },
            child: Text('Save Signature'),
          ),
        ],
      ),
    );
  }
}
