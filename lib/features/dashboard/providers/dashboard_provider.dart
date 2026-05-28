import 'package:flutter/foundation.dart';
import 'package:tailoring_system/features/dashboard/data/dashboard_repository.dart';

class DashboardProvider extends ChangeNotifier {
  DashboardProvider({DashboardRepository? repository})
      : _repository = repository ?? DashboardRepository();

  final DashboardRepository _repository;

  bool _isLoading = false;
  String? _errorMessage;
  DashboardSummary? _summary;
  List<Map<String, Object?>> _dueSoonOrders = [];
  List<Map<String, Object?>> _unpaidOrders = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DashboardSummary? get summary => _summary;
  List<Map<String, Object?>> get dueSoonOrders => List.unmodifiable(_dueSoonOrders);
  List<Map<String, Object?>> get unpaidOrders => List.unmodifiable(_unpaidOrders);

  Future<void> refresh() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _summary = await _repository.loadSummary();
      _dueSoonOrders = await _repository.dueSoonOrders();
      _unpaidOrders = await _repository.unpaidOrders();
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
