import 'package:flutter/material.dart';

/// DonateModal
/// Verifies the user's willingness to donate to an aid request.
/// Covers two variants with a shared Terms & Conditions checkbox:
///   - Donate Funds  (no extra note)
///   - Donate Items  (has a bold physical-delivery note)
///
/// Parameters:
///   [title]        — Dialog title. Defaults to "Donate Funds".
///   [aidRequestName] — Name of the aid request shown in the body text.
///   [boldNote]     — Optional bold note (e.g. "NOTE: You will have to deliver these items physically.").
///   [termsUrl]     — URL for the "terms and conditions" link.
///   [onTermsTap]   — Callback when the terms link is tapped.
///   [onNo]         — Callback when No is tapped (defaults to pop).
///   [onYes]        — Callback when Yes is tapped (only called if T&C is checked).
///
/// Usage:
/// ```dart
/// // Donate Funds
/// showDialog(
///   context: context,
///   builder: (_) => DonateModal(
///     title: 'Donate Funds',
///     aidRequestName: 'Surgery Meds & Treatment',
///     onYes: () { /* proceed with funds donation */ },
///   ),
/// );
///
/// // Donate Items
/// showDialog(
///   context: context,
///   builder: (_) => DonateModal(
///     title: 'Donate Items',
///     aidRequestName: 'Surgery Meds & Treatment',
///     boldNote: 'NOTE: You will have to deliver these items physically.',
///     onYes: () { /* open item donation modal */ },
///   ),
/// );
/// ```
class DonateModal extends StatefulWidget {
  final String title;
  final String aidRequestName;
  final String? boldNote;
  final String? termsUrl;
  final VoidCallback? onTermsTap;
  final VoidCallback? onNo;
  final VoidCallback? onYes;

  const DonateModal({
    super.key,
    this.title = 'Donate Funds',
    this.aidRequestName = 'Aid Request Name',
    this.boldNote,
    this.termsUrl,
    this.onTermsTap,
    this.onNo,
    this.onYes,
  });

  @override
  State<DonateModal> createState() => _DonateModalState();
}

class _DonateModalState extends State<DonateModal> {
  bool _termsAccepted = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title + close
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed:
                      widget.onNo ?? () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Body
            Text(
              'We wish to verify whether or not you are willing to donate to the '
              '"${widget.aidRequestName}" aid request. Do you wish to proceed?',
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),

            // Bold note
            if (widget.boldNote != null) ...[
              const SizedBox(height: 6),
              Text(
                widget.boldNote!,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],

            const SizedBox(height: 14),

            // Terms & Conditions checkbox
            Row(
              children: [
                Checkbox(
                  value: _termsAccepted,
                  onChanged: (v) =>
                      setState(() => _termsAccepted = v ?? false),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3)),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () =>
                        setState(() => _termsAccepted = !_termsAccepted),
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                            fontSize: 13, color: Colors.black87),
                        children: [
                          const TextSpan(text: "I've read the "),
                          WidgetSpan(
                            child: GestureDetector(
                              onTap: widget.onTermsTap,
                              child: const Text(
                                'terms and conditions',
                                style: TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                  fontSize: 13,
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
            const SizedBox(height: 16),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 22, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed:
                      widget.onNo ?? () => Navigator.of(context).pop(),
                  child: const Text('No'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _termsAccepted ? Colors.blue : Colors.grey,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 22, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed:
                      _termsAccepted ? widget.onYes : null,
                  child: const Text('Yes'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}