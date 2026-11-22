import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sumeet/main.dart';

Future<void> _login(WidgetTester tester) async {
  await tester.pumpWidget(const SuMeetApp());
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
}

Future<void> _openTab(WidgetTester tester, String label) async {
  await tester.tap(
    find.descendant(of: find.byType(NavigationBar), matching: find.text(label)),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('profile shows the user, counters and logs out', (tester) async {
    await _login(tester);
    await _openTab(tester, 'Profile');

    expect(find.text('Demo Student'), findsOneWidget);
    expect(find.text('demo@sabanciuniv.edu'), findsOneWidget);
    expect(find.text('Computer Science and Engineering'), findsOneWidget);
    expect(find.text('Events created'), findsOneWidget);
    expect(find.text('Events joined'), findsOneWidget);

    await tester.tap(find.text('Log out'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome to SuMeet'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('my events: leaving a joined event removes its card', (
    tester,
  ) async {
    await _login(tester);
    await _openTab(tester, 'My Events');

    final leave = find.widgetWithText(OutlinedButton, 'Leave');
    expect(leave, findsWidgets);
    final before = tester.widgetList(leave).length;

    await tester.tap(leave.first);
    await tester.pumpAndSettle();
    expect(find.text('Leave this event?'), findsOneWidget);

    // Cancel keeps the card.
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(tester.widgetList(leave).length, before);

    // Confirm removes it.
    await tester.tap(leave.first);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Leave'));
    await tester.pumpAndSettle();
    expect(tester.widgetList(leave).length, before - 1);
  });

  testWidgets('my events: cancelling a created event removes its card', (
    tester,
  ) async {
    await _login(tester);
    await _openTab(tester, 'My Events');
    await tester.tap(find.text('Created'));
    await tester.pumpAndSettle();

    final cancel = find.widgetWithText(OutlinedButton, 'Cancel event');
    expect(cancel, findsWidgets);
    final before = tester.widgetList(cancel).length;

    await tester.tap(cancel.first);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Cancel event'));
    await tester.pumpAndSettle();
    expect(tester.widgetList(cancel).length, before - 1);
  });
}
