# SuMeet data and logic layer

Owner: Kaan İspiroğlu. Everything here is in memory for now, so data resets
when the app restarts. Later steps can replace the inside of the services with
a real backend without changing the screens.

Demo login: `demo@sabanciuniv.edu` / `demo123`

## Folder layout

```
lib/
  main.dart                 providers + MaterialApp
  routes.dart               AppRoutes (named routes)
  models/                   AppUser, Event, EventCategory, EventReport, ReportReason
  data/                     mock_data.dart (seed users/events), campus_locations.dart
  services/                 AuthService, EventService (ChangeNotifier + Provider)
  utils/                    validators.dart, date_format.dart
  theme/app_theme.dart      AppColors + AppTheme (one palette for every screen)
  screens/                  UI (placeholders right now, see owners below)
  widgets/                  shared widgets
```

## Screen owners

| Screen | File | Owner |
|---|---|---|
| Login, Sign up | `screens/auth/` | Burak |
| Home (event feed) | `screens/home/home_screen.dart` | Burak |
| Event Detail (+ Report sheet) | `screens/events/event_detail_screen.dart` | Yeşim |
| Create Event | `screens/events/create_event_screen.dart` | Yeşim |
| Edit Event, My Events, Profile | | not assigned yet |

The placeholders only exist so the app compiles. Replace them as you go.

## Using the services

```dart
import 'package:provider/provider.dart';

// Rebuild when data changes (inside build):
final auth = context.watch<AuthService>();
final events = context.watch<EventService>();
final me = auth.currentUser!;

// One-off calls (in onPressed etc.):
final error = context.read<EventService>().joinEvent(event.id, me.id);
if (error != null) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
}
```

Methods that can fail return `String?`: `null` means success, otherwise it is a
message you can show the user.

### AuthService

| Member | Notes |
|---|---|
| `currentUser`, `isLoggedIn` | |
| `login(email, password)` | `String?` error |
| `signUp(fullName:, email:, department:, password:)` | logs the user in on success |
| `logout()` | then go to `AppRoutes.login` |
| `userById(id)`, `usersByIds(ids)` | for organizer and attendee names |

### EventService

| Member | Used on |
|---|---|
| `filteredEvents(category:, date:)` | Home. `category: null` is "All"; `DateFilter.any / today / thisWeek` |
| `eventById(id)` | Event Detail, Edit Event |
| `joinedEvents(userId)`, `createdEvents(userId)` | My Events tabs |
| `joinedCount(userId)`, `createdCount(userId)` | Profile counters |
| `createEvent(...)` | Create Event. Returns the new `Event`. Validate the form first |
| `updateEvent(eventId:, userId:, ...)` | Edit Event, `String?` error |
| `joinEvent` / `leaveEvent(eventId, userId)` | Event Detail, My Events |
| `cancelEvent(eventId, userId)` | organizer only |
| `reportEvent(eventId, userId, ReportReason)` | Report sheet |

Useful `Event` getters: `capacityLabel` ("3 / 6 joined"), `isFull`,
`isOrganizer(userId)`, `isAttending(userId)`, `category.label`.

## Validators

Each returns `null` or the error text from the wireframes, so they go straight
into `TextFormField(validator: ...)`:

`fullName`, `universityEmail`, `department`, `password`,
`confirmPassword(value, password)`, `eventTitle`,
`requiredChoice(value, 'Category')`, `eventDateTime(dateTime)`,
`maxParticipantsField(value, currentAttendees: n)`, `description`.

## Dates

`DateFormatter.card(d)` gives "Tue 10 Nov 18:00", `detail(d)` gives
"Tue 10 Nov, 18:00", `date(d)` gives "10 Nov 2026", `time(d)` gives "18:00".

## Navigation

```dart
Navigator.pushNamed(context, AppRoutes.eventDetail, arguments: event.id);
// in the screen:
final id = ModalRoute.of(context)!.settings.arguments as String;
```

Routes: `login` (start), `signUp`, `home` (bottom bar shell), `eventDetail`,
`createEvent`, `editEvent`.

## Tests

`flutter test` runs the unit tests for validators and services.
