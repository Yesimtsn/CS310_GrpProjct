import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/event.dart';
import '../../routes.dart';
import '../../services/auth_service.dart';
import '../../services/event_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/date_format.dart';
import '../../widgets/confirmation_dialog.dart';

/// My Events screen: Joined and Created tabs, each event a card with a
/// Leave / Cancel event action. See CS310_Group30_Step2.1 wireframes.
/// Owner: Burak Ala
class MyEventsScreen extends StatelessWidget {
  const MyEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final me = context.watch<AuthService>().currentUser;
    final events = context.watch<EventService>();
    final joined = me == null ? <Event>[] : events.joinedEvents(me.id);
    final created = me == null ? <Event>[] : events.createdEvents(me.id);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Events'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Joined'),
              Tab(text: 'Created'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _EventList(
              events: joined,
              emptyText: 'You have not joined any events yet.',
              actionLabel: 'Leave',
              onAction: (e) => _leave(context, e, me!.id),
            ),
            _EventList(
              events: created,
              emptyText: 'You have not created any events yet.',
              actionLabel: 'Cancel event',
              onAction: (e) => _cancel(context, e, me!.id),
            ),
          ],
        ),
      ),
    );
  }

  void _snack(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _leave(BuildContext context, Event event, String userId) async {
    final ok = await showConfirmationDialog(
      context: context,
      title: 'Leave this event?',
      message: 'You will be removed from ${event.title}.',
      confirmLabel: 'Leave',
      cancelLabel: 'Cancel',
      destructive: true,
    );
    if (!ok || !context.mounted) return;
    final error = context.read<EventService>().leaveEvent(event.id, userId);
    _snack(context, error ?? 'You left the event.');
  }

  Future<void> _cancel(BuildContext context, Event event, String userId) async {
    final ok = await showConfirmationDialog(
      context: context,
      title: 'Cancel this event?',
      message: '${event.title} will be removed for everyone.',
      confirmLabel: 'Cancel event',
      cancelLabel: 'Keep',
      destructive: true,
    );
    if (!ok || !context.mounted) return;
    final error = context.read<EventService>().cancelEvent(event.id, userId);
    _snack(context, error ?? 'Event cancelled.');
  }
}

class _EventList extends StatelessWidget {
  final List<Event> events;
  final String emptyText;
  final String actionLabel;
  final void Function(Event) onAction;

  const _EventList({
    required this.events,
    required this.emptyText,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            emptyText,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: AppColors.textSecondary),
          ),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: events.length,
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      itemBuilder: (context, i) => _MyEventCard(
        event: events[i],
        actionLabel: actionLabel,
        onAction: () => onAction(events[i]),
      ),
    );
  }
}

/// Compact card: title, time | place, joined / capacity and one action.
class _MyEventCard extends StatelessWidget {
  final Event event;
  final String actionLabel;
  final VoidCallback onAction;

  const _MyEventCard({
    required this.event,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.pushNamed(
          context,
          AppRoutes.eventDetail,
          arguments: event.id,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.title,
                style: text.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${DateFormatter.card(event.dateTime)}  |  ${event.location}',
                style: text.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      event.capacityLabel,
                      style: text.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  OutlinedButton(
                    onPressed: onAction,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(88, 40),
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                    ),
                    child: Text(actionLabel),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
