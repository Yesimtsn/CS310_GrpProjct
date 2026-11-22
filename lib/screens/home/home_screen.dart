import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/event.dart';
import '../../routes.dart';
import '../../services/event_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/event_card.dart';

/// Home screen (event feed). See CS310_Group30_Step2.1 wireframes.
/// Owner: Burak Ala
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// null = "All".
  EventCategory? _category;
  DateFilter _date = DateFilter.any;

  /// Search bar text; matched against title, location and description.
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchCtrl.clear();
    setState(() => _query = '');
  }

  @override
  Widget build(BuildContext context) {
    final events = context.watch<EventService>().filteredEvents(
      category: _category,
      date: _date,
      query: _query,
    );

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/images/logo.png',
                width: 32,
                height: 32,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'SuMeet',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Create event',
        onPressed: () => Navigator.pushNamed(context, AppRoutes.createEvent),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _query = v),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search events or places',
                isDense: true,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear search',
                        icon: const Icon(Icons.close),
                        onPressed: _clearSearch,
                      ),
              ),
            ),
          ),
          _FilterRow(
            labels: ['All', ...EventCategory.values.map((c) => c.label)],
            selected: _category == null ? 0 : _category!.index + 1,
            onSelected: (i) => setState(
              () => _category = i == 0 ? null : EventCategory.values[i - 1],
            ),
          ),
          _FilterRow(
            labels: DateFilter.values.map((d) => d.label).toList(),
            selected: _date.index,
            onSelected: (i) => setState(() => _date = DateFilter.values[i]),
          ),
          Expanded(
            child: events.isEmpty
                ? _EmptyState(searching: _query.trim().isNotEmpty)
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
                    itemCount: events.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 16),
                    itemBuilder: (context, i) {
                      final event = events[i];
                      return EventCard(
                        event: event,
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.eventDetail,
                          arguments: event.id,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/// Horizontally scrollable single-select chip row.
class _FilterRow extends StatelessWidget {
  final List<String> labels;
  final int selected;
  final ValueChanged<int> onSelected;

  const _FilterRow({
    required this.labels,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        itemCount: labels.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final isSelected = i == selected;
          return ChoiceChip(
            label: Text(labels[i]),
            selected: isSelected,
            showCheckmark: false,
            onSelected: (_) => onSelected(i),
            backgroundColor: AppColors.surface,
            selectedColor: AppColors.primary,
            side: BorderSide(
              color: isSelected ? AppColors.primary : AppColors.border,
            ),
            shape: const StadiumBorder(),
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool searching;
  const _EmptyState({required this.searching});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.event_busy_outlined,
              size: 48,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 12),
            Text(
              searching
                  ? 'No events match your search.'
                  : 'No events match these filters.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
