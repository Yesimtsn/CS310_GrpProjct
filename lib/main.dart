import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'routes.dart';
import 'services/auth_service.dart';
import 'services/event_service.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const SuMeetApp());
}

class SuMeetApp extends StatelessWidget {
  const SuMeetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => EventService()),
      ],
      child: MaterialApp(
        title: 'SuMeet',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        initialRoute: AppRoutes.login,
        routes: AppRoutes.table,
      ),
    );
  }
}
