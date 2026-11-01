import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// Service for picking and compressing images before upload
class ImageService {
  static final ImagePicker _picker = ImagePicker();
  
  /// Maximum file size in bytes (1MB)
  static const int maxFileSizeBytes = 1024 * 1024;
  
  /// Target image dimensions (square)
  static const int targetSize = 512;

  /// Shows a bottom sheet to let user choose between camera and gallery,
  /// then picks and compresses the image.
  /// 
  /// Returns the compressed image File, or null if user cancels
  static Future<File?> pickAndCompressImage({
    required BuildContext context,
    required String title,
    required String cameraLabel,
    required String galleryLabel,
  }) async {
    final source = await _showImageSourcePicker(
      context: context,
      title: title,
      cameraLabel: cameraLabel,
      galleryLabel: galleryLabel,
    );
    
    if (source == null) return null;
    
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (pickedFile == null) return null;
      
      // Compress the image
      return await _compressImage(File(pickedFile.path));
    } catch (e) {
      if (e.toString().contains('photo_access_denied') || 
          e.toString().contains('camera_access_denied')) {
        throw Exception('Permission denied. Please enable camera/photos access in settings.');
      }
      throw Exception('Failed to pick image: ${e.toString()}');
    }
  }

  /// Shows a bottom sheet with camera and gallery options
  static Future<ImageSource?> _showImageSourcePicker({
    required BuildContext context,
    required String title,
    required String cameraLabel,
    required String galleryLabel,
  }) async {
    return await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final theme = Theme.of(context);
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle indicator
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Title
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              // Camera option
              _ImageSourceTile(
                icon: Icons.camera_alt,
                label: cameraLabel,
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              const SizedBox(height: 12),
              // Gallery option
              _ImageSourceTile(
                icon: Icons.photo_library,
                label: galleryLabel,
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  /// Compresses an image to target size and max file size
  static Future<File> _compressImage(File imageFile) async {
    try {
      // Read the image
      final bytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(bytes);
      
      if (image == null) {
        throw Exception('Failed to decode image');
      }
      
      // Resize to square with target dimensions
      final size = image.width > image.height ? image.height : image.width;
      image = img.copyCrop(
        image,
        x: (image.width - size) ~/ 2,
        y: (image.height - size) ~/ 2,
        width: size,
        height: size,
      );
      
      image = img.copyResize(
        image,
        width: targetSize,
        height: targetSize,
        interpolation: img.Interpolation.average,
      );
      
      // Compress to JPEG with quality adjustment
      int quality = 85;
      List<int> compressedBytes;
      
      do {
        compressedBytes = img.encodeJpg(image, quality: quality);
        if (compressedBytes.length <= maxFileSizeBytes || quality <= 20) {
          break;
        }
        quality -= 10;
      } while (true);
      
      // Save compressed image to temporary file
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'compressed_$timestamp.jpg';
      final compressedFile = File(path.join(tempDir.path, fileName));
      
      await compressedFile.writeAsBytes(compressedBytes);
      
      return compressedFile;
    } catch (e) {
      throw Exception('Failed to compress image: ${e.toString()}');
    }
  }
}

/// Widget for image source selection tile
class _ImageSourceTile extends StatelessWidget {
  const _ImageSourceTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.3),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: theme.colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
