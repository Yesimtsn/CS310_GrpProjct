import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sumeet/main.dart';

void main() {
  testWidgets('app starts on Login and demo login reaches Home', (
    tester,
  ) async {
    await tester.pumpWidget(const SuMeetApp());
    expect(find.text('Login'), findsWidgets);

    await tester.tap(find.text('Log in as demo user'));
    await tester.pumpAndSettle();
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
