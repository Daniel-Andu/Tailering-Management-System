import 'package:tailoring_system/utils/database_helper.dart';

class FinancialReportRepository {
  Future<FinancialSummary> summaryForRange({
    required DateTime start,
    required DateTime end,
  }) async {
    final db = await DatabaseHelper.instance.database;
    final startText = start.toIso8601String();
    final endText = end.toIso8601String();

    final payments = await db.rawQuery(
      '''
      SELECT COALESCE(SUM(amount), 0) AS value
      FROM payments
      WHERE paid_at >= ? AND paid_at <= ?
      ''',
      [startText, endText],
    );

    final refunds = await db.rawQuery(
      '''
      SELECT COALESCE(SUM(amount), 0) AS value
      FROM refunds
      WHERE refunded_at >= ? AND refunded_at <= ?
      ''',
      [startText, endText],
    );

    final expenses = await db.rawQuery(
      '''
      SELECT COALESCE(SUM(amount), 0) AS value
      FROM expenses
      WHERE expense_date >= ? AND expense_date <= ?
      ''',
      [startText, endText],
    );

    final orders = await db.rawQuery(
      '''
      SELECT COUNT(*) AS count, COALESCE(SUM(total_amount), 0) AS value
      FROM orders
      WHERE createdAt >= ? AND createdAt <= ? AND deleted_at IS NULL
      ''',
      [startText, endText],
    );

    final revenue = (payments.first['value'] as num).toDouble();
    final refunded = (refunds.first['value'] as num).toDouble();
    final expenseTotal = (expenses.first['value'] as num).toDouble();
    final orderCount = (orders.first['count'] as num).toInt();
    final orderValue = (orders.first['value'] as num).toDouble();

    return FinancialSummary(
      grossPayments: revenue,
      refunds: refunded,
      expenses: expenseTotal,
      netCash: revenue - refunded - expenseTotal,
      orderCount: orderCount,
      orderValue: orderValue,
    );
  }

  Future<List<Map<String, Object?>>> paymentsByMethod({
    required DateTime start,
    required DateTime end,
  }) async {
    final db = await DatabaseHelper.instance.database;
    return db.rawQuery(
      '''
      SELECT payment_method, COUNT(*) AS count, COALESCE(SUM(amount), 0) AS total
      FROM payments
      WHERE paid_at >= ? AND paid_at <= ?
      GROUP BY payment_method
      ORDER BY total DESC
      ''',
      [start.toIso8601String(), end.toIso8601String()],
    );
  }

  Future<List<Map<String, Object?>>> unpaidBalances() async {
    final db = await DatabaseHelper.instance.database;
    return db.rawQuery(
      '''
      SELECT o.id, o.order_number, o.balance_amount, o.expected_delivery_date,
             c.name AS customer_name, c.phone AS customer_phone
      FROM orders o
      LEFT JOIN customers c ON c.id = o.customerId
      WHERE o.deleted_at IS NULL AND o.balance_amount > 0
      ORDER BY o.balance_amount DESC
      ''',
    );
  }
}

class FinancialSummary {
  const FinancialSummary({
    required this.grossPayments,
    required this.refunds,
    required this.expenses,
    required this.netCash,
    required this.orderCount,
    required this.orderValue,
  });

  final double grossPayments;
  final double refunds;
  final double expenses;
  final double netCash;
  final int orderCount;
  final double orderValue;
}
