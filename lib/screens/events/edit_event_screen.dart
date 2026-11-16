import 'package:flutter/material.dart';

import '../../widgets/placeholder_screen.dart';

/// Edit event screen. See CS310_Group30_Step2.1 wireframes.
/// Owner: TBD
class EditEventScreen extends StatelessWidget {
  const EditEventScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit event')),
      body: PlaceholderBody(screen: 'Edit event', owner: 'TBD', actions: []),
    );
  }
}
