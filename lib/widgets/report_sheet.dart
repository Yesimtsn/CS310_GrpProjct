import 'package:flutter/material.dart';

import '../models/event_report.dart';

/// "Report event" bottom sheet (2.1 wireframe).
/// Returns the chosen [ReportReason], or null if the sheet is closed.
Future<ReportReason?> showReportSheet(BuildContext context) {
  return showModalBottomSheet<ReportReason>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => const _ReportSheet(),
  );
}

class _ReportSheet extends StatefulWidget {
  const _ReportSheet();

  @override
  State<_ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends State<_ReportSheet> {
  ReportReason _reason = ReportReason.spam;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Report event',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            RadioGroup<ReportReason>(
              groupValue: _reason,
              onChanged: (v) {
                if (v != null) setState(() => _reason = v);
              },
              child: Column(
                children: [
                  for (final r in ReportReason.values)
                    RadioListTile<ReportReason>(
                      value: r,
                      title: Text(r.label),
                      contentPadding: EdgeInsets.zero,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () => Navigator.pop(context, _reason),
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
