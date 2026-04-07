import 'package:flutter/material.dart';

/// DeleteRemoveModal
/// Displays a destructive-action confirmation with a trash icon.
/// Covers two variants:
///   - Delete (e.g. "Delete Notification" — has an undoable warning)
///   - Remove (e.g. "Remove Bookmark" — simpler confirmation)
///
/// Parameters:
///   [title]          — Dialog title (e.g. "Delete Notification").
///   [body]           — Confirmation question text.
///   [actionLabel]    — Label for the destructive button. Defaults to "Delete".
///   [cancelLabel]    — Label for the cancel button. Defaults to "Cancel".
///   [actionColor]    — Background color of the action button. Defaults to red.
///   [onAction]       — Callback when the destructive action button is tapped.
///   [onCancel]       — Callback when Cancel is tapped (defaults to pop).
///
/// Usage:
/// ```dart
/// // Delete variant
/// showDialog(
///   context: context,
///   builder: (_) => DeleteRemoveModal(
///     title: 'Delete Notification',
///     body: 'Are you sure you want to delete this bookmark? This action cannot be undone.',
///     actionLabel: 'Delete',
///     onAction: () { /* delete logic */ },
///   ),
/// );
///
/// // Remove variant
/// showDialog(
///   context: context,
///   builder: (_) => DeleteRemoveModal(
///     title: 'Remove Bookmark',
///     body: 'Are you sure you want to remove this bookmark?',
///     actionLabel: 'Remove',
///     onAction: () { /* remove logic */ },
///   ),
/// );
/// ```
class DeleteRemoveModal extends StatelessWidget {
  final String title;
  final String body;
  final String actionLabel;
  final String cancelLabel;
  final Color actionColor;
  final VoidCallback? onAction;
  final VoidCallback? onCancel;

  const DeleteRemoveModal({
    super.key,
    required this.title,
    required this.body,
    this.actionLabel = 'Delete',
    this.cancelLabel = 'Cancel',
    this.actionColor = Colors.red,
    this.onAction,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Close button top-right
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),

            // Trash icon
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.delete_outline, color: Colors.red.shade400, size: 26),
            ),
            const SizedBox(height: 14),

            // Title
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Body
            Text(body, style: const TextStyle(fontSize: 14, color: Colors.black87)),
            const SizedBox(height: 20),

            // Action button (full-width)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: actionColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: onAction,
                child: Text(actionLabel, style: const TextStyle(fontSize: 15)),
              ),
            ),
            const SizedBox(height: 10),

            // Cancel button (full-width)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: onCancel ?? () => Navigator.of(context).pop(),
                child: Text(cancelLabel, style: const TextStyle(fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}