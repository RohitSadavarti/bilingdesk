import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

class SignatureCaptureScreen extends StatefulWidget {
  @override
  _SignatureCaptureScreenState createState() => _SignatureCaptureScreenState();
}

class _SignatureCaptureScreenState extends State<SignatureCaptureScreen> {
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 2,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
    exportPenColor: Colors.black,
  );

  bool _isLoading = false;

  @override
  void dispose() {
    _signatureController.dispose();
    super.dispose();
  }

  Future<String?> _saveSignature() async {
    if (_signatureController.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please provide a signature first')),
      );
      return null;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Get the signature as image data
      final Uint8List? signatureBytes = await _signatureController.toPngBytes();
      
      if (signatureBytes == null) {
        throw Exception('Failed to capture signature');
      }

      // Optimize the image for better quality and smaller size
      final img.Image? originalImage = img.decodeImage(signatureBytes);
      if (originalImage == null) {
        throw Exception('Failed to decode signature image');
      }

      // Resize if too large (max 800x600 for good quality vs file size balance)
      img.Image resizedImage = originalImage;
      if (originalImage.width > 800 || originalImage.height > 600) {
        resizedImage = img.copyResize(
          originalImage,
          width: originalImage.width > 800 ? 800 : null,
          height: originalImage.height > 600 ? 600 : null,
        );
      }

      // Encode as PNG with good compression
      final Uint8List optimizedBytes = Uint8List.fromList(
        img.encodePng(resizedImage, level: 6), // Good compression level
      );

      // Get the app's temporary directory
      final Directory tempDir = await getTemporaryDirectory();
      final String signaturePath = '${tempDir.path}/signature_${DateTime.now().millisecondsSinceEpoch}.png';
      
      // Save the signature file
      final File signatureFile = File(signaturePath);
      await signatureFile.writeAsBytes(optimizedBytes);

      setState(() {
        _isLoading = false;
      });

      // Return the file path
      return signaturePath;
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving signature: $e')),
      );
      return null;
    }
  }

  void _clearSignature() {
    _signatureController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Capture Signature'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _clearSignature,
            icon: Icon(Icons.clear),
            tooltip: 'Clear Signature',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Signature(
                controller: _signatureController,
                backgroundColor: Colors.white,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Please sign above',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _clearSignature,
                      icon: Icon(Icons.clear),
                      label: Text('Clear'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : () async {
                        final String? signaturePath = await _saveSignature();
                        if (signaturePath != null) {
                          Navigator.pop(context, signaturePath);
                        }
                      },
                      icon: _isLoading 
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Icon(Icons.save),
                      label: Text(_isLoading ? 'Saving...' : 'Save Signature'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}