import 'package:flutter_test/flutter_test.dart';
import 'package:tailoring_system/models/shop_profile.dart';

void main() {
  test('legacy shop profiles are treated as already set up', () {
    final profile = ShopProfile.fromMap(
      {
        'userId': 'user-1',
        'shopName': 'Sample Shop',
        'ownerName': 'Sample Owner',
        'phone': '123456789',
        'createdAt': '2024-01-01T00:00:00.000',
      },
      'shop-1',
    );

    expect(profile.isSetupComplete, isTrue);
  });

  test('newly registered shop profiles remain incomplete until setup finishes',
      () {
    final profile = ShopProfile(
      userId: 'user-1',
      shopName: 'Sample Shop',
      ownerName: 'Sample Owner',
      phone: '123456789',
      createdAt: DateTime(2024),
      isSetupComplete: false,
    );

    expect(profile.toMap()['isSetupComplete'], isFalse);
  });
}
