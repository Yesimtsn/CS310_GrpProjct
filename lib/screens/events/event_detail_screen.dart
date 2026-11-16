import 'package:flutter/material.dart';

import '../../widgets/placeholder_screen.dart';

/// Event screen. See CS310_Group30_Step2.1 wireframes.
/// Owner: Yeşim Tosun
class EventDetailScreen extends StatelessWidget {
  const EventDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Event')),
      body: PlaceholderBody(screen: 'Event', owner: 'Yeşim Tosun', actions: []),
    );
  }
}
