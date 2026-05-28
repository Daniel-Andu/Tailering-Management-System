import 'package:tailoring_system/utils/database_helper.dart';

class CustomerProfileRepository {
  Future<CustomerProfileStats> stats(int customerId) async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.rawQuery(
      '''
      SELECT
        COUNT(o.id) AS total_orders,
        COALESCE(SUM(o.total_amount), 0) AS total_order_value,
        COALESCE(SUM(o.paid_amount), 0) AS total_paid,
        COALESCE(SUM(o.balance_amount), 0) AS total_balance,
        SUM(CASE WHEN o.status IN ('completed', 'delivered') THEN 1 ELSE 0 END) AS completed_orders,
        MAX(o.createdAt) AS last_order_at
      FROM orders o
      WHERE o.customerId = ? AND o.deleted_at IS NULL
      ''',
      [customerId],
    );

    final measurementRows = await db.rawQuery(
      '''
      SELECT COUNT(*) AS value
      FROM customer_measurements
      WHERE customer_id = ?
      ''',
      [customerId],
    );

    final row = rows.first;
    return CustomerProfileStats(
      totalOrders: (row['total_orders'] as num).toInt(),
      completedOrders: (row['completed_orders'] as num?)?.toInt() ?? 0,
      totalOrderValue: (row['total_order_value'] as num).toDouble(),
      totalPaid: (row['total_paid'] as num).toDouble(),
      totalBalance: (row['total_balance'] as num).toDouble(),
      measurementCount: (measurementRows.first['value'] as num).toInt(),
      lastOrderAt: row['last_order_at'] as String?,
    );
  }

  Future<List<Map<String, Object?>>> timeline(int customerId) async {
    final db = await DatabaseHelper.instance.database;
    return db.rawQuery(
      '''
      SELECT 'order' AS type, id AS entity_id, status AS title, createdAt AS occurred_at, notes
      FROM orders
      WHERE customerId = ? AND deleted_at IS NULL
      UNION ALL
      SELECT 'payment' AS type, id AS entity_id, payment_method AS title, paid_at AS occurred_at, notes
      FROM payments
      WHERE customer_id = ?
      UNION ALL
      SELECT 'measurement' AS type, id AS entity_id, title AS title, measured_at AS occurred_at, notes
      FROM customer_measurements
      WHERE customer_id = ?
      UNION ALL
      SELECT 'appointment' AS type, id AS entity_id, appointment_type AS title, scheduled_at AS occurred_at, notes
      FROM appointments
      WHERE customer_id = ?
      ORDER BY occurred_at DESC
      ''',
      [customerId, customerId, customerId, customerId],
    );
  }
}

class CustomerProfileStats {
  const CustomerProfileStats({
    required this.totalOrders,
    required this.completedOrders,
    required this.totalOrderValue,
    required this.totalPaid,
    required this.totalBalance,
    required this.measurementCount,
    this.lastOrderAt,
  });

  final int totalOrders;
  final int completedOrders;
  final double totalOrderValue;
  final double totalPaid;
  final double totalBalance;
  final int measurementCount;
  final String? lastOrderAt;
}
