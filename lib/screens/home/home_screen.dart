import 'package:flutter/material.dart';

import '../../routes.dart';
import '../../widgets/placeholder_screen.dart';

/// Home screen. See CS310_Group30_Step2.1 wireframes.
/// Owner: Burak Ala
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: PlaceholderBody(
        screen: 'Home',
        owner: 'Burak Ala',
        actions: [
          FilledButton(
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.createEvent),
            child: const Text('+ Create event'),
          ),
        ],
      ),
    );
  }
}
