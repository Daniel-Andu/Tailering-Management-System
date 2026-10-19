import 'package:sqflite/sqflite.dart';

/// Adds cloud sync fields to all tables
/// Run this migration to enable offline-first cloud sync
class SyncMigration {
  /// Add sync fields to customers table
  static Future<void> addSyncFieldsToCustomers(Database db) async {
    try {
      // Check if columns already exist
      final columns = await db.rawQuery('PRAGMA table_info(customers)');
      final columnNames = columns.map((col) => col['name'] as String).toList();

      if (!columnNames.contains('firebase_id')) {
        await db.execute('''
          ALTER TABLE customers ADD COLUMN firebase_id TEXT
        ''');
      }

      if (!columnNames.contains('last_synced_at')) {
        await db.execute('''
          ALTER TABLE customers ADD COLUMN last_synced_at TEXT
        ''');
      }

      if (!columnNames.contains('sync_status')) {
        await db.execute('''
          ALTER TABLE customers ADD COLUMN sync_status TEXT DEFAULT 'pending'
        ''');
      }

      print('✅ Sync fields added to customers table');
    } catch (e) {
      print('⚠️ Error adding sync fields to customers: $e');
    }
  }

  /// Add sync fields to orders table
  static Future<void> addSyncFieldsToOrders(Database db) async {
    try {
      final columns = await db.rawQuery('PRAGMA table_info(orders)');
      final columnNames = columns.map((col) => col['name'] as String).toList();

      if (!columnNames.contains('firebase_id')) {
        await db.execute('''
          ALTER TABLE orders ADD COLUMN firebase_id TEXT
        ''');
      }

      if (!columnNames.contains('last_synced_at')) {
        await db.execute('''
          ALTER TABLE orders ADD COLUMN last_synced_at TEXT
        ''');
      }

      if (!columnNames.contains('sync_status')) {
        await db.execute('''
          ALTER TABLE orders ADD COLUMN sync_status TEXT DEFAULT 'pending'
        ''');
      }

      print('✅ Sync fields added to orders table');
    } catch (e) {
      print('⚠️ Error adding sync fields to orders: $e');
    }
  }

  /// Add sync fields to payments table
  static Future<void> addSyncFieldsToPayments(Database db) async {
    try {
      final columns = await db.rawQuery('PRAGMA table_info(payments)');
      final columnNames = columns.map((col) => col['name'] as String).toList();

      if (!columnNames.contains('firebase_id')) {
        await db.execute('''
          ALTER TABLE payments ADD COLUMN firebase_id TEXT
        ''');
      }

      if (!columnNames.contains('last_synced_at')) {
        await db.execute('''
          ALTER TABLE payments ADD COLUMN last_synced_at TEXT
        ''');
      }

      if (!columnNames.contains('sync_status')) {
        await db.execute('''
          ALTER TABLE payments ADD COLUMN sync_status TEXT DEFAULT 'pending'
        ''');
      }

      print('✅ Sync fields added to payments table');
    } catch (e) {
      print('⚠️ Error adding sync fields to payments: $e');
    }
  }

  /// Add sync fields to expenses table
  static Future<void> addSyncFieldsToExpenses(Database db) async {
    try {
      final columns = await db.rawQuery('PRAGMA table_info(expenses)');
      final columnNames = columns.map((col) => col['name'] as String).toList();

      if (!columnNames.contains('firebase_id')) {
        await db.execute('''
          ALTER TABLE expenses ADD COLUMN firebase_id TEXT
        ''');
      }

      if (!columnNames.contains('last_synced_at')) {
        await db.execute('''
          ALTER TABLE expenses ADD COLUMN last_synced_at TEXT
        ''');
      }

      if (!columnNames.contains('sync_status')) {
        await db.execute('''
          ALTER TABLE expenses ADD COLUMN sync_status TEXT DEFAULT 'pending'
        ''');
      }

      print('✅ Sync fields added to expenses table');
    } catch (e) {
      print('⚠️ Error adding sync fields to expenses: $e');
    }
  }

  /// Run all migrations
  static Future<void> runAllMigrations(Database db) async {
    print('🔄 Running sync migrations...');
    await addSyncFieldsToCustomers(db);
    await addSyncFieldsToOrders(db);
    await addSyncFieldsToPayments(db);
    await addSyncFieldsToExpenses(db);
    print('✅ All sync migrations completed');
  }
}
