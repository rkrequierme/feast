import 'package:flutter/material.dart';
import 'package:feast/core/core.dart';

// ---------------------------------------------------------------------------
// DonateItemsDialog
// ---------------------------------------------------------------------------
// Step 1 confirmation shown when the user taps "GIVE ITEMS".
// On "Yes" -> show ItemDonationDialog.
//
// Usage:
//   showDialog(
//     context: context,
//     builder: (_) => DonateItemsDialog(
//       requestTitle: 'Surgery Meds & Treatment',
//       onConfirm: () { /* show ItemDonationDialog */ },
//     ),
//   );
// ---------------------------------------------------------------------------

class DonateItemsDialog extends StatefulWidget {
  final String requestTitle;

  /// Called when the user accepts T&C and taps "Yes".
  final VoidCallback? onConfirm;

  const DonateItemsDialog({
    super.key,
    required this.requestTitle,
    this.onConfirm,
  });

  @override
  State<DonateItemsDialog> createState() => _DonateItemsDialogState();
}

class _DonateItemsDialogState extends State<DonateItemsDialog> {
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
                    'Donate Items',
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
              'We wish to verify whether or not you are willing to donate items to the "${widget.requestTitle}" aid request. Do you wish to proceed?',
              style: const TextStyle(
                fontFamily: 'Outfit',
                fontSize: 13,
                color: Colors.black54,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'NOTE: You will have to deliver these items physically.',
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
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
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