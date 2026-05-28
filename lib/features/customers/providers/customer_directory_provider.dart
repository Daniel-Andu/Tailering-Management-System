import 'package:flutter/foundation.dart';
import 'package:tailoring_system/features/customers/data/customer_directory_repository.dart';

class CustomerDirectoryProvider extends ChangeNotifier {
  CustomerDirectoryProvider({CustomerDirectoryRepository? repository})
      : _repository = repository ?? CustomerDirectoryRepository();

  final CustomerDirectoryRepository _repository;

  bool _isLoading = false;
  String? _errorMessage;
  List<Map<String, Object?>> _customers = [];
  String _query = '';

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Map<String, Object?>> get customers => List.unmodifiable(_customers);
  String get query => _query;

  Future<void> search(String query) async {
    _query = query;
    await _run(() async {
      _customers = await _repository.searchCustomers(query);
    });
  }

  Future<void> createCustomer({
    required String fullName,
    required String phone,
    String? businessName,
    String? gender,
    String? secondaryPhone,
    String? email,
    String? address,
    String category = 'regular',
    String preferredLanguage = 'am',
    String? notes,
  }) async {
    await _run(() async {
      await _repository.createCustomer(
        fullName: fullName,
        phone: phone,
        businessName: businessName,
        gender: gender,
        secondaryPhone: secondaryPhone,
        email: email,
        address: address,
        category: category,
        preferredLanguage: preferredLanguage,
        notes: notes,
      );
      _customers = await _repository.searchCustomers(_query);
    });
  }

  Future<void> updateCustomer({
    required int customerId,
    required String fullName,
    required String phone,
    String? businessName,
    String? address,
    String category = 'regular',
    String preferredLanguage = 'am',
    String? notes,
  }) async {
    await _run(() async {
      await _repository.updateCustomer(
        customerId: customerId,
        fullName: fullName,
        phone: phone,
        businessName: businessName,
        address: address,
        category: category,
        preferredLanguage: preferredLanguage,
        notes: notes,
      );
      _customers = await _repository.searchCustomers(_query);
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
