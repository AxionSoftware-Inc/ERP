import 'package:flutter_test/flutter_test.dart';
import 'package:erp_client/main.dart';

void main() {
  testWidgets('ERP Ecosystem App boots up correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const ERPEcosystemApp());
    expect(find.text('NEXT ERP'), findsNothing);
  });
}
