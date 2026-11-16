import 'package:flutter/material.dart';

import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/events/create_event_screen.dart';
import 'screens/events/edit_event_screen.dart';
import 'screens/events/event_detail_screen.dart';
import 'screens/main_shell.dart';

/// Named routes (see the 2.1 navigation flow).
///
/// Screens that need an event take its id as the route argument:
///   Navigator.pushNamed(context, AppRoutes.eventDetail, arguments: event.id);
///   final id = ModalRoute.of(context)!.settings.arguments as String;
class AppRoutes {
  static const login = '/';
  static const signUp = '/signup';
  static const home = '/home'; // bottom-bar shell: Home, My Events, Profile
  static const eventDetail = '/event';
  static const createEvent = '/event/create';
  static const editEvent = '/event/edit';

  static Map<String, WidgetBuilder> get table => {
    login: (_) => const LoginScreen(),
    signUp: (_) => const SignUpScreen(),
    home: (_) => const MainShell(),
    eventDetail: (_) => const EventDetailScreen(),
    createEvent: (_) => const CreateEventScreen(),
    editEvent: (_) => const EditEventScreen(),
  };
}
