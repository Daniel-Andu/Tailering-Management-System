import 'package:tailoring_system/core/database/app_sequence_repository.dart';
import 'package:tailoring_system/utils/database_helper.dart';

class StaffRepository {
  Future<List<Map<String, Object?>>> activeStaff() async {
    final db = await DatabaseHelper.instance.database;
    return db.query(
      'employees',
      where: 'is_active = 1',
      orderBy: 'full_name ASC',
    );
  }

  Future<int> createStaff({
    required String fullName,
    required String role,
    String? phone,
  }) async {
    final db = await DatabaseHelper.instance.database;
    final employeeCode = await AppSequenceRepository(db).nextCode(
      key: 'employee',
      prefix: 'EMP',
      includeDate: false,
    );
    final now = DateTime.now().toIso8601String();

    return db.insert('employees', {
      'employee_code': employeeCode,
      'full_name': fullName,
      'phone': phone,
      'role': role,
      'is_active': 1,
      'created_at': now,
      'updated_at': now,
    });
  }

  Future<int> deactivateStaff(int id) async {
    final db = await DatabaseHelper.instance.database;
    return db.update(
      'employees',
      {
        'is_active': 0,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
