import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tailoring_system/models/shop_profile.dart';
import 'package:tailoring_system/services/firebase_service.dart';

/// Service for managing shop/tailor profiles
class ShopService {
  final FirebaseService _firebase = FirebaseService();

  FirebaseFirestore get _firestore => _firebase.firestore;
  String? get _userId => _firebase.userId;

  /// Create shop profile for new tailor
  Future<void> createShopProfile(ShopProfile profile) async {
    if (_userId == null) throw Exception('User not authenticated');

    await _firestore.collection('shops').doc(_userId).set(profile.toMap());
  }

  /// Get shop profile
  Future<ShopProfile?> getShopProfile() async {
    if (_userId == null) return null;

    final doc = await _firestore.collection('shops').doc(_userId).get();
    
    if (!doc.exists) return null;
    
    return ShopProfile.fromMap(doc.data()!, doc.id);
  }

  /// Update shop profile
  Future<void> updateShopProfile(ShopProfile profile) async {
    if (_userId == null) throw Exception('User not authenticated');

    await _firestore.collection('shops').doc(_userId).update({
      ...profile.toMap(),
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  /// Check if shop setup is complete
  Future<bool> isSetupComplete() async {
    final profile = await getShopProfile();
    return profile?.isSetupComplete ?? false;
  }

  /// Mark shop setup as complete
  Future<void> completeSetup() async {
    if (_userId == null) throw Exception('User not authenticated');

    await _firestore.collection('shops').doc(_userId).update({
      'isSetupComplete': true,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }
}
