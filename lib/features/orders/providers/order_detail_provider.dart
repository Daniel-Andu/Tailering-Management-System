import 'package:flutter/foundation.dart';
import 'package:tailoring_system/features/orders/data/order_detail_repository.dart';

class OrderDetailProvider extends ChangeNotifier {
  OrderDetailProvider({OrderDetailRepository? repository})
      : _repository = repository ?? OrderDetailRepository();

  final OrderDetailRepository _repository;

  bool _isLoading = false;
  String? _errorMessage;
  Map<String, Object?>? _order;
  List<Map<String, Object?>> _items = [];
  List<Map<String, Object?>> _history = [];
  List<Map<String, Object?>> _payments = [];
  List<Map<String, Object?>> _notifications = [];
  List<Map<String, Object?>> _appointments = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, Object?>? get order => _order;
  List<Map<String, Object?>> get items => List.unmodifiable(_items);
  List<Map<String, Object?>> get history => List.unmodifiable(_history);
  List<Map<String, Object?>> get payments => List.unmodifiable(_payments);
  List<Map<String, Object?>> get notifications => List.unmodifiable(_notifications);
  List<Map<String, Object?>> get appointments => List.unmodifiable(_appointments);

  Future<void> load(int orderId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _order = await _repository.orderDetail(orderId);
      _items = await _repository.orderItems(orderId);
      _history = await _repository.statusHistory(orderId);
      _payments = await _repository.payments(orderId);
      _notifications = await _repository.notifications(orderId);
      _appointments = await _repository.appointments(orderId);
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
