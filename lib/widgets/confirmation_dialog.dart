import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Shared confirmation dialog (2.1 "Confirmation dialog" wireframe).
/// Returns true only when the user taps the confirm button.
/// Leave [cancelLabel] null for a single-button info dialog (e.g. "Event created").
Future<bool> showConfirmationDialog({
  required BuildContext context,
  required String title,
  required String message,
  String confirmLabel = 'OK',
  String? cancelLabel,
  bool destructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: cancelLabel != null,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(child: Text(message)),
      actions: [
        if (cancelLabel != null)
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(cancelLabel),
          ),
        FilledButton(
          // The theme gives FilledButton full width; keep it compact in dialogs.
          style: FilledButton.styleFrom(
            minimumSize: const Size(88, 40),
            backgroundColor: destructive ? AppColors.error : null,
          ),
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  // Back button / tap outside counts as "not confirmed".
  return result ?? false;
}
