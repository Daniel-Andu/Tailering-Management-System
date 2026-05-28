import 'package:flutter/foundation.dart';
import 'package:tailoring_system/features/reports/data/financial_report_repository.dart';

class FinancialReportProvider extends ChangeNotifier {
  FinancialReportProvider({FinancialReportRepository? repository})
      : _repository = repository ?? FinancialReportRepository();

  final FinancialReportRepository _repository;

  bool _isLoading = false;
  String? _errorMessage;
  FinancialSummary? _summary;
  List<Map<String, Object?>> _paymentsByMethod = [];
  List<Map<String, Object?>> _unpaidBalances = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  FinancialSummary? get summary => _summary;
  List<Map<String, Object?>> get paymentsByMethod =>
      List.unmodifiable(_paymentsByMethod);
  List<Map<String, Object?>> get unpaidBalances =>
      List.unmodifiable(_unpaidBalances);

  Future<void> loadRange({
    required DateTime start,
    required DateTime end,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _summary = await _repository.summaryForRange(start: start, end: end);
      _paymentsByMethod =
          await _repository.paymentsByMethod(start: start, end: end);
      _unpaidBalances = await _repository.unpaidBalances();
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
