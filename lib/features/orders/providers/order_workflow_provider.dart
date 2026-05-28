import 'package:flutter/foundation.dart';
import 'package:tailoring_system/features/orders/data/order_workflow_repository.dart';
import 'package:tailoring_system/features/notifications/data/notification_repository.dart';

class OrderWorkflowProvider extends ChangeNotifier {
  OrderWorkflowProvider({
    OrderWorkflowRepository? repository,
    NotificationRepository? notificationRepository,
  })  : _repository = repository ?? OrderWorkflowRepository(),
        _notificationRepository =
            notificationRepository ?? NotificationRepository();

  final OrderWorkflowRepository _repository;
  final NotificationRepository _notificationRepository;

  bool _isLoading = false;
  String? _errorMessage;
  List<Map<String, Object?>> _statusHistory = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Map<String, Object?>> get statusHistory =>
      List.unmodifiable(_statusHistory);

  Future<void> loadStatusHistory(int orderId) async {
    await _run(() async {
      _statusHistory = await _repository.statusHistory(orderId);
    });
  }

  Future<void> changeStatus({
    required int orderId,
    required String newStatus,
    String? notes,
  }) async {
    await _run(() async {
      await _repository.changeStatus(
        orderId: orderId,
        newStatus: newStatus,
        notes: notes,
      );
      _statusHistory = await _repository.statusHistory(orderId);

      // Create notification when order is completed
      if (newStatus.toLowerCase() == 'completed') {
        await _notificationRepository.createNotification(
          type: 'order_completed',
          title: 'Order Completed',
          message:
              'Order #$orderId has been completed and is ready for pickup.',
          entityId: orderId,
        );
      }
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
