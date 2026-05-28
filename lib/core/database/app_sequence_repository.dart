import 'package:sqflite/sqflite.dart';

class AppSequenceRepository {
  AppSequenceRepository(this._db);

  final DatabaseExecutor _db;

  Future<String> nextCode({
    required String key,
    required String prefix,
    bool includeDate = true,
    int padding = 5,
  }) async {
    final now = DateTime.now();
    final datePart = _compactDate(now);
    final sequenceKey = includeDate ? '$key.$datePart' : key;
    final rows = await _db.query(
      'app_sequences',
      columns: ['current_value'],
      where: 'key = ?',
      whereArgs: [sequenceKey],
      limit: 1,
    );

    final current = rows.isEmpty ? 0 : rows.first['current_value'] as int;
    final next = current + 1;
    final updatedAt = now.toIso8601String();

    await _db.insert(
      'app_sequences',
      {
        'key': sequenceKey,
        'current_value': next,
        'updated_at': updatedAt,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    final number = next.toString().padLeft(padding, '0');
    return includeDate ? '$prefix-$datePart-$number' : '$prefix-$number';
  }

  String _compactDate(DateTime value) {
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '$year$month$day';
  }
}
