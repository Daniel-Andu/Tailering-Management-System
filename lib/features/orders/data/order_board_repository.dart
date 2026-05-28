import 'package:tailoring_system/core/database/app_sequence_repository.dart';
import 'package:tailoring_system/core/domain/order_status.dart';
import 'package:tailoring_system/utils/database_helper.dart';

class OrderBoardRepository {
  Future<List<Map<String, Object?>>> orders({
    String? status,
    String? query,
  }) async {
    final db = await DatabaseHelper.instance.database;
    final where = <String>['o.deleted_at IS NULL'];
    final args = <Object?>[];

    if (status != null && status.isNotEmpty) {
      where.add('o.status = ?');
      args.add(status);
    }

    if (query != null && query.trim().isNotEmpty) {
      final like = '%${query.trim()}%';
      where.add('''
        (
          o.order_number LIKE ?
          OR o.clothType LIKE ?
          OR c.name LIKE ?
          OR c.phone LIKE ?
          OR c.customer_code LIKE ?
        )
      ''');
      args.addAll([like, like, like, like, like]);
    }

    return db.rawQuery(
      '''
      SELECT o.*, c.name AS customer_name, c.phone AS customer_phone
      FROM orders o
      LEFT JOIN customers c ON c.id = o.customerId
      WHERE ${where.join(' AND ')}
      ORDER BY o.createdAt DESC
      LIMIT 200
      ''',
      args,
    );
  }

  Future<int> createOrder({
    required int customerId,
    required String clothType,
    required double price,
    required DateTime deliveryDate,
    String status = OrderStatuses.confirmed,
    String priority = OrderPriorities.normal,
    String urgencyLevel = OrderUrgencyLevels.normal,
    DateTime? fittingDate,
    int? assignedStaffId,
    String? notes,
    String? gender,
    double? chest,
    double? shoulder,
    double? hip,
    double? breast,
    double? waist,
    double? length,
    double? sleeve,
    double? neck,
    String? clothPhoto,
  }) async {
    final db = await DatabaseHelper.instance.database;
    return db.transaction((txn) async {
      final sequence = AppSequenceRepository(txn);
      final orderNumber = await sequence.nextCode(key: 'order', prefix: 'ORD');
      final now = DateTime.now().toIso8601String();

      final orderId = await txn.insert('orders', {
        'order_number': orderNumber,
        'customerId': customerId,
        'clothType': clothType,
        'price': price,
        'deliveryDate': deliveryDate.toIso8601String(),
        'status': status,
        'priority': priority,
        'urgency_level': urgencyLevel,
        'expected_delivery_date': deliveryDate.toIso8601String(),
        'fitting_date': fittingDate?.toIso8601String(),
        'assigned_staff_id': assignedStaffId,
        'subtotal': price,
        'discount_amount': 0,
        'tax_amount': 0,
        'total_amount': price,
        'paid_amount': 0,
        'balance_amount': price,
        'notes': notes,
        'createdAt': now,
        'updated_at': now,
        'paymentStatus': 'unpaid',
        'gender': gender,
        'chest': chest,
        'shoulder': shoulder,
        'hip': hip,
        'breast': breast,
        'waist': waist,
        'length': length,
        'sleeve': sleeve,
        'neck': neck,
        'cloth_photo': clothPhoto,
      });

      await txn.insert('order_items', {
        'order_id': orderId,
        'item_name': clothType,
        'quantity': 1,
        'unit_price': price,
        'total_price': price,
        'notes': notes,
        'created_at': now,
      });

      await txn.insert('order_status_history', {
        'order_id': orderId,
        'old_status': null,
        'new_status': status,
        'changed_at': now,
        'notes': 'Order created',
      });

      return orderId;
    });
  }
}
