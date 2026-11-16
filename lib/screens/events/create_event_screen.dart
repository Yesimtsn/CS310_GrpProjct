import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/auth_service.dart';
import '../../services/event_service.dart';
import '../../widgets/confirmation_dialog.dart';
import '../../widgets/event_form.dart';

class CreateEventScreen extends StatelessWidget {
  const CreateEventScreen({super.key});

  Future<void> _create(BuildContext context, EventFormData data) async {
    final me = context.read<AuthService>().currentUser;
    if (me == null) return; // not logged in; can't happen after Login

    final event = context.read<EventService>().createEvent(
      organizerId: me.id,
      title: data.title,
      category: data.category,
      dateTime: data.dateTime,
      location: data.location,
      maxParticipants: data.maxParticipants,
      description: data.description,
      
    );

    await showConfirmationDialog(
      context: context,
      title: 'Event created',
      message: '${event.title} is now visible to everyone.',
    );
    if (!context.mounted) return;
    Navigator.pop(context); // back to Home
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create event')),
      body: SafeArea(
        child: EventForm(
          submitLabel: 'Create event',
          onSubmit: (data) => _create(context, data),
        ),
      ),
    );
  }
}
