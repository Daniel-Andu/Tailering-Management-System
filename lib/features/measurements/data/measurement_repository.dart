import 'package:tailoring_system/utils/database_helper.dart';

class MeasurementRepository {
  Future<List<Map<String, Object?>>> clothTypes() async {
    final db = await DatabaseHelper.instance.database;
    return db.query(
      'cloth_types',
      where: 'is_active = 1',
      orderBy: 'sort_order ASC, default_name ASC',
    );
  }

  Future<List<Map<String, Object?>>> templatesForClothType(int clothTypeId) async {
    final db = await DatabaseHelper.instance.database;
    return db.query(
      'measurement_templates',
      where: 'cloth_type_id = ? AND is_active = 1',
      whereArgs: [clothTypeId],
      orderBy: 'is_default DESC, name ASC',
    );
  }

  Future<List<Map<String, Object?>>> fieldsForTemplate(int templateId) async {
    final db = await DatabaseHelper.instance.database;
    return db.query(
      'measurement_fields',
      where: 'template_id = ?',
      whereArgs: [templateId],
      orderBy: 'sort_order ASC, id ASC',
    );
  }

  Future<int> createTemplate({
    required int clothTypeId,
    required String name,
    required List<MeasurementFieldDraft> fields,
    bool isDefault = false,
  }) async {
    final db = await DatabaseHelper.instance.database;
    return db.transaction((txn) async {
      final now = DateTime.now().toIso8601String();
      final templateId = await txn.insert('measurement_templates', {
        'cloth_type_id': clothTypeId,
        'name': name,
        'is_default': isDefault ? 1 : 0,
        'is_active': 1,
        'created_at': now,
        'updated_at': now,
      });

      for (var index = 0; index < fields.length; index++) {
        final field = fields[index];
        await txn.insert('measurement_fields', {
          'template_id': templateId,
          'field_key': field.fieldKey,
          'label_key': field.labelKey,
          'input_type': field.inputType,
          'unit': field.unit,
          'is_required': field.isRequired ? 1 : 0,
          'sort_order': index,
          'min_value': field.minValue,
          'max_value': field.maxValue,
        });
      }

      return templateId;
    });
  }

  Future<int> saveCustomerMeasurement({
    required int customerId,
    required int templateId,
    required Map<int, Object?> valuesByFieldId,
    String? title,
    String? notes,
    int? measuredByStaffId,
  }) async {
    final db = await DatabaseHelper.instance.database;
    return db.transaction((txn) async {
      final measurementId = await txn.insert('customer_measurements', {
        'customer_id': customerId,
        'template_id': templateId,
        'title': title,
        'measured_by_staff_id': measuredByStaffId,
        'measured_at': DateTime.now().toIso8601String(),
        'notes': notes,
      });

      for (final entry in valuesByFieldId.entries) {
        final value = entry.value;
        await txn.insert('customer_measurement_values', {
          'measurement_id': measurementId,
          'field_id': entry.key,
          'value': value is num ? value.toDouble() : null,
          'text_value': value is num ? null : value?.toString(),
        });
      }

      return measurementId;
    });
  }

  Future<List<Map<String, Object?>>> measurementsForCustomer(int customerId) async {
    final db = await DatabaseHelper.instance.database;
    return db.rawQuery(
      '''
      SELECT cm.*, mt.name AS template_name, ct.default_name AS cloth_type_name
      FROM customer_measurements cm
      INNER JOIN measurement_templates mt ON mt.id = cm.template_id
      INNER JOIN cloth_types ct ON ct.id = mt.cloth_type_id
      WHERE cm.customer_id = ?
      ORDER BY cm.measured_at DESC
      ''',
      [customerId],
    );
  }
}

class MeasurementFieldDraft {
  const MeasurementFieldDraft({
    required this.fieldKey,
    required this.labelKey,
    this.inputType = 'number',
    this.unit = 'cm',
    this.isRequired = false,
    this.minValue,
    this.maxValue,
  });

  final String fieldKey;
  final String labelKey;
  final String inputType;
  final String unit;
  final bool isRequired;
  final double? minValue;
  final double? maxValue;
}
