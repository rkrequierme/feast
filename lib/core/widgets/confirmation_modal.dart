import 'package:flutter/material.dart';

/// ConfirmationModal
/// A flexible Yes/No confirmation dialog used across multiple flows:
///   - Reset Form          (titleColor: red, has subtitle)
///   - Create Aid Request  (bold warning note in body)
///   - Disable Notifications (simple question)
///   - Remove Group Member (title highlights a name in red)
///
/// Parameters:
///   [title]         — Main title text.
///   [titlePrefix]   — Optional colored prefix word shown before [title]
///                     (e.g. "Reset" in red). Leave null to skip.
///   [titlePrefixColor] — Color for [titlePrefix]. Defaults to red.
///   [body]          — Main body/question text.
///   [boldNote]      — Optional bold note appended after [body].
///   [noLabel]       — Label for the "No" button. Defaults to "No".
///   [yesLabel]      — Label for the "Yes" button. Defaults to "Yes".
///   [onNo]          — Callback when No is tapped (defaults to pop).
///   [onYes]         — Callback when Yes is tapped.
///   [isScrollable]  — Wraps content in SingleChildScrollView when true.
///
/// Usage:
/// ```dart
/// // Reset Form
/// showDialog(
///   context: context,
///   builder: (_) => ConfirmationModal(
///     titlePrefix: 'Reset',
///     title: 'Form',
///     body: 'Are you sure you want to reset the contents or field data of this request form?',
///     onYes: () { /* reset logic */ },
///   ),
/// );
///
/// // Create Aid Request
/// showDialog(
///   context: context,
///   builder: (_) => ConfirmationModal(
///     title: 'Create Aid Request',
///     body: 'Are you sure you want to proceed with posting the aid request.',
///     boldNote: 'REMEMBER: You cannot edit your post or take it down after a certain amount of time has passed.',
///     onYes: () { /* submit logic */ },
///   ),
/// );
///
/// // Disable Notifications
/// showDialog(
///   context: context,
///   builder: (_) => ConfirmationModal(
///     title: 'Disable Notifications',
///     body: 'Are you sure you want to disable group notifications?',
///     onYes: () { /* disable logic */ },
///   ),
/// );
///
/// // Remove Group Member
/// showDialog(
///   context: context,
///   builder: (_) => ConfirmationModal(
///     titlePrefix: 'Remove',
///     title: 'Adina Santos',
///     body: 'Are you sure you want to remove this group member?',
///     onYes: () { /* remove logic */ },
///   ),
/// );
/// ```
class ConfirmationModal extends StatelessWidget {
  final String? titlePrefix;
  final Color titlePrefixColor;
  final String title;
  final String body;
  final String? boldNote;
  final String noLabel;
  final String yesLabel;
  final VoidCallback? onNo;
  final VoidCallback? onYes;
  final bool isScrollable;

  const ConfirmationModal({
    super.key,
    this.titlePrefix,
    this.titlePrefixColor = Colors.red,
    required this.title,
    required this.body,
    this.boldNote,
    this.noLabel = 'No',
    this.yesLabel = 'Yes',
    this.onNo,
    this.onYes,
    this.isScrollable = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  children: [
                    if (titlePrefix != null) ...[
                      TextSpan(
                        text: '$titlePrefix ',
                        style: TextStyle(color: titlePrefixColor),
                      ),
                    ],
                    TextSpan(text: title),
                  ],
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Body text
        Text(body, style: const TextStyle(fontSize: 14, color: Colors.black87)),

        // Bold note (optional)
        if (boldNote != null) ...[
          const SizedBox(height: 8),
          Text(
            boldNote!,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],

        const SizedBox(height: 20),

        // Buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _buildButton(
              label: noLabel,
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              onTap: onNo ?? () => Navigator.of(context).pop(),
            ),
            const SizedBox(width: 10),
            _buildButton(
              label: yesLabel,
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              onTap: onYes ?? () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ],
    );

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: isScrollable
            ? SingleChildScrollView(child: content)
            : content,
      ),
    );
  }

  Widget _buildButton({
    required String label,
    required Color backgroundColor,
    required Color foregroundColor,
    required VoidCallback? onTap,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: onTap,
      child: Text(label, style: const TextStyle(fontSize: 14)),
    );
  }
}