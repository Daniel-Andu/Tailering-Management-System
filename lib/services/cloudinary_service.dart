import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';

/// Cloudinary image upload service
class CloudinaryService {
  // Singleton pattern
  static final CloudinaryService _instance = CloudinaryService._internal();
  factory CloudinaryService() => _instance;
  CloudinaryService._internal();

  // Cloudinary credentials
  static const String _cloudName = 'hozmwqs8';
  static const String _uploadPreset = 'tailoring_app';

  late CloudinaryPublic _cloudinary;

  /// Initialize Cloudinary
  void initialize() {
    _cloudinary = CloudinaryPublic(_cloudName, _uploadPreset, cache: false);
  }

  /// Upload image to Cloudinary
  Future<String> uploadImage(File imageFile, {String folder = 'orders'}) async {
    try {
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          folder: folder,
          resourceType: CloudinaryResourceType.Image,
        ),
      );
      
      return response.secureUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
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
