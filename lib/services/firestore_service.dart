import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tailoring_system/services/firebase_service.dart';

/// Firestore CRUD operations service
class FirestoreService {
  final FirebaseService _firebase = FirebaseService();

  // Get Firestore instance
  FirebaseFirestore get _firestore => _firebase.firestore;

  // Get current user ID
  String? get _userId => _firebase.userId;

  /// Get collection reference for current user's shop
  CollectionReference _getCollection(String collectionName) {
    if (_userId == null) {
      throw Exception('User not authenticated');
    }
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('shop')
        .doc('default')
        .collection(collectionName);
  }

  // ==================== CUSTOMERS ====================

  /// Add customer to Firestore
  Future<String> addCustomer(Map<String, dynamic> data) async {
    final doc = await _getCollection('customers').add({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  /// Update customer in Firestore
  Future<void> updateCustomer(String firebaseId, Map<String, dynamic> data) async {
    await _getCollection('customers').doc(firebaseId).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Delete customer from Firestore
  Future<void> deleteCustomer(String firebaseId) async {
    await _getCollection('customers').doc(firebaseId).delete();
  }

  /// Get all customers
  Stream<QuerySnapshot> getCustomers() {
    return _getCollection('customers').orderBy('createdAt', descending: true).snapshots();
  }

  // ==================== ORDERS ====================

  /// Add order to Firestore
  Future<String> addOrder(Map<String, dynamic> data) async {
    final doc = await _getCollection('orders').add({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  /// Update order in Firestore
  Future<void> updateOrder(String firebaseId, Map<String, dynamic> data) async {
    await _getCollection('orders').doc(firebaseId).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Delete order from Firestore
  Future<void> deleteOrder(String firebaseId) async {
    await _getCollection('orders').doc(firebaseId).delete();
  }

  /// Get all orders
  Stream<QuerySnapshot> getOrders() {
    return _getCollection('orders').orderBy('createdAt', descending: true).snapshots();
  }

  // ==================== SYNC STATUS ====================

  /// Mark item as synced in local database
  Future<void> markAsSynced(String collection, String localId, String firebaseId) async {
    // This will be handled by your local database
    // Just a placeholder for sync tracking
  }
}
