import 'package:sqflite/sqflite.dart';
import 'package:tailoring_system/services/sync_service.dart';
import 'package:tailoring_system/utils/database_helper.dart';

/// Customer-specific sync service
/// Handles offline-first sync between SQLite and Firestore
class CustomerSyncService {
  final SyncService _syncService = SyncService();
  final DatabaseHelper _db = DatabaseHelper.instance;

  static const String collectionName = 'customers';

  /// Sync a single customer to cloud
  /// Updates the local database with Firebase ID and sync status
  Future<bool> syncCustomerToCloud(Map<String, dynamic> customer) async {
    try {
      final localId = customer['id'] as int;
      final firebaseId = customer['firebase_id'] as String?;

      // Prepare data for cloud (remove SQLite-specific fields)
      final cloudData = Map<String, dynamic>.from(customer);
      cloudData.remove('id'); // Don't sync SQLite auto-increment ID
      cloudData.remove('firebase_id');
      cloudData.remove('last_synced_at');
      cloudData.remove('sync_status');

      // Sync to cloud
      final resultFirebaseId = await _syncService.syncToCloud(
        collectionName: collectionName,
        data: cloudData,
        documentId: firebaseId,
      );

      if (resultFirebaseId != null) {
        // Update local database with Firebase ID and sync status
        final db = await _db.database;
        await db.update(
          'customers',
          {
            'firebase_id': resultFirebaseId,
            'last_synced_at': DateTime.now().toIso8601String(),
            'sync_status': 'synced',
          },
          where: 'id = ?',
          whereArgs: [localId],
        );
        print('✅ Customer $localId synced to cloud with ID: $resultFirebaseId');
        return true;
      }

      return false;
    } catch (e) {
      print('❌ Error syncing customer to cloud: $e');
      
      // Update sync status to error
      try {
        final db = await _db.database;
        await db.update(
          'customers',
          {'sync_status': 'error'},
          where: 'id = ?',
          whereArgs: [customer['id']],
        );
      } catch (_) {}
      
      return false;
    }
  }

  /// Sync all pending customers to cloud
  Future<int> syncAllPendingCustomers() async {
    try {
      final db = await _db.database;
      
      // Get all customers with pending or error status
      final customers = await db.query(
        'customers',
        where: 'sync_status IN (?, ?) AND deleted_at IS NULL',
        whereArgs: ['pending', 'error'],
      );

      int successCount = 0;
      for (final customer in customers) {
        final success = await syncCustomerToCloud(customer);
        if (success) successCount++;
      }

      print('✅ Synced $successCount out of ${customers.length} customers');
      return successCount;
    } catch (e) {
      print('❌ Error syncing pending customers: $e');
      return 0;
    }
  }

  /// Pull customers from cloud and update local database
  Future<int> pullCustomersFromCloud() async {
    try {
      final cloudCustomers = await _syncService.fetchAllFromCloud(
        collectionName: collectionName,
      );

      final db = await _db.database;
      int updatedCount = 0;

      for (final cloudCustomer in cloudCustomers) {
        final firebaseId = cloudCustomer['firebaseId'] as String;
        
        // Check if customer exists locally
        final existing = await db.query(
          'customers',
          where: 'firebase_id = ?',
          whereArgs: [firebaseId],
        );

        final customerData = Map<String, dynamic>.from(cloudCustomer);
        customerData.remove('firebaseId');
        customerData['firebase_id'] = firebaseId;
        customerData['sync_status'] = 'synced';
        customerData['last_synced_at'] = DateTime.now().toIso8601String();

        if (existing.isEmpty) {
          // Insert new customer
          await db.insert('customers', customerData);
          updatedCount++;
        } else {
          // Update existing customer (only if cloud version is newer)
          final localUpdatedAt = existing.first['updated_at'] as String?;
          final cloudUpdatedAt = customerData['updated_at'] as String?;

          if (cloudUpdatedAt != null && 
              (localUpdatedAt == null || 
               DateTime.parse(cloudUpdatedAt).isAfter(DateTime.parse(localUpdatedAt)))) {
            await db.update(
              'customers',
              customerData,
              where: 'firebase_id = ?',
              whereArgs: [firebaseId],
            );
            updatedCount++;
          }
        }
      }

      print('✅ Pulled and updated $updatedCount customers from cloud');
      return updatedCount;
    } catch (e) {
      print('❌ Error pulling customers from cloud: $e');
      return 0;
    }
  }

  /// Full bidirectional sync
  /// 1. Push local changes to cloud
  /// 2. Pull cloud changes to local
  Future<Map<String, int>> fullSync() async {
    print('🔄 Starting full customer sync...');
    
    final pushed = await syncAllPendingCustomers();
    final pulled = await pullCustomersFromCloud();

    print('✅ Full sync complete: Pushed $pushed, Pulled $pulled');
    
    return {
      'pushed': pushed,
      'pulled': pulled,
    };
  }

  /// Get sync statistics
  Future<Map<String, int>> getSyncStats() async {
    try {
      final db = await _db.database;
      
      final total = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM customers WHERE deleted_at IS NULL'),
      ) ?? 0;
      
      final synced = Sqflite.firstIntValue(
        await db.rawQuery(
          "SELECT COUNT(*) FROM customers WHERE sync_status = 'synced' AND deleted_at IS NULL",
        ),
      ) ?? 0;
      
      final pending = Sqflite.firstIntValue(
        await db.rawQuery(
          "SELECT COUNT(*) FROM customers WHERE sync_status = 'pending' AND deleted_at IS NULL",
        ),
      ) ?? 0;
      
      final error = Sqflite.firstIntValue(
        await db.rawQuery(
          "SELECT COUNT(*) FROM customers WHERE sync_status = 'error' AND deleted_at IS NULL",
        ),
      ) ?? 0;

      return {
        'total': total,
        'synced': synced,
        'pending': pending,
        'error': error,
      };
    } catch (e) {
      print('❌ Error getting sync stats: $e');
      return {
        'total': 0,
        'synced': 0,
        'pending': 0,
        'error': 0,
      };
    }
  }

  /// Mark customer as pending sync after local changes
  Future<void> markAsPending(int customerId) async {
    try {
      final db = await _db.database;
      await db.update(
        'customers',
        {
          'sync_status': 'pending',
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [customerId],
      );
    } catch (e) {
      print('❌ Error marking customer as pending: $e');
    }
  }

  /// Delete customer from cloud (soft delete)
  Future<bool> deleteCustomerFromCloud(String firebaseId) async {
    try {
      return await _syncService.deleteFromCloud(
        collectionName: collectionName,
        documentId: firebaseId,
      );
    } catch (e) {
      print('❌ Error deleting customer from cloud: $e');
      return false;
    }
  }
}
