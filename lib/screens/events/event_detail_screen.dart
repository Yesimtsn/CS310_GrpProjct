import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/app_user.dart';
import '../../models/event.dart';
import '../../routes.dart';
import '../../services/auth_service.dart';
import '../../services/event_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/date_format.dart';
import '../../widgets/confirmation_dialog.dart';
import '../../widgets/event_card.dart';
import '../../widgets/report_sheet.dart';

/// Event screen. See CS310_Group30_Step2.1 wireframes.
/// Owner: Yeşim Tosun
///
/// Route argument: the event id (String).
/// Organizer sees Edit + Cancel event; everyone else sees Join / Leave.
class EventDetailScreen extends StatelessWidget {
  const EventDetailScreen({super.key});

  void _snack(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _join(BuildContext context, Event event, String userId) {
    final error = context.read<EventService>().joinEvent(event.id, userId);
    _snack(
      context,
      error ?? 'You joined. Reminder set for 1 hour before the start.',
    );
  }

  Future<void> _leave(BuildContext context, Event event, String userId) async {
    final ok = await showConfirmationDialog(
      context: context,
      title: 'Leave this event?',
      message: 'You will be removed from the attendee list.',
      confirmLabel: 'Confirm',
      cancelLabel: 'Cancel',
    );
    if (!ok || !context.mounted) return;
    final error = context.read<EventService>().leaveEvent(event.id, userId);
    _snack(context, error ?? 'You left the event.');
  }

  Future<void> _cancelEvent(
    BuildContext context,
    Event event,
    String userId,
  ) async {
    final ok = await showConfirmationDialog(
      context: context,
      title: 'Cancel this event?',
      message: '${event.title} will be removed for everyone.',
      confirmLabel: 'Cancel event',
      cancelLabel: 'Keep',
      destructive: true,
    );
    if (!ok || !context.mounted) return;

    // Grab these before popping; this screen's context goes away after pop.
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final error = context.read<EventService>().cancelEvent(event.id, userId);
    if (error != null) {
      _snack(context, error);
      return;
    }
    navigator.pop();
    messenger.showSnackBar(const SnackBar(content: Text('Event cancelled')));
  }

  Future<void> _report(BuildContext context, Event event, String userId) async {
    final reason = await showReportSheet(context);
    if (reason == null || !context.mounted) return;
    final error = context.read<EventService>().reportEvent(
      event.id,
      userId,
      reason,
    );
    _snack(context, error ?? 'Report submitted');
  }

  @override
  Widget build(BuildContext context) {
    final id = ModalRoute.of(context)!.settings.arguments as String;
    final auth = context.watch<AuthService>();
    final event = context.watch<EventService>().eventById(id);
    final me = auth.currentUser;

    if (event == null || me == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Event')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Event not found'),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Go back'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final isOrganizer = event.isOrganizer(me.id);
    final organizer = auth.userById(event.organizerId);
    final attendees = auth.usersByIds(event.attendeeIds);
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event'),
        actions: [
          if (!isOrganizer)
            PopupMenuButton<String>(
              tooltip: 'More',
              onSelected: (_) => _report(context, event, me.id),
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'report', child: Text('Report event')),
              ],
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          EventCoverImage(imageUrl: event.imageUrl, height: 180),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: text.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                CategoryTag(label: event.category.label),
                const SizedBox(height: 16),
                _InfoRow(
                  icon: Icons.calendar_today_outlined,
                  text: DateFormatter.detail(event.dateTime),
                ),
                _InfoRow(icon: Icons.place_outlined, text: event.location),
                _InfoRow(
                  icon: Icons.person_outline,
                  text: 'Organizer: ${organizer?.fullName ?? 'Unknown'}',
                ),
                _InfoRow(
                  icon: Icons.group_outlined,
                  text: event.capacityLabel,
                  trailing: event.isFull ? const _FullBadge() : null,
                ),
                if (event.description.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(event.description, style: text.bodyMedium),
                ],
                const SizedBox(height: 24),
                Text(
                  'Attendees',
                  style: text.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                for (final user in attendees)
                  _AttendeeTile(
                    user: user,
                    isOrganizer: user.id == event.organizerId,
                  ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: isOrganizer
              ? Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pushNamed(
                          context,
                          AppRoutes.editEvent,
                          arguments: event.id,
                        ),
                        child: const Text('Edit'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.error,
                        ),
                        onPressed: () => _cancelEvent(context, event, me.id),
                        child: const Text('Cancel event'),
                      ),
                    ),
                  ],
                )
              : _JoinLeaveButton(
                  event: event,
                  isAttending: event.isAttending(me.id),
                  onJoin: () => _join(context, event, me.id),
                  onLeave: () => _leave(context, event, me.id),
                ),
        ),
      ),
    );
  }
}

/// Join when not attending, Leave when attending, disabled when full or started.
class _JoinLeaveButton extends StatelessWidget {
  final Event event;
  final bool isAttending;
  final VoidCallback onJoin;
  final VoidCallback onLeave;

  const _JoinLeaveButton({
    required this.event,
    required this.isAttending,
    required this.onJoin,
    required this.onLeave,
  });

  @override
  Widget build(BuildContext context) {
    if (isAttending) {
      return OutlinedButton(onPressed: onLeave, child: const Text('Leave'));
    }
    if (event.isPast) {
      return const FilledButton(
        onPressed: null,
        child: Text('Event has started'),
      );
    }
    if (event.isFull) {
      return const FilledButton(onPressed: null, child: Text('Event is full'));
    }
    return FilledButton(onPressed: onJoin, child: const Text('Join'));
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Widget? trailing;

  const _InfoRow({required this.icon, required this.text, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary),
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 8), trailing!],
        ],
      ),
    );
  }
}

class _AttendeeTile extends StatelessWidget {
  final AppUser user;
  final bool isOrganizer;

  const _AttendeeTile({required this.user, required this.isOrganizer});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primaryLight,
            child: Text(
              user.initial,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isOrganizer ? '${user.fullName} (organizer)' : user.shortName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _FullBadge extends StatelessWidget {
  const _FullBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.error,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        'FULL',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
