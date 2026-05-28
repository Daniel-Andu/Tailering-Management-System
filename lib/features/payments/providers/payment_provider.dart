import 'package:flutter/foundation.dart';
import 'package:tailoring_system/features/payments/data/payment_repository.dart';

class PaymentProvider extends ChangeNotifier {
  PaymentProvider({PaymentRepository? repository})
      : _repository = repository ?? PaymentRepository();

  final PaymentRepository _repository;

  bool _isLoading = false;
  String? _errorMessage;
  List<Map<String, Object?>> _payments = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Map<String, Object?>> get payments => List.unmodifiable(_payments);

  Future<void> loadPaymentsForOrder(int orderId) async {
    await _run(() async {
      _payments = await _repository.paymentsForOrder(orderId);
    });
  }

  Future<void> recordPayment({
    required int orderId,
    required int customerId,
    required double amount,
    required String paymentMethod,
    String? transactionReference,
    String? notes,
  }) async {
    await _run(() async {
      await _repository.recordPayment(
        orderId: orderId,
        customerId: customerId,
        amount: amount,
        paymentMethod: paymentMethod,
        transactionReference: transactionReference,
        notes: notes,
      );
      _payments = await _repository.paymentsForOrder(orderId);
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
