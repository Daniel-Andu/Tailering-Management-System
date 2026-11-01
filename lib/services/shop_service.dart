import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:tailoring_system/models/shop_profile.dart';
import 'package:tailoring_system/services/firebase_service.dart';

/// Service for managing shop/tailor profiles
class ShopService {
  final FirebaseService _firebase = FirebaseService();

  FirebaseFirestore get _firestore => _firebase.firestore;
  String? get _userId => _firebase.userId;

  // Collection name - MUST match Firestore security rules
  static const String _collectionName = 'tailors';

  /// Create shop profile for new tailor
  Future<void> createShopProfile(ShopProfile profile) async {
    if (_userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      print('📝 Creating shop profile for user: $_userId');
      print('📝 Collection: $_collectionName');
      print('📝 Profile data: ${profile.toMap()}');

      // Test Firestore connectivity first
      print('🔍 Testing Firestore connectivity...');
      try {
        await _firestore.collection('_test').doc('connectivity').get();
        print('✅ Firestore is reachable');
      } catch (testError) {
        print('❌ Firestore connectivity test failed: $testError');
        throw Exception('Cannot connect to Firestore: $testError');
      }

      // Now create the actual profile
      print('📝 Writing to Firestore...');
      final docRef = _firestore.collection(_collectionName).doc(_userId);
      print('📝 Document path: ${docRef.path}');

      await docRef.set(profile.toMap());

      print('✅ Shop profile created successfully');

      // Verify it was actually written
      print('🔍 Verifying write...');
      final verifyDoc = await docRef.get();
      if (verifyDoc.exists) {
        print('✅ Write verified - document exists in Firestore');
      } else {
        print('⚠️ WARNING: Document was written but cannot be read back');
      }
    } catch (e) {
      print('❌ Error creating shop profile: $e');
      print('❌ Error type: ${e.runtimeType}');
      throw Exception('Failed to create shop profile: $e');
    }
  }

  /// Get shop profile
  Future<ShopProfile?> getShopProfile() async {
    if (_userId == null) {
      print('⚠️ Cannot get shop profile: User not authenticated');
      return null;
    }

    final doc = await _firestore.collection(_collectionName).doc(_userId).get();

    if (!doc.exists) return null;

    return ShopProfile.fromMap(doc.data()!, doc.id);
  }

  /// Update shop profile
  Future<void> updateShopProfile(ShopProfile profile) async {
    if (_userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      print('📝 Updating shop profile for user: $_userId');

      await _firestore.collection(_collectionName).doc(_userId).set({
        ...profile.toMap(),
        'updatedAt': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));

      print('✅ Shop profile updated successfully');
    } catch (e) {
      print('❌ Error updating shop profile: $e');
      throw Exception('Failed to update shop profile: $e');
    }
  }

  Future<String> uploadProfileImage(
    Uint8List bytes, {
    required String contentType,
  }) async {
    if (_userId == null) throw Exception('User not authenticated');
    final reference =
        _firebase.storage.ref().child('shops/$_userId/profile/profile-image');
    final result = await reference.putData(
      bytes,
      SettableMetadata(
        contentType: contentType,
        cacheControl: 'public,max-age=3600',
      ),
    );
    return result.ref.getDownloadURL();
  }

  /// Check if shop setup is complete
  Future<bool> isSetupComplete() async {
    try {
      final profile = await getShopProfile();
      final isComplete = profile?.isSetupComplete ?? false;
      print('🔍 Setup complete status: $isComplete');
      return isComplete;
    } catch (e) {
      print('❌ Error checking setup status: $e');
      return false;
    }
  }

  /// Mark shop setup as complete
  Future<void> completeSetup() async {
    if (_userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      print('📝 Marking setup as complete for user: $_userId');

      await _firestore.collection(_collectionName).doc(_userId).update({
        'isSetupComplete': true,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      print('✅ Setup marked as complete');
    } catch (e) {
      print('❌ Error completing setup: $e');
      throw Exception('Failed to complete setup: $e');
    }
  }
}
