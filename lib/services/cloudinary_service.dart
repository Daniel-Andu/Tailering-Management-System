import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';

/// Cloudinary image upload service
class CloudinaryService {
  // Singleton pattern
  static final CloudinaryService _instance = CloudinaryService._internal();
  factory CloudinaryService() => _instance;
  CloudinaryService._internal();

  // Cloudinary credentials
  static const String _cloudName = 'xcig0m8u';
  static const String _uploadPreset = 'tailor'; // User's custom upload preset

  CloudinaryPublic? _cloudinary;

  /// Initialize Cloudinary
  void initialize() {
    _cloudinary = CloudinaryPublic(_cloudName, _uploadPreset, cache: false);
  }

  /// Get cloudinary instance (lazy initialization)
  CloudinaryPublic get cloudinary {
    _cloudinary ??= CloudinaryPublic(_cloudName, _uploadPreset, cache: false);
    return _cloudinary!;
  }

  /// Upload image to Cloudinary
  Future<String> uploadImage(File imageFile, {String folder = 'profile_photos'}) async {
    try {
      // Try upload without specifying folder first
      final response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          resourceType: CloudinaryResourceType.Image,
        ),
      );
      
      return response.secureUrl;
    } catch (e) {
      // If that fails, try with folder
      try {
        final response = await cloudinary.uploadFile(
          CloudinaryFile.fromFile(
            imageFile.path,
            folder: folder,
            resourceType: CloudinaryResourceType.Image,
          ),
        );
        return response.secureUrl;
      } catch (e2) {
        throw Exception('Failed to upload image: $e2');
      }
    }
  }

  /// Upload multiple images
  Future<List<String>> uploadImages(List<File> imageFiles, {String folder = 'orders'}) async {
    final urls = <String>[];
    
    for (final file in imageFiles) {
      final url = await uploadImage(file, folder: folder);
      urls.add(url);
    }
    
    return urls;
  }

  /// Note: Cloudinary deletion requires a signed API call
  /// For now, images remain in Cloudinary (won't affect your upload quota significantly)
  /// To delete images, you'll need to use Cloudinary Admin API with API secret
  /// or delete manually from Cloudinary Dashboard
}
