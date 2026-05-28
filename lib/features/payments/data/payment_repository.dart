import 'package:tailoring_system/core/database/app_sequence_repository.dart';
import 'package:tailoring_system/core/domain/payment_method.dart';
import 'package:tailoring_system/utils/database_helper.dart';

class PaymentRepository {
  Future<int> recordPayment({
    required int orderId,
    required int customerId,
    required double amount,
    required String paymentMethod,
    String paymentType = PaymentTypes.partial,
    String? transactionReference,
    String? notes,
    int? employeeId,
  }) async {
    final db = await DatabaseHelper.instance.database;
    return db.transaction((txn) async {
      final sequence = AppSequenceRepository(txn);
      final paymentNumber = await sequence.nextCode(
        key: 'payment',
        prefix: 'PAY',
      );
      final receiptNumber = await sequence.nextCode(
        key: 'receipt',
        prefix: 'RCT',
      );
      final now = DateTime.now().toIso8601String();

      final paymentId = await txn.insert('payments', {
        'payment_number': paymentNumber,
        'order_id': orderId,
        'customer_id': customerId,
        'amount': amount,
        'payment_method': paymentMethod,
        'payment_type': paymentType,
        'transaction_reference': transactionReference,
        'receipt_number': receiptNumber,
        'notes': notes,
        'paid_at': now,
        'created_by_employee_id': employeeId,
      });

      await _refreshOrderBalance(txn, orderId);
      return paymentId;
    });
  }

  Future<void> recordRefund({
    required int paymentId,
    required double amount,
    String? reason,
  }) async {
    final db = await DatabaseHelper.instance.database;
    await db.transaction((txn) async {
      final paymentRows = await txn.query(
        'payments',
        columns: ['order_id'],
        where: 'id = ?',
        whereArgs: [paymentId],
        limit: 1,
      );
      if (paymentRows.isEmpty) {
        throw StateError('Payment $paymentId was not found');
      }

      final orderId = paymentRows.first['order_id'] as int;
      await txn.insert('refunds', {
        'payment_id': paymentId,
        'amount': amount,
        'reason': reason,
        'refunded_at': DateTime.now().toIso8601String(),
      });
      await _refreshOrderBalance(txn, orderId);
    });
  }

  Future<List<Map<String, Object?>>> paymentsForOrder(int orderId) async {
    final db = await DatabaseHelper.instance.database;
    return db.query(
      'payments',
      where: 'order_id = ?',
      whereArgs: [orderId],
      orderBy: 'paid_at DESC',
    );
  }

  Future<void> _refreshOrderBalance(dynamic txn, int orderId) async {
    final orderRows = await txn.query(
      'orders',
      columns: ['total_amount', 'price'],
      where: 'id = ?',
      whereArgs: [orderId],
      limit: 1,
    );
    if (orderRows.isEmpty) return;

    final order = orderRows.first;
    final total = ((order['total_amount'] as num?)?.toDouble() ?? 0) > 0
        ? (order['total_amount'] as num).toDouble()
        : ((order['price'] as num?)?.toDouble() ?? 0);

    final paymentRows = await txn.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) AS total FROM payments WHERE order_id = ?',
      [orderId],
    );
    final refundRows = await txn.rawQuery(
      '''
      SELECT COALESCE(SUM(r.amount), 0) AS total
      FROM refunds r
      INNER JOIN payments p ON p.id = r.payment_id
      WHERE p.order_id = ?
      ''',
      [orderId],
    );

    final paid = (paymentRows.first['total'] as num).toDouble();
    final refunded = (refundRows.first['total'] as num).toDouble();
    final netPaid = paid - refunded;
    final balance = total - netPaid;

    await txn.update(
      'orders',
      {
        'total_amount': total,
        'paid_amount': netPaid,
        'balance_amount': balance,
        'paymentStatus': balance <= 0 ? 'paid' : netPaid > 0 ? 'partial' : 'unpaid',
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [orderId],
    );
  }
}
