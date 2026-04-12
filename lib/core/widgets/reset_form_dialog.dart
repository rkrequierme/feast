import 'package:flutter/material.dart';
import 'package:feast/core/core.dart';

// ---------------------------------------------------------------------------
// ResetFormDialog
// ---------------------------------------------------------------------------
// Confirmation dialog shown before resetting a form's field data.
//
// Usage:
//   showDialog(
//     context: context,
//     builder: (_) => ResetFormDialog(
//       onConfirm: () { /* clear all form fields */ },
//     ),
//   );
// ---------------------------------------------------------------------------

class ResetFormDialog extends StatelessWidget {
  /// Called when the user taps "Yes".
  final VoidCallback? onConfirm;

  /// Override the body text if needed. Defaults to a generic message.
  final String? bodyText;

  const ResetFormDialog({
    super.key,
    this.onConfirm,
    this.bodyText,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: feastBlack,
                      ),
                      children: [
                        TextSpan(
                          text: 'Reset ',
                          style: TextStyle(color: Colors.red),
                        ),
                        TextSpan(text: 'Form'),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close,
                      size: 20, color: Colors.black45),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Text(
              bodyText ??
                  'Are you sure you want to reset the contents or field data of this form?',
              style: const TextStyle(
                fontFamily: 'Outfit',
                fontSize: 13,
                color: Colors.black54,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 20),

            // ── Buttons ──────────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildActionButton(
                  label: 'No',
                  backgroundColor: Colors.black87,
                  onTap: () => Navigator.pop(context),
                ),
                const SizedBox(width: 8),
                _buildActionButton(
                  label: 'Yes',
                  backgroundColor: Colors.red,
                  onTap: () {
                    Navigator.pop(context);
                    onConfirm?.call();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'Outfit',
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// UnsavedChangesDialog
// ---------------------------------------------------------------------------
// Shown when the user tries to leave a form screen with unsaved changes.
// Intercept the back gesture via PopScope and call this dialog.
//
// Usage:
//   showDialog(
//     context: context,
//     builder: (_) => UnsavedChangesDialog(
//       onLeave: () => Navigator.pop(context),
//     ),
//   );
// ---------------------------------------------------------------------------

class UnsavedChangesDialog extends StatelessWidget {
  /// Called when the user confirms they want to leave without saving.
  final VoidCallback? onLeave;

  const UnsavedChangesDialog({super.key, this.onLeave});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: feastBlack,
                      ),
                      children: [
                        TextSpan(
                          text: 'Unsaved ',
                          style: TextStyle(color: Colors.red),
                        ),
                        TextSpan(text: 'Changes'),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close,
                      size: 20, color: Colors.black45),
                ),
              ],
            ),

            const SizedBox(height: 10),

            const Text(
              'You have unsaved changes. If you leave now, all unsaved progress will be lost.',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 13,
                color: Colors.black54,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'Save your draft first to keep your progress.',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: feastBlack,
              ),
            ),

            const SizedBox(height: 20),

            // ── Buttons ──────────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildActionButton(
                  label: 'Stay',
                  backgroundColor: Colors.black87,
                  onTap: () => Navigator.pop(context),
                ),
                const SizedBox(width: 8),
                _buildActionButton(
                  label: 'Leave',
                  backgroundColor: Colors.red,
                  onTap: () {
                    Navigator.pop(context); // close dialog
                    onLeave?.call();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'Outfit',
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}