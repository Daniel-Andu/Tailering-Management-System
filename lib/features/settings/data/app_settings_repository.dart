import 'package:sqflite/sqflite.dart';
import 'package:tailoring_system/utils/database_helper.dart';

class AppSettingsRepository {
  Future<Map<String, String?>> loadAll() async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query('app_settings');
    return {
      for (final row in rows) row['key'] as String: row['value'] as String?,
    };
  }

  Future<void> save(String key, String? value) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert(
      'app_settings',
      {
        'key': key,
        'value': value,
        'updated_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> saveShopProfile({
    required String shopName,
    String? phone,
    String? address,
    String? receiptFooter,
  }) async {
    await save('shop.name', shopName);
    await save('shop.phone', phone);
    await save('shop.address', address);
    await save('receipt.footer', receiptFooter);
  }
}
