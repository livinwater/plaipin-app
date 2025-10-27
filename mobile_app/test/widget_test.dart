// This is a basic Flutter widget test.

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/main.dart';

void main() {
  testWidgets('App starts successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CompanionApp());

    // Verify that the home screen loads
    expect(find.text('Your Companion'), findsOneWidget);
  });
}
