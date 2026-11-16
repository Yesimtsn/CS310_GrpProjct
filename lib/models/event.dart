/// Event categories, matching the filter chips on Home.
enum EventCategory {
  sports('Sports'),
  study('Study'),
  social('Social'),
  other('Other');

  final String label;
  const EventCategory(this.label);
}

/// A campus event. Immutable: changes go through [EventService], which
/// replaces the stored instance with a [copyWith] result.
class Event {
  final String id;
  final String title;
  final EventCategory category;
  final DateTime dateTime;
  final String location;
  final int maxParticipants;
  final String description;
  final String organizerId;

  /// Everyone attending, organizer included (the organizer is added on create).
  final List<String> attendeeIds;

  /// Optional cover image (asset path or URL). Null shows a placeholder.
  final String? imageUrl;

  const Event({
    required this.id,
    required this.title,
    required this.category,
    required this.dateTime,
    required this.location,
    required this.maxParticipants,
    required this.description,
    required this.organizerId,
    required this.attendeeIds,
    this.imageUrl,
  });

  int get attendeeCount => attendeeIds.length;
  int get spotsLeft => maxParticipants - attendeeCount;
  bool get isFull => attendeeCount >= maxParticipants;
  bool get isPast => dateTime.isBefore(DateTime.now());

  /// "3 / 6 joined"
  String get capacityLabel => '$attendeeCount / $maxParticipants joined';

  bool isOrganizer(String userId) => organizerId == userId;
  bool isAttending(String userId) => attendeeIds.contains(userId);

  Event copyWith({
    String? title,
    EventCategory? category,
    DateTime? dateTime,
    String? location,
    int? maxParticipants,
    String? description,
    List<String>? attendeeIds,
    String? imageUrl,
  }) {
    return Event(
      id: id,
      title: title ?? this.title,
      category: category ?? this.category,
      dateTime: dateTime ?? this.dateTime,
      location: location ?? this.location,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      description: description ?? this.description,
      organizerId: organizerId,
      attendeeIds: attendeeIds ?? this.attendeeIds,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  @override
  bool operator ==(Object other) => other is Event && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
