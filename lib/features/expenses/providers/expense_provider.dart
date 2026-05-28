import 'package:flutter/foundation.dart';
import 'package:tailoring_system/features/expenses/data/expense_repository.dart';

class ExpenseProvider extends ChangeNotifier {
  ExpenseProvider({ExpenseRepository? repository})
      : _repository = repository ?? ExpenseRepository();

  final ExpenseRepository _repository;

  bool _isLoading = false;
  String? _errorMessage;
  List<Map<String, Object?>> _expenses = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Map<String, Object?>> get expenses => List.unmodifiable(_expenses);

  Future<void> loadRange({
    required DateTime start,
    required DateTime end,
  }) async {
    await _run(() async {
      _expenses = await _repository.expensesForRange(start: start, end: end);
    });
  }

  Future<void> createExpense({
    required String category,
    required double amount,
    required DateTime expenseDate,
    String? paymentMethod,
    String? description,
  }) async {
    await _run(() async {
      await _repository.createExpense(
        category: category,
        amount: amount,
        expenseDate: expenseDate,
        paymentMethod: paymentMethod,
        description: description,
      );
      _expenses = await _repository.expensesForRange(
        start: DateTime(expenseDate.year, expenseDate.month, 1),
        end: DateTime(expenseDate.year, expenseDate.month + 1, 0, 23, 59, 59),
      );
    });
  }

  Future<void> _run(Future<void> Function() action) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await action();
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
