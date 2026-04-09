import 'package:flutter_test/flutter_test.dart';

import 'package:bono_project_app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const BonoApp());

    // Verify that Splash Screen shows welcome text.
    expect(find.text('Кош келиңиз!'), findsOneWidget);
  });
}
