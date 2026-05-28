import 'package:flutter/foundation.dart';
import 'package:tailoring_system/features/staff/data/staff_repository.dart';

class StaffProvider extends ChangeNotifier {
  StaffProvider({StaffRepository? repository})
      : _repository = repository ?? StaffRepository();

  final StaffRepository _repository;

  bool _isLoading = false;
  String? _errorMessage;
  List<Map<String, Object?>> _staff = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Map<String, Object?>> get staff => List.unmodifiable(_staff);

  Future<void> refresh() async {
    await _run(() async {
      _staff = await _repository.activeStaff();
    });
  }

  Future<void> createStaff({
    required String fullName,
    required String role,
    String? phone,
  }) async {
    await _run(() async {
      await _repository.createStaff(fullName: fullName, role: role, phone: phone);
      _staff = await _repository.activeStaff();
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
