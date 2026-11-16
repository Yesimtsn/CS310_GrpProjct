import 'package:flutter_test/flutter_test.dart';
import 'package:sumeet/utils/validators.dart';

void main() {
  group('auth validators', () {
    test('university email', () {
      expect(Validators.universityEmail('ali@sabanciuniv.edu'), isNull);
      expect(Validators.universityEmail('  Ali@SabanciUniv.edu '), isNull);
      expect(
        Validators.universityEmail('ali@gmail.com'),
        'Use your @sabanciuniv.edu email',
      );
      expect(Validators.universityEmail('ali@sabanciuniv.edu.tr'), isNotNull);
      expect(Validators.universityEmail(''), 'Email is required');
    });

    test('password and confirmation', () {
      expect(
        Validators.password('12345'),
        'Password must be at least 6 characters',
      );
      expect(Validators.password('123456'), isNull);
      expect(
        Validators.confirmPassword('abc', 'abd'),
        'Passwords do not match',
      );
      expect(Validators.confirmPassword('abcdef', 'abcdef'), isNull);
    });

    test('full name', () {
      expect(Validators.fullName('  '), 'Full name is required');
      expect(Validators.fullName('Ayşe Yılmaz'), isNull);
    });
  });

  group('event validators', () {
    test('title', () {
      expect(Validators.eventTitle(''), 'Title is required');
      expect(Validators.eventTitle('Basketball 3v3'), isNull);
      expect(Validators.eventTitle('x' * 61), isNotNull);
    });

    test('max participants between 2 and 100', () {
      const msg = 'Value must be between 2 and 100';
      expect(Validators.maxParticipantsField('1'), msg);
      expect(Validators.maxParticipantsField('101'), msg);
      expect(Validators.maxParticipantsField('abc'), msg);
      expect(Validators.maxParticipantsField('2'), isNull);
      expect(Validators.maxParticipantsField('100'), isNull);
      expect(
        Validators.maxParticipantsField('3', currentAttendees: 4),
        '4 people already joined',
      );
    });

    test('date must be in the future', () {
      final now = DateTime(2026, 11, 16, 12);
      expect(Validators.eventDateTime(null), isNotNull);
      expect(
        Validators.eventDateTime(DateTime(2026, 11, 16, 11), now: now),
        'Event must be in the future',
      );
      expect(
        Validators.eventDateTime(DateTime(2026, 11, 17), now: now),
        isNull,
      );
    });

    test('required dropdown choice', () {
      expect(
        Validators.requiredChoice(null, 'Category'),
        'Category is required',
      );
      expect(Validators.requiredChoice('FENS', 'Location'), isNull);
    });
  });
}
