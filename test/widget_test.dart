import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_genui_sdk_firebase_mcp/main.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const GenericTemplateApp());

    // Verify that the Dashboard tab is present.
    expect(find.text('Dashboard'), findsOneWidget);
  });
}

