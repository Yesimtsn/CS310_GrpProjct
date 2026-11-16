import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sumeet/main.dart';

void main() {
  testWidgets('app starts on Login and a valid login reaches Home', (
    tester,
  ) async {
    await tester.pumpWidget(const SuMeetApp());
    expect(find.text('Welcome to SuMeet'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'University email'),
      'demo@sabanciuniv.edu',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Password'),
      'demo123',
    );
    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
