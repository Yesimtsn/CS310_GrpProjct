import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sumeet/main.dart';

/// Walks through every screen on small and large phones (portrait) with a
/// larger system font. A RenderFlex overflow throws, which fails the test.
const _phones = <String, Size>{
  'small 320x568': Size(320, 568),
  'medium 360x800': Size(360, 800),
  'large 430x932': Size(430, 932),
};

Finder _field(String label) => find.widgetWithText(TextFormField, label);

/// Fails with the step name if the last action caused a layout error.
void _noError(WidgetTester tester, String step) {
  final error = tester.takeException();
  if (error != null) fail('Layout error after "$step": $error');
}

Future<void> _tab(WidgetTester tester, String label) async {
  await tester.tap(
    find.descendant(of: find.byType(NavigationBar), matching: find.text(label)),
  );
  await tester.pumpAndSettle();
  _noError(tester, 'open tab $label');
}

/// Scrolls the target into view first (screens are scrollable on small phones).
int _steps = 0;

Future<void> _tap(WidgetTester tester, Finder target) async {
  _steps++;
  expect(target, findsWidgets, reason: 'nothing to tap (step $_steps)');
  final finder = target.first;
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
  _noError(tester, 'tap #$_steps');
}

Future<void> _back(WidgetTester tester) async {
  await tester.pageBack();
  await tester.pumpAndSettle();
  _noError(tester, 'go back');
}

void main() {
  for (final entry in _phones.entries) {
    testWidgets('no overflow on ${entry.key}', (tester) async {
      tester.view.physicalSize = entry.value * 2;
      tester.view.devicePixelRatio = 2;
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
        tester.platformDispatcher.clearTextScaleFactorTestValue();
      });

      await tester.pumpWidget(const SuMeetApp());

      // Login, with error messages visible.
      await tester.enterText(_field('University email'), 'bad');
      await tester.enterText(_field('Password'), '1');
      await _tap(tester, find.text('Log in'));

      // Sign up, with error messages visible.
      await _tap(tester, find.text('Create account'));
      await _tap(tester, find.text('Create account').last);
      await _back(tester);

      expect(
        find.text('Welcome to SuMeet'),
        findsOneWidget,
        reason: 'not back on login',
      );

      // Log in as the demo user.
      await tester.enterText(
        _field('University email'),
        'demo@sabanciuniv.edu',
      );
      await tester.enterText(_field('Password'), 'demo123');
      await _tap(tester, find.text('Log in'));

      expect(
        find.byType(NavigationBar),
        findsOneWidget,
        reason: 'login failed',
      );

      // Event Detail (opened from a card), then Edit Event if offered.
      await _tap(tester, find.text('Basketball 3v3').first);
      final edit = find.text('Edit');
      if (edit.evaluate().isNotEmpty) {
        await _tap(tester, edit.first);
        await _back(tester);
      }
      await _back(tester);

      // Home. The chip rows scroll sideways, so on narrow phones a chip may
      // not be built; only tap one when it is on screen.
      final study = find.widgetWithText(ChoiceChip, 'Study');
      if (study.evaluate().isNotEmpty) {
        await _tap(tester, study);
      }

      // Create Event.
      await _tap(tester, find.byType(FloatingActionButton));
      await _back(tester);

      // My Events (both tabs) and Profile.
      await _tab(tester, 'My Events');
      await _tap(tester, find.text('Created'));
      await _tab(tester, 'Profile');

      expect(tester.takeException(), isNull);
    });
  }
}
