import 'package:flutter/foundation.dart';

import '../data/mock_data.dart';
import '../models/event.dart';
import '../models/event_report.dart';
import '../utils/validators.dart';

/// Date chips on Home.
enum DateFilter {
  any('Any date'),
  today('Today'),
  thisWeek('This week');

  final String label;
  const DateFilter(this.label);
}

/// All event data and rules (join, leave, create, edit, cancel, report).
/// In-memory for now; the public API is what screens should rely on.
///
/// Mutating methods that can fail for a user-facing reason return
/// `String?`: null on success, otherwise a message for a SnackBar.
class EventService extends ChangeNotifier {
  final List<Event> _events;
  final List<EventReport> _reports = [];
  final DateTime Function() _clock;
  int _nextId = 100;

  /// [clock] is injectable for tests.
  EventService({bool seed = true, DateTime Function()? clock})
    : _clock = clock ?? DateTime.now,
      _events = [] {
    if (seed) _events.addAll(MockData.events(_clock()));
  }

  // ---------------------------------------------------------------- queries

  /// Upcoming events, soonest first.
  List<Event> get upcomingEvents {
    final now = _clock();
    return _events.where((e) => !e.dateTime.isBefore(now)).toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  Event? eventById(String id) {
    for (final e in _events) {
      if (e.id == id) return e;
    }
    return null;
  }

  /// Home feed. [category] null means "All".
  /// "This week" means today plus the next 7 days.
  /// [query] is the search bar text: matches title, location or description,
  /// ignoring case; empty means no search.
  List<Event> filteredEvents({
    EventCategory? category,
    DateFilter date = DateFilter.any,
    String query = '',
  }) {
    final now = _clock();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final endOfToday = startOfToday.add(const Duration(days: 1));
    final endOfWeek = startOfToday.add(const Duration(days: 8));
    final q = query.trim().toLowerCase();

    return upcomingEvents.where((e) {
      if (category != null && e.category != category) return false;
      if (q.isNotEmpty && !_matches(e, q)) return false;
      switch (date) {
        case DateFilter.any:
          return true;
        case DateFilter.today:
          return e.dateTime.isBefore(endOfToday);
        case DateFilter.thisWeek:
          return e.dateTime.isBefore(endOfWeek);
      }
    }).toList();
  }

  /// My Events > Joined: attending but not organizing.
  List<Event> joinedEvents(String userId) => upcomingEvents
      .where((e) => e.isAttending(userId) && !e.isOrganizer(userId))
      .toList();

  /// My Events > Created.
  List<Event> createdEvents(String userId) =>
      upcomingEvents.where((e) => e.isOrganizer(userId)).toList();

  /// Profile counters.
  int createdCount(String userId) => createdEvents(userId).length;
  int joinedCount(String userId) => joinedEvents(userId).length;

  List<EventReport> get reports => List.unmodifiable(_reports);

  // -------------------------------------------------------------- mutations

  /// Creates an event with the organizer as its first attendee.
  /// Throws [ArgumentError] if the data is invalid; screens should run the
  /// [Validators] on the form first so this never fires in practice.
  Event createEvent({
    required String organizerId,
    required String title,
    required EventCategory category,
    required DateTime dateTime,
    required String location,
    required int maxParticipants,
    String description = '',
    String? imageUrl,
  }) {
    _validateEventData(
      title: title,
      dateTime: dateTime,
      location: location,
      maxParticipants: maxParticipants,
      description: description,
    );

    final event = Event(
      id: 'e${_nextId++}',
      title: title.trim(),
      category: category,
      dateTime: dateTime,
      location: location,
      maxParticipants: maxParticipants,
      description: description.trim(),
      organizerId: organizerId,
      attendeeIds: [organizerId],
      imageUrl: imageUrl,
    );
    _events.add(event);
    notifyListeners();
    return event;
  }

  /// Only the organizer can edit. Capacity can't drop below current attendees.
  String? updateEvent({
    required String eventId,
    required String userId,
    required String title,
    required EventCategory category,
    required DateTime dateTime,
    required String location,
    required int maxParticipants,
    String description = '',
  }) {
    final event = eventById(eventId);
    if (event == null) return 'Event not found';
    if (!event.isOrganizer(userId)) {
      return 'Only the organizer can edit this event';
    }

    try {
      _validateEventData(
        title: title,
        dateTime: dateTime,
        location: location,
        maxParticipants: maxParticipants,
        description: description,
        currentAttendees: event.attendeeCount,
      );
    } on ArgumentError catch (e) {
      return e.message as String;
    }

    _replace(
      event.copyWith(
        title: title.trim(),
        category: category,
        dateTime: dateTime,
        location: location,
        maxParticipants: maxParticipants,
        description: description.trim(),
      ),
    );
    return null;
  }

  /// Organizer cancels: the event is removed for everyone.
  String? cancelEvent(String eventId, String userId) {
    final event = eventById(eventId);
    if (event == null) return 'Event not found';
    if (!event.isOrganizer(userId)) {
      return 'Only the organizer can cancel this event';
    }

    _events.removeWhere((e) => e.id == eventId);
    notifyListeners();
    return null;
  }

  String? joinEvent(String eventId, String userId) {
    final event = eventById(eventId);
    if (event == null) return 'Event not found';
    if (event.isAttending(userId)) return 'You already joined this event';
    if (event.dateTime.isBefore(_clock())) {
      return 'This event has already started';
    }
    if (event.isFull) return 'This event is full';

    _replace(event.copyWith(attendeeIds: [...event.attendeeIds, userId]));
    return null;
  }

  String? leaveEvent(String eventId, String userId) {
    final event = eventById(eventId);
    if (event == null) return 'Event not found';
    if (event.isOrganizer(userId)) {
      return 'Organizers can\'t leave; cancel the event instead';
    }
    if (!event.isAttending(userId)) return 'You are not in this event';

    _replace(
      event.copyWith(
        attendeeIds: event.attendeeIds.where((id) => id != userId).toList(),
      ),
    );
    return null;
  }

  String? reportEvent(String eventId, String userId, ReportReason reason) {
    if (eventById(eventId) == null) return 'Event not found';
    final already = _reports.any(
      (r) => r.eventId == eventId && r.reporterId == userId,
    );
    if (already) return 'You already reported this event';

    _reports.add(
      EventReport(
        eventId: eventId,
        reporterId: userId,
        reason: reason,
        createdAt: _clock(),
      ),
    );
    notifyListeners();
    return null;
  }

  // ---------------------------------------------------------------- helpers

  /// [q] is already trimmed and lower-case.
  bool _matches(Event e, String q) =>
      e.title.toLowerCase().contains(q) ||
      e.location.toLowerCase().contains(q) ||
      e.description.toLowerCase().contains(q);

  void _replace(Event updated) {
    final i = _events.indexWhere((e) => e.id == updated.id);
    _events[i] = updated;
    notifyListeners();
  }

  void _validateEventData({
    required String title,
    required DateTime dateTime,
    required String location,
    required int maxParticipants,
    required String description,
    int currentAttendees = 0,
  }) {
    final error =
        Validators.eventTitle(title) ??
        Validators.eventDateTime(dateTime, now: _clock()) ??
        Validators.requiredChoice(location, 'Location') ??
        Validators.maxParticipantsField(
          '$maxParticipants',
          currentAttendees: currentAttendees,
        ) ??
        Validators.description(description);
    if (error != null) throw ArgumentError(error);
  }
}
