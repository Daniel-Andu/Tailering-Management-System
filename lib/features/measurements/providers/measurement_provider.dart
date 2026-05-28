import 'package:flutter/foundation.dart';
import 'package:tailoring_system/features/measurements/data/measurement_repository.dart';

class MeasurementProvider extends ChangeNotifier {
  MeasurementProvider({MeasurementRepository? repository})
      : _repository = repository ?? MeasurementRepository();

  final MeasurementRepository _repository;

  bool _isLoading = false;
  String? _errorMessage;
  List<Map<String, Object?>> _clothTypes = [];
  List<Map<String, Object?>> _templates = [];
  List<Map<String, Object?>> _fields = [];
  List<Map<String, Object?>> _customerMeasurements = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Map<String, Object?>> get clothTypes => List.unmodifiable(_clothTypes);
  List<Map<String, Object?>> get templates => List.unmodifiable(_templates);
  List<Map<String, Object?>> get fields => List.unmodifiable(_fields);
  List<Map<String, Object?>> get customerMeasurements =>
      List.unmodifiable(_customerMeasurements);

  Future<void> loadClothTypes() async {
    await _run(() async {
      _clothTypes = await _repository.clothTypes();
    });
  }

  Future<void> loadTemplatesForClothType(int clothTypeId) async {
    await _run(() async {
      _templates = await _repository.templatesForClothType(clothTypeId);
    });
  }

  Future<void> loadFieldsForTemplate(int templateId) async {
    await _run(() async {
      _fields = await _repository.fieldsForTemplate(templateId);
    });
  }

  Future<void> loadMeasurementsForCustomer(int customerId) async {
    await _run(() async {
      _customerMeasurements = await _repository.measurementsForCustomer(customerId);
    });
  }

  Future<void> saveCustomerMeasurement({
    required int customerId,
    required int templateId,
    required Map<int, Object?> valuesByFieldId,
    String? title,
    String? notes,
  }) async {
    await _run(() async {
      await _repository.saveCustomerMeasurement(
        customerId: customerId,
        templateId: templateId,
        valuesByFieldId: valuesByFieldId,
        title: title,
        notes: notes,
      );
      _customerMeasurements = await _repository.measurementsForCustomer(customerId);
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
