import 'package:flutter/foundation.dart';
import 'package:tailoring_system/features/appointments/data/appointment_repository.dart';

class AppointmentProvider extends ChangeNotifier {
  AppointmentProvider({AppointmentRepository? repository})
      : _repository = repository ?? AppointmentRepository();

  final AppointmentRepository _repository;

  bool _isLoading = false;
  String? _errorMessage;
  List<Map<String, Object?>> _appointments = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Map<String, Object?>> get appointments => List.unmodifiable(_appointments);

  Future<void> loadDay(DateTime day) async {
    await _run(() async {
      _appointments = await _repository.appointmentsForDay(day);
    });
  }

  Future<void> createAppointment({
    required int customerId,
    required DateTime scheduledAt,
    required String appointmentType,
    int? orderId,
    String? notes,
  }) async {
    await _run(() async {
      await _repository.createAppointment(
        customerId: customerId,
        scheduledAt: scheduledAt,
        appointmentType: appointmentType,
        orderId: orderId,
        notes: notes,
      );
      _appointments = await _repository.appointmentsForDay(scheduledAt);
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
