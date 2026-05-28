import 'package:flutter/foundation.dart';
import 'package:tailoring_system/features/receipts/data/receipt_repository.dart';

class ReceiptProvider extends ChangeNotifier {
  ReceiptProvider({ReceiptRepository? repository})
      : _repository = repository ?? ReceiptRepository();

  final ReceiptRepository _repository;

  bool _isLoading = false;
  String? _errorMessage;
  ReceiptData? _receipt;
  String? _plainTextReceipt;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ReceiptData? get receipt => _receipt;
  String? get plainTextReceipt => _plainTextReceipt;

  Future<void> loadReceipt(int paymentId, {String languageCode = 'en'}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _receipt = await _repository.receiptForPayment(paymentId);
      _plainTextReceipt = _receipt == null
          ? null
          : _repository.buildPlainTextReceipt(
              _receipt!,
              languageCode: languageCode,
            );
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
