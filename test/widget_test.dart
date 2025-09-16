// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tutorhouse_app/app.dart';

void main() {
  testWidgets('App starts with auth screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: TutorhouseApp(),
      ),
    );

    // Verify that the auth screen is displayed
    expect(find.text('Tutorhouse'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });
}
