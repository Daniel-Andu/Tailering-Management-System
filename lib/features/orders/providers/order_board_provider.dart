import 'package:flutter/foundation.dart';
import 'package:tailoring_system/features/orders/data/order_board_repository.dart';
import 'package:tailoring_system/features/orders/data/order_workflow_repository.dart';

class OrderBoardProvider extends ChangeNotifier {
  OrderBoardProvider({
    OrderBoardRepository? repository,
    OrderWorkflowRepository? workflowRepository,
  })  : _repository = repository ?? OrderBoardRepository(),
        _workflowRepository = workflowRepository ?? OrderWorkflowRepository();

  final OrderBoardRepository _repository;
  final OrderWorkflowRepository _workflowRepository;

  bool _isLoading = false;
  String? _errorMessage;
  String? _statusFilter;
  String _query = '';
  List<Map<String, Object?>> _orders = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get statusFilter => _statusFilter;
  String get query => _query;
  List<Map<String, Object?>> get orders => List.unmodifiable(_orders);

  Future<void> load({String? status, String? query}) async {
    _statusFilter = status;
    _query = query ?? _query;
    await _run(() async {
      _orders = await _repository.orders(status: _statusFilter, query: _query);
    });
  }

  Future<void> createOrder({
    required int customerId,
    required String clothType,
    required double price,
    required DateTime deliveryDate,
    required String priority,
    required String urgencyLevel,
    DateTime? fittingDate,
    int? assignedStaffId,
    String? notes,
    String? gender,
    double? chest,
    double? shoulder,
    double? hip,
    double? breast,
    double? waist,
    double? length,
    double? sleeve,
    double? neck,
    String? clothPhoto,
  }) async {
    await _run(() async {
      await _repository.createOrder(
        customerId: customerId,
        clothType: clothType,
        price: price,
        deliveryDate: deliveryDate,
        priority: priority,
        urgencyLevel: urgencyLevel,
        fittingDate: fittingDate,
        assignedStaffId: assignedStaffId,
        notes: notes,
        gender: gender,
        chest: chest,
        shoulder: shoulder,
        hip: hip,
        breast: breast,
        waist: waist,
        length: length,
        sleeve: sleeve,
        neck: neck,
        clothPhoto: clothPhoto,
      );
      _orders = await _repository.orders(status: _statusFilter, query: _query);
    });
  }

  Future<void> changeStatus(int orderId, String newStatus) async {
    await _run(() async {
      await _workflowRepository.changeStatus(
        orderId: orderId,
        newStatus: newStatus,
      );
      _orders = await _repository.orders(status: _statusFilter, query: _query);
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
