import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// disable_notification_dialog.dart
//
// FIX (Image 5): SelectedGroupScreen called:
//   DisableNotificationDialog(onConfirm: () {})
// But widget only defined `onYes` — `onConfirm` was undefined.
//
// SOLUTION: Added `onConfirm` as an alias for `onYes`.
// Both are accepted so neither caller breaks.
//
// Used in two places:
//   • Settings screen  → global app-notification toggle
//   • SelectedGroupScreen → per-group notification mute
// ─────────────────────────────────────────────────────────────────────────────

class DisableNotificationDialog extends StatelessWidget {
  /// Primary callback — used by SelectedGroupScreen (fixes Image 5).
  final VoidCallback? onConfirm;

  /// Alias kept so Settings screen usage (onYes:) still compiles.
  final VoidCallback? onYes;

  final VoidCallback? onNo;

  /// When true, shows "Disable Notifications" messaging.
  /// When false, shows "Enable Notifications" messaging.
  final bool isDisabling;

  const DisableNotificationDialog({
    super.key,
    this.onConfirm,
    this.onYes,
    this.onNo,
    this.isDisabling = true,
  });

  @override
  Widget build(BuildContext context) {
    final action = isDisabling ? 'Disable' : 'Enable';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Title Row ──────────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    '$action App Notifications',
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
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

            // ── Body ──────────────────────────────────────────────────
            Text(
              'Are you sure you want to $action app notifications?',
              style: const TextStyle(
                fontFamily: 'Outfit',
                fontSize: 14,
                color: feastGray,
              ),
            ),
            const SizedBox(height: 24),

            // ── Buttons ───────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // No
                _ActionButton(
                  label: 'No',
                  color: feastWarning,
                  onTap: onNo ?? () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 10),
                // Yes — resolves both onConfirm and onYes
                _ActionButton(
                  label: 'Yes',
                  color: feastBlue,
                  onTap: () {
                    Navigator.of(context).pop();
                    // Prefer onConfirm (new); fall back to onYes (legacy)
                    (onConfirm ?? onYes)?.call();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Outfit',
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
