import 'package:tailoring_system/core/database/app_sequence_repository.dart';
import 'package:tailoring_system/utils/database_helper.dart';

class CustomerDirectoryRepository {
  Future<List<Map<String, Object?>>> searchCustomers(String query) async {
    final db = await DatabaseHelper.instance.database;
    final like = '%${query.trim()}%';
    if (query.trim().isEmpty) {
      return db.query(
        'customers',
        where: 'COALESCE(is_active, 1) = 1',
        orderBy: 'date DESC',
        limit: 100,
      );
    }

    return db.query(
      'customers',
      where: '''
        COALESCE(is_active, 1) = 1 AND (
          customerId LIKE ?
          OR customer_code LIKE ?
          OR name LIKE ?
          OR full_name LIKE ?
          OR businessName LIKE ?
          OR phone LIKE ?
          OR secondary_phone LIKE ?
          OR email LIKE ?
          OR address LIKE ?
        )
      ''',
      whereArgs: [like, like, like, like, like, like, like, like, like],
      orderBy: 'date DESC',
      limit: 100,
    );
  }

  Future<int> createCustomer({
    required String fullName,
    required String phone,
    String? businessName,
    String? gender,
    String? secondaryPhone,
    String? email,
    String? address,
    String category = 'regular',
    String preferredLanguage = 'am',
    String? notes,
  }) async {
    final db = await DatabaseHelper.instance.database;
    final customerCode = await AppSequenceRepository(db).nextCode(
      key: 'customer',
      prefix: 'CUS',
    );
    final now = DateTime.now().toIso8601String();

    return db.insert('customers', {
      'customerId': customerCode,
      'customer_code': customerCode,
      'name': fullName,
      'full_name': fullName,
      'businessName': businessName,
      'gender': gender,
      'phone': phone,
      'secondary_phone': secondaryPhone,
      'email': email,
      'address': address,
      'category': category,
      'preferred_language': preferredLanguage,
      'date': now,
      'updated_at': now,
      'is_active': 1,
      'notes': notes,
    });
  }

  Future<void> updateCustomer({
    required int customerId,
    required String fullName,
    required String phone,
    String? businessName,
    String? address,
    String category = 'regular',
    String preferredLanguage = 'am',
    String? notes,
  }) async {
    final db = await DatabaseHelper.instance.database;
    final now = DateTime.now().toIso8601String();

    await db.update(
      'customers',
      {
        'name': fullName,
        'full_name': fullName,
        'businessName': businessName,
        'phone': phone,
        'address': address,
        'category': category,
        'preferred_language': preferredLanguage,
        'notes': notes,
        'updated_at': now,
      },
      where: 'id = ?',
      whereArgs: [customerId],
    );
  }
}
