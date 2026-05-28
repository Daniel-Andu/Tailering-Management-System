import 'package:tailoring_system/features/notifications/data/sms_gateway.dart';
import 'package:tailoring_system/utils/database_helper.dart';

class NotificationRepository {
  NotificationRepository({SmsGateway? smsGateway})
      : _smsGateway = smsGateway ?? DisabledSmsGateway();

  final SmsGateway _smsGateway;

  Future<List<Map<String, Object?>>> pendingNotifications(
      {int limit = 20}) async {
    final db = await DatabaseHelper.instance.database;
    return db.query(
      'notifications',
      where: 'status = ?',
      whereArgs: ['pending'],
      orderBy: 'created_at ASC',
      limit: limit,
    );
  }

  Future<int> queueSms({
    required String recipient,
    required String message,
    required String templateKey,
    String languageCode = 'am',
    int? customerId,
    int? orderId,
    DateTime? scheduledAt,
  }) async {
    final db = await DatabaseHelper.instance.database;
    return db.insert('notifications', {
      'customer_id': customerId,
      'order_id': orderId,
      'channel': 'sms',
      'recipient': recipient,
      'language_code': languageCode,
      'template_key': templateKey,
      'message': message,
      'status': 'pending',
      'scheduled_at': scheduledAt?.toIso8601String(),
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<int> processPendingSms({int limit = 20}) async {
    final db = await DatabaseHelper.instance.database;
    final pending = await pendingNotifications(limit: limit);
    var sentCount = 0;

    for (final notification in pending) {
      if (notification['channel'] != 'sms') continue;

      final id = notification['id'] as int;
      final result = await _smsGateway.send(
        SmsMessage(
          to: notification['recipient'] as String,
          message: notification['message'] as String,
          languageCode: notification['language_code'] as String? ?? 'am',
          reference: id.toString(),
        ),
      );

      await db.update(
        'notifications',
        {
          'status': result.success ? 'sent' : 'failed',
          'provider_message_id': result.providerMessageId,
          'error_message': result.errorMessage,
          'sent_at': result.success ? DateTime.now().toIso8601String() : null,
        },
        where: 'id = ?',
        whereArgs: [id],
      );

      if (result.success) sentCount++;
    }

    return sentCount;
  }

  Future<List<Map<String, Object?>>> notificationsForOrder(int orderId) async {
    final db = await DatabaseHelper.instance.database;
    return db.query(
      'notifications',
      where: 'order_id = ?',
      whereArgs: [orderId],
      orderBy: 'created_at DESC',
    );
  }

  Future<int> createNotification({
    required String type,
    required String title,
    required String message,
    required int entityId,
  }) async {
    final db = await DatabaseHelper.instance.database;
    return db.insert('notifications', {
      'order_id': entityId,
      'channel': 'app',
      'type': type,
      'title': title,
      'message': message,
      'status': 'pending',
      'created_at': DateTime.now().toIso8601String(),
    });
  }
}
