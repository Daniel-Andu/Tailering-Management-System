import 'package:tailoring_system/core/domain/order_status.dart';
import 'package:tailoring_system/utils/database_helper.dart';

class OrderWorkflowRepository {
  Future<void> changeStatus({
    required int orderId,
    required String newStatus,
    int? employeeId,
    String? notes,
    bool queueCustomerNotification = true,
  }) async {
    final db = await DatabaseHelper.instance.database;
    await db.transaction((txn) async {
      final rows = await txn.query(
        'orders',
        where: 'id = ?',
        whereArgs: [orderId],
        limit: 1,
      );
      if (rows.isEmpty) {
        throw StateError('Order $orderId was not found');
      }

      final order = rows.first;
      final oldStatus = order['status'] as String?;
      final now = DateTime.now().toIso8601String();

      await txn.update(
        'orders',
        {
          'status': newStatus,
          'updated_at': now,
          if (newStatus == OrderStatuses.delivered) 'actual_delivery_date': now,
        },
        where: 'id = ?',
        whereArgs: [orderId],
      );

      await txn.insert('order_status_history', {
        'order_id': orderId,
        'old_status': oldStatus,
        'new_status': newStatus,
        'changed_by_employee_id': employeeId,
        'changed_at': now,
        'notes': notes,
      });

      if (queueCustomerNotification && _shouldNotify(newStatus)) {
        await _queueStatusNotification(txn, order, newStatus, now);
      }
    });
  }

  Future<List<Map<String, Object?>>> statusHistory(int orderId) async {
    final db = await DatabaseHelper.instance.database;
    return db.query(
      'order_status_history',
      where: 'order_id = ?',
      whereArgs: [orderId],
      orderBy: 'changed_at DESC',
    );
  }

  bool _shouldNotify(String status) {
    return status == OrderStatuses.readyForPickup ||
        status == OrderStatuses.completed ||
        status == OrderStatuses.delayed;
  }

  Future<void> _queueStatusNotification(
    dynamic txn,
    Map<String, Object?> order,
    String status,
    String now,
  ) async {
    final customerId = order['customerId'] as int?;
    if (customerId == null) return;

    final customers = await txn.query(
      'customers',
      where: 'id = ?',
      whereArgs: [customerId],
      limit: 1,
    );
    if (customers.isEmpty) return;

    final customer = customers.first;
    final phone = customer['phone'] as String?;
    if (phone == null || phone.trim().isEmpty) return;

    final languageCode = (customer['preferred_language'] as String?) ?? 'am';
    final orderNumber = (order['order_number'] as String?) ?? order['id'].toString();
    final customerName = (customer['full_name'] as String?) ??
        (customer['name'] as String?) ??
        '';
    final balance = ((order['balance_amount'] as num?)?.toDouble() ?? 0).toStringAsFixed(2);
    final templateKey = 'order.status.$status';

    await txn.insert('notifications', {
      'customer_id': customerId,
      'order_id': order['id'],
      'channel': 'sms',
      'recipient': phone,
      'language_code': languageCode,
      'template_key': templateKey,
      'message': _messageForStatus(
        status: status,
        languageCode: languageCode,
        customerName: customerName,
        orderNumber: orderNumber,
        balance: balance,
      ),
      'status': 'pending',
      'created_at': now,
    });
  }

  String _messageForStatus({
    required String status,
    required String languageCode,
    required String customerName,
    required String orderNumber,
    required String balance,
  }) {
    if (languageCode == 'am') {
      if (status == OrderStatuses.readyForPickup) {
        return 'ሰላም $customerName, ትዕዛዝዎ $orderNumber ለመውሰድ ዝግጁ ሆኗል። ቀሪ ክፍያ፦ $balance ብር።';
      }
      if (status == OrderStatuses.delayed) {
        return 'ሰላም $customerName, ትዕዛዝዎ $orderNumber ዘግይቷል። ለተጨማሪ መረጃ ሱቁን ያግኙ።';
      }
      return 'ሰላም $customerName, ትዕዛዝዎ $orderNumber ተጠናቋል።';
    }

    if (status == OrderStatuses.readyForPickup) {
      return 'Hello $customerName, your order $orderNumber is ready for pickup. Balance: $balance ETB.';
    }
    if (status == OrderStatuses.delayed) {
      return 'Hello $customerName, your order $orderNumber is delayed. Please contact the shop for details.';
    }
    return 'Hello $customerName, your order $orderNumber is completed.';
  }
}
