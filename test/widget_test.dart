import 'package:flutter_test/flutter_test.dart';
import 'package:cltv_sign/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const CltvSignApp());
    expect(find.byType(CltvSignApp), findsOneWidget);
  });
}
