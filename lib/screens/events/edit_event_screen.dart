import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/event.dart';
import '../../services/auth_service.dart';
import '../../services/event_service.dart';
import '../../widgets/confirmation_dialog.dart';
import '../../widgets/event_form.dart';

/// Edit Event (2.1 "Edit Event" wireframe): the Create form pre-filled with
/// the event's data. Opened by the organizer from Event Detail.
/// Owner: Yeşim Tosun
class EditEventScreen extends StatelessWidget {
  const EditEventScreen({super.key});

  Future<void> _save(
    BuildContext context,
    Event event,
    String userId,
    EventFormData data,
  ) async {
    final error = context.read<EventService>().updateEvent(
      eventId: event.id,
      userId: userId,
      title: data.title,
      category: data.category,
      dateTime: data.dateTime,
      location: data.location,
      maxParticipants: data.maxParticipants,
      description: data.description,
    );
    if (error != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    await showConfirmationDialog(
      context: context,
      title: 'Changes saved',
      message: '${data.title} has been updated.',
    );
    if (!context.mounted) return;
    Navigator.pop(context); // back to Event Detail
  }

  @override
  Widget build(BuildContext context) {
    final id = ModalRoute.of(context)!.settings.arguments as String;
    // read, not watch: the form keeps its own state while the user types.
    final event = context.read<EventService>().eventById(id);
    final me = context.read<AuthService>().currentUser;

    if (event == null || me == null) {
      return const _MessageScaffold(message: 'Event not found');
    }
    if (!event.isOrganizer(me.id)) {
      return const _MessageScaffold(
        message: 'Only the organizer can edit this event',
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Edit event')),
      body: SafeArea(
        child: EventForm(
          initialEvent: event,
          submitLabel: 'Save changes',
          onSubmit: (data) => _save(context, event, me.id, data),
        ),
      ),
    );
  }
}

/// Shown instead of the form when the event can't be edited.
class _MessageScaffold extends StatelessWidget {
  final String message;
  const _MessageScaffold({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit event')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              OutlinedButton(
                style: OutlinedButton.styleFrom(minimumSize: const Size(120, 44)),
                onPressed: () => Navigator.pop(context),
                child: const Text('Go back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
