import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sumeet/main.dart';

Finder _field(String label) => find.widgetWithText(TextFormField, label);

void main() {
  testWidgets('login shows inline errors for invalid input', (tester) async {
    await tester.pumpWidget(const SuMeetApp());
    await tester.enterText(_field('University email'), 'a@gmail.com');
    await tester.enterText(_field('Password'), '123');
    await tester.tap(find.text('Log in'));
    await tester.pump();
    expect(find.text('Use your @sabanciuniv.edu email'), findsOneWidget);
    expect(find.text('Password must be at least 6 characters'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('wrong password stays on login with a message', (tester) async {
    await tester.pumpWidget(const SuMeetApp());
    await tester.enterText(_field('University email'), 'demo@sabanciuniv.edu');
    await tester.enterText(_field('Password'), 'wrongpass');
    await tester.tap(find.text('Log in'));
    await tester.pump();
    expect(find.text('Incorrect email or password'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  Future<void> login(WidgetTester tester) async {
    await tester.pumpWidget(const SuMeetApp());
    await tester.enterText(_field('University email'), 'demo@sabanciuniv.edu');
    await tester.enterText(_field('Password'), 'demo123');
    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();
  }

  testWidgets('valid login opens Home with the feed', (tester) async {
    await login(tester);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Basketball 3v3'), findsOneWidget);
    expect(find.text('Any date'), findsOneWidget);
  });

  testWidgets('category chip filters the feed', (tester) async {
    await login(tester);
    await tester.tap(find.widgetWithText(ChoiceChip, 'Study'));
    await tester.pumpAndSettle();
    expect(find.text('Basketball 3v3'), findsNothing);
    expect(find.textContaining('CS310'), findsOneWidget);
  });

  testWidgets('sign up validates then opens Home', (tester) async {
    await tester.pumpWidget(const SuMeetApp());
    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();
    expect(find.text('Create your account'), findsOneWidget);

    await tester.enterText(_field('University email'), 'x@gmail.com');
    await tester.enterText(_field('Password'), 'secret1');
    await tester.enterText(_field('Confirm password'), 'secret2');
    await tester.tap(find.text('Create account').last);
    await tester.pump();
    expect(find.text('Full name is required'), findsOneWidget);
    expect(find.text('Use your @sabanciuniv.edu email'), findsOneWidget);
    expect(find.text('Passwords do not match'), findsOneWidget);

    await tester.enterText(_field('Full name'), 'Burak Ala');
    await tester.enterText(
      _field('University email'),
      'burak.ala@sabanciuniv.edu',
    );
    await tester.enterText(_field('Department'), 'Computer Science');
    await tester.enterText(_field('Confirm password'), 'secret1');
    await tester.tap(find.text('Create account').last);
    await tester.pumpAndSettle();
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
