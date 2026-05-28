import 'package:flutter/foundation.dart';
import 'package:tailoring_system/features/notifications/data/notification_repository.dart';

class NotificationProvider extends ChangeNotifier {
  NotificationProvider({NotificationRepository? repository})
      : _repository = repository ?? NotificationRepository();

  final NotificationRepository _repository;

  bool _isLoading = false;
  String? _errorMessage;
  List<Map<String, Object?>> _pending = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Map<String, Object?>> get pending => List.unmodifiable(_pending);

  Future<void> loadPending() async {
    await _run(() async {
      _pending = await _repository.pendingNotifications();
    });
  }

  Future<int> processPendingSms() async {
    var sent = 0;
    await _run(() async {
      sent = await _repository.processPendingSms();
      _pending = await _repository.pendingNotifications();
    });
    return sent;
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
