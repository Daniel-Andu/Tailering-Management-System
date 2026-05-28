import 'package:tailoring_system/utils/database_helper.dart';

class OrderDetailRepository {
  Future<Map<String, Object?>?> orderDetail(int orderId) async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.rawQuery(
      '''
      SELECT o.*, c.name AS customer_name, c.phone AS customer_phone,
             c.customer_code, c.preferred_language
      FROM orders o
      LEFT JOIN customers c ON c.id = o.customerId
      WHERE o.id = ?
      LIMIT 1
      ''',
      [orderId],
    );
    return rows.isEmpty ? null : rows.first;
  }

  Future<List<Map<String, Object?>>> orderItems(int orderId) async {
    final db = await DatabaseHelper.instance.database;
    return db.query(
      'order_items',
      where: 'order_id = ?',
      whereArgs: [orderId],
      orderBy: 'id ASC',
    );
  }

  Future<List<Map<String, Object?>>> statusHistory(int orderId) async {
    final db = await DatabaseHelper.instance.database;
    return db.rawQuery(
      '''
      SELECT h.*, e.full_name AS employee_name
      FROM order_status_history h
      LEFT JOIN employees e ON e.id = h.changed_by_employee_id
      WHERE h.order_id = ?
      ORDER BY h.changed_at DESC
      ''',
      [orderId],
    );
  }

  Future<List<Map<String, Object?>>> payments(int orderId) async {
    final db = await DatabaseHelper.instance.database;
    return db.query(
      'payments',
      where: 'order_id = ?',
      whereArgs: [orderId],
      orderBy: 'paid_at DESC',
    );
  }

  Future<List<Map<String, Object?>>> notifications(int orderId) async {
    final db = await DatabaseHelper.instance.database;
    return db.query(
      'notifications',
      where: 'order_id = ?',
      whereArgs: [orderId],
      orderBy: 'created_at DESC',
    );
  }

  Future<List<Map<String, Object?>>> appointments(int orderId) async {
    final db = await DatabaseHelper.instance.database;
    return db.query(
      'appointments',
      where: 'order_id = ?',
      whereArgs: [orderId],
      orderBy: 'scheduled_at DESC',
    );
  }
}
