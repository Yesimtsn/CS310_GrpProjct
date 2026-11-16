import 'package:flutter/material.dart';

/// Temporary body for screens that haven't been built yet.
/// Delete it once every screen is implemented.
class PlaceholderBody extends StatelessWidget {
  final String screen;
  final String owner;
  final List<Widget> actions;

  const PlaceholderBody({
    super.key,
    required this.screen,
    required this.owner,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(screen, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('TODO: $owner'),
            const SizedBox(height: 24),
            ...actions,
          ],
        ),
      ),
    );
  }
}
