import 'package:tailoring_system/core/database/app_sequence_repository.dart';
import 'package:tailoring_system/utils/database_helper.dart';

class ExpenseRepository {
  Future<int> createExpense({
    required String category,
    required double amount,
    required DateTime expenseDate,
    String? paymentMethod,
    String? description,
  }) async {
    final db = await DatabaseHelper.instance.database;
    final expenseNumber = await AppSequenceRepository(db).nextCode(
      key: 'expense',
      prefix: 'EXP',
    );
    return db.insert('expenses', {
      'expense_number': expenseNumber,
      'category': category,
      'amount': amount,
      'payment_method': paymentMethod,
      'description': description,
      'expense_date': expenseDate.toIso8601String(),
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, Object?>>> expensesForRange({
    required DateTime start,
    required DateTime end,
  }) async {
    final db = await DatabaseHelper.instance.database;
    return db.query(
      'expenses',
      where: 'expense_date >= ? AND expense_date <= ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'expense_date DESC',
    );
  }
}
