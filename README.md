# SuMeet - Organize meetings at campus easily.
"SuMeet" is a mobile app that makes it possible for students to create and join social events on campus. Students will be able to organize basketball games, volleyball matches or study sessions for people who are taking the same course.  

For now, students who want to organize a spontaneous activity rely on group chats and word of mouth, which makes it hard to know who is coming, where to meet, and whether a game has enough players. "SuMeet" provides one shared place where any student can publish an event with a time and a location on campus.  

## Requirements

- Flutter 3.47.6 (stable), Dart 3.13.5
- An Android emulator or iOS simulator (the UI is also tested with `flutter test`)

## Running

```
flutter pub get
flutter run
flutter test
```

Demo login: `demo@sabanciuniv.edu` / `demo123`. See [docs/BACKEND.md](docs/BACKEND.md) for the data and logic layer.

## Screens

Login, Sign up, Home (event feed with search and filters), Event Detail (with report sheet), Create Event, Edit Event, My Events (Joined / Created, with Leave and Cancel event) and Profile. Data is in memory and resets when the app restarts.
