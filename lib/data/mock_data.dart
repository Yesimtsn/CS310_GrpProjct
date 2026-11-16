import '../models/app_user.dart';
import '../models/event.dart';

/// In-memory seed data so the app has content before we add a real backend.
///
/// Demo login: demo@sabanciuniv.edu / demo123
class MockData {
  static const demoEmail = 'demo@sabanciuniv.edu';
  static const demoPassword = 'demo123';

  static const users = [
    AppUser(
      id: 'u1',
      fullName: 'Demo Student',
      email: demoEmail,
      department: 'Computer Science and Engineering',
    ),
    AppUser(
      id: 'u2',
      fullName: 'Ayşe Yılmaz',
      email: 'ayse.yilmaz@sabanciuniv.edu',
      department: 'Industrial Engineering',
    ),
    AppUser(
      id: 'u3',
      fullName: 'Mehmet Kaya',
      email: 'mehmet.kaya@sabanciuniv.edu',
      department: 'Economics',
    ),
    AppUser(
      id: 'u4',
      fullName: 'Zeynep Demir',
      email: 'zeynep.demir@sabanciuniv.edu',
      department: 'Molecular Biology',
    ),
    AppUser(
      id: 'u5',
      fullName: 'Can Öztürk',
      email: 'can.ozturk@sabanciuniv.edu',
      department: 'Computer Science and Engineering',
    ),
  ];

  /// Passwords keyed by email. Mock only; never do this with real users.
  static const passwords = {
    demoEmail: demoPassword,
    'ayse.yilmaz@sabanciuniv.edu': 'ayse123',
    'mehmet.kaya@sabanciuniv.edu': 'mehmet123',
    'zeynep.demir@sabanciuniv.edu': 'zeynep123',
    'can.ozturk@sabanciuniv.edu': 'can123',
  };

  /// Dates are relative to [now] so the seed events always stay upcoming.
  static List<Event> events([DateTime? now]) {
    final base = now ?? DateTime.now();
    DateTime at(int daysFromNow, int hour) {
      final d = base.add(Duration(days: daysFromNow));
      return DateTime(d.year, d.month, d.day, hour);
    }

    return [
      Event(
        id: 'e1',
        title: 'Basketball 3v3',
        category: EventCategory.sports,
        dateTime: at(1, 18),
        location: 'Sports Center Basketball Court',
        maxParticipants: 6,
        description: 'Casual 3v3 game, all levels welcome.',
        organizerId: 'u1',
        attendeeIds: ['u1', 'u2', 'u3'],
      ),
      Event(
        id: 'e2',
        title: 'Study session: CS310',
        category: EventCategory.study,
        dateTime: at(2, 14),
        location: 'Library Room',
        maxParticipants: 5,
        description:
            'Going over Flutter layouts and state before the project deadline.',
        organizerId: 'u2',
        attendeeIds: ['u2', 'u1', 'u3', 'u4', 'u5'],
      ),
      Event(
        id: 'e3',
        title: 'Volleyball night',
        category: EventCategory.sports,
        dateTime: at(3, 20),
        location: 'Sports Center Volleyball Court',
        maxParticipants: 12,
        description: 'Mixed teams, we rotate every set.',
        organizerId: 'u3',
        attendeeIds: ['u3', 'u1', 'u4'],
      ),
      Event(
        id: 'e4',
        title: 'Board games at UC',
        category: EventCategory.social,
        dateTime: at(5, 19),
        location: 'University Center',
        maxParticipants: 8,
        description: 'Bring your favourite game. Catan and Codenames provided.',
        organizerId: 'u1',
        attendeeIds: ['u1', 'u5'],
      ),
      Event(
        id: 'e5',
        title: 'MATH201 problem solving',
        category: EventCategory.study,
        dateTime: at(9, 16),
        location: 'FENS',
        maxParticipants: 10,
        description: 'Working through last year\'s midterm together.',
        organizerId: 'u4',
        attendeeIds: ['u4'],
      ),
    ];
  }
}
