import 'package:flutter/foundation.dart';
import 'package:tailoring_system/features/customers/data/customer_profile_repository.dart';

class CustomerProfileProvider extends ChangeNotifier {
  CustomerProfileProvider({CustomerProfileRepository? repository})
      : _repository = repository ?? CustomerProfileRepository();

  final CustomerProfileRepository _repository;

  bool _isLoading = false;
  String? _errorMessage;
  CustomerProfileStats? _stats;
  List<Map<String, Object?>> _timeline = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  CustomerProfileStats? get stats => _stats;
  List<Map<String, Object?>> get timeline => List.unmodifiable(_timeline);

  Future<void> load(int customerId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _stats = await _repository.stats(customerId);
      _timeline = await _repository.timeline(customerId);
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
