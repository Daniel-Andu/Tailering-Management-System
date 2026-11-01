import 'package:flutter_test/flutter_test.dart';
import 'package:tailoring_system/features/payments/data/payment_repository.dart';
import 'package:tailoring_system/core/domain/payment_method.dart';

void main() {
  test('Chapa order payments are rejected until server verification exists',
      () async {
    await expectLater(
      PaymentRepository().recordPayment(
        orderId: 1,
        customerId: 1,
        amount: 500,
        paymentMethod: PaymentMethods.chapa,
      ),
      throwsA(isA<StateError>()),
    );
  });
}
