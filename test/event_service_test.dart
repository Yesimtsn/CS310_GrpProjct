import 'package:flutter_test/flutter_test.dart';
import 'package:sumeet/models/event.dart';
import 'package:sumeet/models/event_report.dart';
import 'package:sumeet/services/event_service.dart';

void main() {
  // Monday 16 Nov 2026, 12:00
  final now = DateTime(2026, 11, 16, 12);
  late EventService events;
  setUp(() => events = EventService(clock: () => now));

  group('queries', () {
    test('seed matches the wireframes for the demo user', () {
      expect(events.createdCount('u1'), 2);
      expect(events.joinedCount('u1'), 2);
      expect(events.eventById('e2')!.isFull, isTrue);
      expect(events.eventById('e1')!.capacityLabel, '3 / 6 joined');
    });

    test('upcoming events are sorted by date', () {
      final list = events.upcomingEvents;
      for (var i = 1; i < list.length; i++) {
        expect(list[i].dateTime.isBefore(list[i - 1].dateTime), isFalse);
      }
    });

    test('filters by category and date', () {
      expect(
        events.filteredEvents(category: EventCategory.study).map((e) => e.id),
        ['e2', 'e5'],
      );
      // seed: e1 +1 day, e2 +2, e3 +3, e4 +5, e5 +9
      expect(events.filteredEvents(date: DateFilter.thisWeek).length, 4);
      expect(events.filteredEvents(date: DateFilter.today), isEmpty);
    });
  });

  group('join / leave', () {
    test('join adds the user and updates the count', () {
      expect(events.joinEvent('e1', 'u4'), isNull);
      expect(events.eventById('e1')!.attendeeCount, 4);
      expect(events.joinEvent('e1', 'u4'), 'You already joined this event');
    });

    test('cannot join a full event', () {
      expect(events.joinEvent('e2', 'u99'), 'This event is full');
    });

    test('leave removes the user', () {
      expect(events.leaveEvent('e3', 'u1'), isNull);
      expect(events.eventById('e3')!.isAttending('u1'), isFalse);
      expect(events.joinedCount('u1'), 1);
    });

    test('organizer cannot leave', () {
      expect(events.leaveEvent('e1', 'u1'), isNotNull);
    });

    test('listeners are notified', () {
      var calls = 0;
      events.addListener(() => calls++);
      events.joinEvent('e1', 'u4');
      expect(calls, 1);
    });
  });

  group('create / edit / cancel', () {
    test('create adds organizer as first attendee', () {
      final e = events.createEvent(
        organizerId: 'u2',
        title: '  Football 5v5 ',
        category: EventCategory.sports,
        dateTime: now.add(const Duration(days: 1)),
        location: 'Football Field',
        maxParticipants: 10,
      );
      expect(e.title, 'Football 5v5');
      expect(e.attendeeIds, ['u2']);
      expect(events.createdCount('u2'), 2);
    });

    test('create rejects invalid data', () {
      expect(
        () => events.createEvent(
          organizerId: 'u2',
          title: 'Past',
          category: EventCategory.other,
          dateTime: now.subtract(const Duration(hours: 1)),
          location: 'FENS',
          maxParticipants: 5,
        ),
        throwsArgumentError,
      );
    });

    test('only organizer can edit; capacity >= attendees', () {
      final e = events.eventById('e1')!;
      String? edit(String user, int max) => events.updateEvent(
        eventId: e.id,
        userId: user,
        title: 'Basketball 4v4',
        category: e.category,
        dateTime: e.dateTime,
        location: e.location,
        maxParticipants: max,
      );

      expect(edit('u2', 8), 'Only the organizer can edit this event');
      expect(edit('u1', 2), '3 people already joined');
      expect(edit('u1', 8), isNull);
      expect(events.eventById('e1')!.title, 'Basketball 4v4');
      expect(events.eventById('e1')!.attendeeCount, 3);
    });

    test('cancel removes the event; only organizer', () {
      expect(events.cancelEvent('e1', 'u2'), isNotNull);
      expect(events.cancelEvent('e1', 'u1'), isNull);
      expect(events.eventById('e1'), isNull);
    });
  });

  test('report once per user', () {
    expect(events.reportEvent('e3', 'u1', ReportReason.spam), isNull);
    expect(
      events.reportEvent('e3', 'u1', ReportReason.fake),
      'You already reported this event',
    );
    expect(events.reports.length, 1);
  });
}
