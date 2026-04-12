import 'package:flutter/material.dart';
import 'package:feast/core/core.dart';

// ---------------------------------------------------------------------------
// JoinEventDialog
// ---------------------------------------------------------------------------
// Confirmation dialog shown when the user taps "JOIN US" on a charity event.
//
// Usage:
//   showDialog(
//     context: context,
//     builder: (_) => JoinEventDialog(
//       eventTitle: 'Flood Relief Project',
//       onConfirm: () { /* register user in Firestore */ },
//     ),
//   );
//
// FIREBASE INTEGRATION:
//   onConfirm: add the current user's UID to
//   `events/{eventId}/participants/{uid}` and increment participantCount.
// ---------------------------------------------------------------------------

class JoinEventDialog extends StatefulWidget {
  final String eventTitle;

  /// Called when the user accepts T&C and taps "Yes".
  final VoidCallback? onConfirm;

  const JoinEventDialog({
    super.key,
    required this.eventTitle,
    this.onConfirm,
  });

  @override
  State<JoinEventDialog> createState() => _JoinEventDialogState();
}

class _JoinEventDialogState extends State<JoinEventDialog> {
  bool _accepted = false;

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
                const Expanded(
                  child: Text(
                    'Join Event',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: feastBlack,
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

            const SizedBox(height: 8),

            Text(
              'Are you sure you want to join "${widget.eventTitle}"? You will be registered as a participant.',
              style: const TextStyle(
                fontFamily: 'Outfit',
                fontSize: 13,
                color: Colors.black54,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'NOTE: You will need to be physically present at the event location.',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: feastBlack,
              ),
            ),

            const SizedBox(height: 14),

            // ── T&C checkbox ─────────────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: Checkbox(
                    value: _accepted,
                    activeColor: feastGreen,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
                    onChanged: (v) =>
                        setState(() => _accepted = v ?? false),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      // TODO: open T&C screen / webview
                    },
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                        children: [
                          TextSpan(text: "I've read the "),
                          TextSpan(
                            text: 'terms and conditions',
                            style: TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          TextSpan(text: '.'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ── Buttons ──────────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildActionButton(
                  label: 'No',
                  backgroundColor: Colors.red,
                  onTap: () => Navigator.pop(context),
                ),
                const SizedBox(width: 8),
                _buildActionButton(
                  label: 'Yes',
                  backgroundColor: Colors.blue,
                  onTap: _accepted
                      ? () {
                          Navigator.pop(context);
                          widget.onConfirm?.call();
                        }
                      : null,
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
    VoidCallback? onTap,
  }) {
    final isDisabled = onTap == null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
        decoration: BoxDecoration(
          color: isDisabled
              ? backgroundColor.withAlpha(100)
              : backgroundColor,
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