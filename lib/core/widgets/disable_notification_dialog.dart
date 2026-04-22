import 'package:flutter/material.dart';
import 'package:feast/core/core.dart';

/// Dialog shown when the user taps "Turn On/Off App Notifications"
/// in the Settings screen.
///
/// Usage:
/// ```dart
/// showDialog(
///   context: context,
///   builder: (_) => DisableNotificationDialog(
///     onYes: () { /* disable logic */ },
///   ),
/// );
/// ```
class DisableNotificationDialog extends StatelessWidget {
  final VoidCallback? onYes;
  final VoidCallback? onNo;

  const DisableNotificationDialog({
    super.key,
    this.onYes,
    this.onNo,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Title Row ───
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(
                  child: Text(
                    'Disable App Notifications',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Outfit',
                      color: feastBlack,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(Icons.close, size: 22, color: feastBlack),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // ─── Body ───
            const Text(
              'Are you sure you want to disable app notifications?',
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Outfit',
                color: feastGray,
              ),
            ),
            const SizedBox(height: 24),

            // ─── Buttons ───
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // No Button
                ElevatedButton(
                  onPressed: onNo ?? () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: feastWarning,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'No',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Yes Button
                ElevatedButton(
                  onPressed: onYes ?? () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: feastBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Yes',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
