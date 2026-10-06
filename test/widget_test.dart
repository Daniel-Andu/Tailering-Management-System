import 'package:flutter_test/flutter_test.dart';
import 'package:tailoring_system/main.dart';

void main() {
  testWidgets('Tailoring app builds without crashing', (tester) async {
    await tester.pumpWidget(const TailoringSystemApp());
    expect(find.byType(TailoringSystemApp), findsOneWidget);
  });
}
