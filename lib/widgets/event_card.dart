import 'package:flutter/material.dart';

import '../models/event.dart';
import '../theme/app_theme.dart';
import '../utils/date_format.dart';

/// Event card shown in the feed (cover, title, category, time | place,
/// joined / capacity, FULL badge). Same look wherever it appears.
class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback onTap;

  const EventCard({super.key, required this.event, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            EventCoverImage(imageUrl: event.imageUrl, height: 140),
            Padding(
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
                  const SizedBox(height: 8),
                  CategoryTag(label: event.category.label),
                  const SizedBox(height: 8),
                  Text(
                    '${DateFormatter.card(event.dateTime)}  |  ${event.location}',
                    style: text.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
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
                      if (event.isFull) const _FullBadge(),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Cover image: network URL, asset path, or the shared placeholder.
class EventCoverImage extends StatelessWidget {
  static const placeholderAsset = 'assets/images/event_placeholder.png';

  final String? imageUrl;
  final double height;

  const EventCoverImage({super.key, this.imageUrl, required this.height});

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    final Widget image;
    if (url == null || url.isEmpty) {
      image = Image.asset(placeholderAsset, fit: BoxFit.cover);
    } else if (url.startsWith('http')) {
      image = Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) =>
            Image.asset(placeholderAsset, fit: BoxFit.cover),
      );
    } else {
      image = Image.asset(url, fit: BoxFit.cover);
    }
    return SizedBox(height: height, width: double.infinity, child: image);
  }
}

/// Light-blue category pill.
class CategoryTag extends StatelessWidget {
  final String label;
  const CategoryTag({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium
            ?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w500),
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
        style: Theme.of(context).textTheme.labelSmall
            ?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
      ),
    );
  }
}
