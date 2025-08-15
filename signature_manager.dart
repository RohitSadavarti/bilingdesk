import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

class SignatureManager {
  static const int maxWidth = 800;
  static const int maxHeight = 600;
  static const int compressionLevel = 6;

  /// Optimizes signature image for better quality and smaller file size
  static Future<Uint8List> optimizeSignatureImage(Uint8List originalBytes) async {
    try {
      // Decode the original image
      final img.Image? originalImage = img.decodeImage(originalBytes);
      if (originalImage == null) {
        throw Exception('Failed to decode image');
      }

      // Resize if necessary
      img.Image processedImage = originalImage;
      if (originalImage.width > maxWidth || originalImage.height > maxHeight) {
        processedImage = img.copyResize(
          originalImage,
          width: originalImage.width > maxWidth ? maxWidth : null,
          height: originalImage.height > maxHeight ? maxHeight : null,
        );
      }

      // Apply image enhancement for better quality
      processedImage = img.contrast(processedImage, contrast: 120); // Enhance contrast
      processedImage = img.brightness(processedImage, brightness: 10); // Slight brightness boost

      // Encode with optimal compression
      return Uint8List.fromList(
        img.encodePng(processedImage, level: compressionLevel),
      );
    } catch (e) {
      // If optimization fails, return original bytes
      return originalBytes;
    }
  }

  /// Saves signature to temporary directory with timestamp
  static Future<String> saveSignatureToTemp(Uint8List signatureBytes) async {
    final Directory tempDir = await getTemporaryDirectory();
    final String fileName = 'signature_${DateTime.now().millisecondsSinceEpoch}.png';
    final String filePath = '${tempDir.path}/$fileName';
    
    final File signatureFile = File(filePath);
    await signatureFile.writeAsBytes(signatureBytes);
    
    return filePath;
  }

  /// Cleans up old signature files to free up storage
  static Future<void> cleanupOldSignatures() async {
    try {
      final Directory tempDir = await getTemporaryDirectory();
      final List<FileSystemEntity> files = tempDir.listSync();
      
      final DateTime cutoffTime = DateTime.now().subtract(Duration(hours: 24));
      
      for (FileSystemEntity file in files) {
        if (file is File && file.path.contains('signature_')) {
          final FileStat stat = await file.stat();
          if (stat.modified.isBefore(cutoffTime)) {
            await file.delete();
          }
        }
      }
    } catch (e) {
      print('Error cleaning up old signatures: $e');
    }
  }

  /// Validates if signature file exists and is readable
  static bool validateSignatureFile(String? signaturePath) {
    if (signaturePath == null) return false;
    final File file = File(signaturePath);
    return file.existsSync();
  }

  /// Gets signature file size in KB
  static Future<double> getSignatureFileSize(String signaturePath) async {
    try {
      final File file = File(signaturePath);
      if (!file.existsSync()) return 0.0;
      
      final int sizeInBytes = await file.length();
      return sizeInBytes / 1024; // Convert to KB
    } catch (e) {
      return 0.0;
    }
  }

  /// Creates a backup copy of signature (optional feature)
  static Future<String?> backupSignature(String signaturePath) async {
    try {
      final File originalFile = File(signaturePath);
      if (!originalFile.existsSync()) return null;

      final Directory appDir = await getApplicationDocumentsDirectory();
      final String backupPath = '${appDir.path}/signature_backup_${DateTime.now().millisecondsSinceEpoch}.png';
      
      await originalFile.copy(backupPath);
      return backupPath;
    } catch (e) {
      print('Error creating signature backup: $e');
      return null;
    }
  }
}