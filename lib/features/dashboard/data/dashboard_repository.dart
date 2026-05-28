import 'package:tailoring_system/core/domain/order_status.dart';
import 'package:tailoring_system/utils/database_helper.dart';

class DashboardRepository {
  Future<DashboardSummary> loadSummary() async {
    final db = await DatabaseHelper.instance.database;
    final today = DateTime.now();
    final todayDate = _dateOnly(today);
    final monthPrefix = '${today.year.toString().padLeft(4, '0')}-'
        '${today.month.toString().padLeft(2, '0')}';

    final dueToday = await _count(
      '''
      SELECT COUNT(*) AS value
      FROM orders
      WHERE deleted_at IS NULL
        AND COALESCE(expected_delivery_date, deliveryDate) LIKE ?
        AND status NOT IN (?, ?, ?)
      ''',
      ['$todayDate%', OrderStatuses.delivered, OrderStatuses.completed, OrderStatuses.cancelled],
    );

    final delayed = await _count(
      '''
      SELECT COUNT(*) AS value
      FROM orders
      WHERE deleted_at IS NULL
        AND COALESCE(expected_delivery_date, deliveryDate) < ?
        AND status NOT IN (?, ?, ?)
      ''',
      [todayDate, OrderStatuses.delivered, OrderStatuses.completed, OrderStatuses.cancelled],
    );

    final readyForPickup = await _count(
      'SELECT COUNT(*) AS value FROM orders WHERE deleted_at IS NULL AND status = ?',
      [OrderStatuses.readyForPickup],
    );

    final openOrders = await _count(
      '''
      SELECT COUNT(*) AS value
      FROM orders
      WHERE deleted_at IS NULL
        AND status NOT IN (?, ?, ?)
      ''',
      [OrderStatuses.delivered, OrderStatuses.completed, OrderStatuses.cancelled],
    );

    final customers = await _count(
      'SELECT COUNT(*) AS value FROM customers WHERE COALESCE(is_active, 1) = 1',
      [],
    );

    final unpaidBalance = await _sum(
      '''
      SELECT COALESCE(SUM(balance_amount), 0) AS value
      FROM orders
      WHERE deleted_at IS NULL AND balance_amount > 0
      ''',
      [],
    );

    final todayPayments = await _sum(
      'SELECT COALESCE(SUM(amount), 0) AS value FROM payments WHERE paid_at LIKE ?',
      ['$todayDate%'],
    );

    final monthPayments = await _sum(
      'SELECT COALESCE(SUM(amount), 0) AS value FROM payments WHERE paid_at LIKE ?',
      ['$monthPrefix%'],
    );

    return DashboardSummary(
      dueToday: dueToday,
      delayedOrders: delayed,
      readyForPickup: readyForPickup,
      openOrders: openOrders,
      activeCustomers: customers,
      unpaidBalance: unpaidBalance,
      todayPayments: todayPayments,
      monthPayments: monthPayments,
    );
  }

  Future<List<Map<String, Object?>>> dueSoonOrders({int limit = 10}) async {
    final db = await DatabaseHelper.instance.database;
    return db.rawQuery(
      '''
      SELECT o.*, c.name AS customer_name, c.phone AS customer_phone
      FROM orders o
      LEFT JOIN customers c ON c.id = o.customerId
      WHERE o.deleted_at IS NULL
        AND o.status NOT IN (?, ?, ?)
      ORDER BY COALESCE(o.expected_delivery_date, o.deliveryDate) ASC
      LIMIT ?
      ''',
      [OrderStatuses.delivered, OrderStatuses.completed, OrderStatuses.cancelled, limit],
    );
  }

  Future<List<Map<String, Object?>>> unpaidOrders({int limit = 10}) async {
    final db = await DatabaseHelper.instance.database;
    return db.rawQuery(
      '''
      SELECT o.*, c.name AS customer_name, c.phone AS customer_phone
      FROM orders o
      LEFT JOIN customers c ON c.id = o.customerId
      WHERE o.deleted_at IS NULL AND o.balance_amount > 0
      ORDER BY o.balance_amount DESC
      LIMIT ?
      ''',
      [limit],
    );
  }

  Future<int> _count(String sql, List<Object?> args) async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.rawQuery(sql, args);
    return (rows.first['value'] as num).toInt();
  }

  Future<double> _sum(String sql, List<Object?> args) async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.rawQuery(sql, args);
    return (rows.first['value'] as num).toDouble();
  }

  String _dateOnly(DateTime value) {
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}

class DashboardSummary {
  const DashboardSummary({
    required this.dueToday,
    required this.delayedOrders,
    required this.readyForPickup,
    required this.openOrders,
    required this.activeCustomers,
    required this.unpaidBalance,
    required this.todayPayments,
    required this.monthPayments,
  });

  final int dueToday;
  final int delayedOrders;
  final int readyForPickup;
  final int openOrders;
  final int activeCustomers;
  final double unpaidBalance;
  final double todayPayments;
  final double monthPayments;
}
