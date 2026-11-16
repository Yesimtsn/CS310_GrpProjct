import 'package:flutter/material.dart';

import '../../widgets/placeholder_screen.dart';

/// Create event screen. See CS310_Group30_Step2.1 wireframes.
/// Owner: Yeşim Tosun
class CreateEventScreen extends StatelessWidget {
  const CreateEventScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create event')),
      body: PlaceholderBody(
        screen: 'Create event',
        owner: 'Yeşim Tosun',
        actions: [],
      ),
    );
  }
}
