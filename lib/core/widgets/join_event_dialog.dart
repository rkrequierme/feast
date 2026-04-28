// lib/core/widgets/join_event_dialog.dart
//
// Confirmation dialog shown when the user taps "JOIN US" on a charity event.
//
// The screen calls it as:
//   JoinEventDialog(onConfirm: () async { ... })
// so eventTitle must NOT be required — it has a sensible default.

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_routes.dart';

class JoinEventDialog extends StatefulWidget {
  /// Display name of the event shown in the confirmation body.
  /// Optional — screens may omit it and it gracefully defaults.
  final String eventTitle;

  /// Called when the user accepts T&C and taps "Yes".
  final VoidCallback? onConfirm;

  const JoinEventDialog({
    super.key,
    this.eventTitle = 'this event', // ← default so callers can omit it
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
            // ── Header ────────────────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(
                  child: Text(
                    'Join Charity Event?',
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
              'Are you sure you want to join "${widget.eventTitle}"?\n'
              'You will be registered as a participant pending admin confirmation.',
              style: const TextStyle(
                fontFamily: 'Outfit',
                fontSize: 13,
                color: Colors.black54,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'NOTE: You must be physically present at the event location.',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: feastBlack,
              ),
            ),

            const SizedBox(height: 14),

            // ── T&C checkbox ──────────────────────────────────────────────
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
                    onTap: () =>
                        setState(() => _accepted = !_accepted),
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                        children: [
                          const TextSpan(text: "I've read the "),
                          WidgetSpan(
                            child: GestureDetector(
                              onTap: () => Navigator.pushNamed(
                                  context, AppRoutes.legal),
                              child: const Text(
                                'terms and conditions',
                                style: TextStyle(
                                  color: feastBlue,
                                  decoration:
                                      TextDecoration.underline,
                                  fontFamily: 'Outfit',
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          const TextSpan(text: '.'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ── Buttons ───────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _btn(
                  label: 'No',
                  color: Colors.red,
                  onTap: () => Navigator.pop(context),
                ),
                const SizedBox(width: 8),
                _btn(
                  label: 'Yes',
                  color: feastBlue,
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

  Widget _btn({
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    final disabled = onTap == null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        decoration: BoxDecoration(
          color: disabled ? color.withAlpha(100) : color,
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
