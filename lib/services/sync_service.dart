import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Sync status for offline-first architecture
enum SyncStatus {
  synced,       // Successfully synced with cloud
  pending,      // Waiting to sync (created/modified offline)
  error,        // Sync failed (will retry)
}

/// Base sync service for all entities
/// Implements offline-first with background cloud sync
class SyncService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current user's UID (required for all sync operations)
  String? get currentUserId => _auth.currentUser?.uid;

  /// Get Firestore collection reference for current user
  CollectionReference getUserCollection(String collectionName) {
    if (currentUserId == null) {
      throw Exception('User must be authenticated to sync data');
    }
    return _firestore
        .collection('tailors')
        .doc(currentUserId)
        .collection(collectionName);
  }

  /// Convert Firestore timestamp to DateTime
  DateTime? timestampToDateTime(dynamic timestamp) {
    if (timestamp == null) return null;
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    }
    if (timestamp is DateTime) {
      return timestamp;
    }
    return null;
  }

  /// Convert DateTime to Firestore timestamp
  Timestamp? dateTimeToTimestamp(DateTime? dateTime) {
    if (dateTime == null) return null;
    return Timestamp.fromDate(dateTime);
  }

  /// Check if device is online (simplified - can be enhanced)
  Future<bool> isOnline() async {
    try {
      // Try to access Firestore - if it fails, we're offline
      await _firestore
          .collection('_health_check')
          .doc('ping')
          .get()
          .timeout(const Duration(seconds: 5));
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Generic sync for any entity
  /// Returns the Firebase document ID
  Future<String?> syncToCloud({
    required String collectionName,
    required Map<String, dynamic> data,
    String? documentId,
  }) async {
    try {
      if (currentUserId == null) {
        print('Cannot sync: User not authenticated');
        return null;
      }

      final collection = getUserCollection(collectionName);
      
      // Add metadata
      data['lastSyncedAt'] = FieldValue.serverTimestamp();
      data['updatedAt'] = FieldValue.serverTimestamp();

      if (documentId != null) {
        // Update existing document
        await collection.doc(documentId).set(data, SetOptions(merge: true));
        return documentId;
      } else {
        // Create new document
        data['createdAt'] = FieldValue.serverTimestamp();
        final docRef = await collection.add(data);
        return docRef.id;
      }
    } catch (e) {
      print('Sync error: $e');
      return null;
    }
  }

  /// Fetch single document from cloud
  Future<Map<String, dynamic>?> fetchFromCloud({
    required String collectionName,
    required String documentId,
  }) async {
    try {
      if (currentUserId == null) return null;

      final doc = await getUserCollection(collectionName)
          .doc(documentId)
          .get();

      if (!doc.exists) return null;

      return {
        ...doc.data() as Map<String, dynamic>,
        'firebaseId': doc.id,
      };
    } catch (e) {
      print('Fetch error: $e');
      return null;
    }
  }

  /// Fetch all documents from cloud for current user
  Future<List<Map<String, dynamic>>> fetchAllFromCloud({
    required String collectionName,
  }) async {
    try {
      if (currentUserId == null) return [];

      final snapshot = await getUserCollection(collectionName).get();

      return snapshot.docs.map((doc) {
        return {
          ...doc.data() as Map<String, dynamic>,
          'firebaseId': doc.id,
        };
      }).toList();
    } catch (e) {
      print('Fetch all error: $e');
      return [];
    }
  }

  /// Delete document from cloud
  Future<bool> deleteFromCloud({
    required String collectionName,
    required String documentId,
  }) async {
    try {
      if (currentUserId == null) return false;

      await getUserCollection(collectionName)
          .doc(documentId)
          .delete();
      return true;
    } catch (e) {
      print('Delete error: $e');
      return false;
    }
  }

  /// Batch sync multiple items
  Future<void> batchSync({
    required String collectionName,
    required List<Map<String, dynamic>> items,
  }) async {
    for (final item in items) {
      await syncToCloud(
        collectionName: collectionName,
        data: item,
        documentId: item['firebaseId'] as String?,
      );
    }
  }

  /// Listen to real-time changes (for future use)
  Stream<List<Map<String, dynamic>>> streamCollection({
    required String collectionName,
  }) {
    if (currentUserId == null) {
      return Stream.value([]);
    }

    return getUserCollection(collectionName).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          ...doc.data() as Map<String, dynamic>,
          'firebaseId': doc.id,
        };
      }).toList();
    });
  }
}
