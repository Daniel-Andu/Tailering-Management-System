import 'package:tailoring_system/utils/database_helper.dart';

class AppointmentRepository {
  Future<int> createAppointment({
    required int customerId,
    required DateTime scheduledAt,
    required String appointmentType,
    int? orderId,
    String? notes,
  }) async {
    final db = await DatabaseHelper.instance.database;
    return db.insert('appointments', {
      'customer_id': customerId,
      'order_id': orderId,
      'appointment_type': appointmentType,
      'scheduled_at': scheduledAt.toIso8601String(),
      'status': 'scheduled',
      'notes': notes,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, Object?>>> appointmentsForDay(DateTime day) async {
    final db = await DatabaseHelper.instance.database;
    final start = DateTime(day.year, day.month, day.day).toIso8601String();
    final end = DateTime(day.year, day.month, day.day, 23, 59, 59).toIso8601String();
    return db.rawQuery(
      '''
      SELECT a.*, c.name AS customer_name, c.phone AS customer_phone, o.order_number
      FROM appointments a
      INNER JOIN customers c ON c.id = a.customer_id
      LEFT JOIN orders o ON o.id = a.order_id
      WHERE a.scheduled_at >= ? AND a.scheduled_at <= ?
      ORDER BY a.scheduled_at ASC
      ''',
      [start, end],
    );
  }

  Future<int> updateStatus({
    required int appointmentId,
    required String status,
  }) async {
    final db = await DatabaseHelper.instance.database;
    return db.update(
      'appointments',
      {'status': status},
      where: 'id = ?',
      whereArgs: [appointmentId],
    );
  }
}
