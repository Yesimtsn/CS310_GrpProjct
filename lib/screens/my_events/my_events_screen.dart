import 'package:flutter/material.dart';

import '../../widgets/placeholder_screen.dart';

/// My Events screen. See CS310_Group30_Step2.1 wireframes.
/// Owner: TBD
class MyEventsScreen extends StatelessWidget {
  const MyEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Events')),
      body: PlaceholderBody(screen: 'My Events', owner: 'TBD', actions: []),
    );
  }
}
