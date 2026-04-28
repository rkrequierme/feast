import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// report_modal.dart
//
// Unified report form. Covers:
//   • Reporting aid requests  (from SelectedAidRequestScreen)
//   • Reporting charity events
//   • Reporting messages / users
//
// Replaces AND removes:
//   • report_content_dialog.dart  (same UI, just a different class name)
//   • The old report_modal.dart   (partial duplicate)
//
// Usage:
//   showDialog(
//     context: context,
//     builder: (_) => ReportModal(
//       targetTitle: 'Surgery Meds & Treatment',
//       targetType: 'request',      // 'request' | 'event' | 'message' | 'user'
//       onSubmit: (title, desc) { AidRequestService.instance.reportContent(...); },
//     ),
//   );
// ─────────────────────────────────────────────────────────────────────────────

class ReportModal extends StatefulWidget {
  /// The display name of the content being reported (shown in the title).
  final String targetTitle;

  /// Type hint for the caller — used to label the dialog correctly.
  /// Values: 'request' | 'event' | 'message' | 'user'
  final String targetType;

  /// Called with (reportTitle, reportDescription) when user taps Yes.
  final void Function(String title, String description)? onSubmit;

  const ReportModal({
    super.key,
    required this.targetTitle,
    this.targetType = 'request',
    this.onSubmit,
  });

  @override
  State<ReportModal> createState() => _ReportModalState();
}

class _ReportModalState extends State<ReportModal> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final t = _titleCtrl.text.trim();
    final d = _descCtrl.text.trim();
    if (t.isEmpty || d.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in both the title and description.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    Navigator.pop(context);
    widget.onSubmit?.call(t, d);
  }

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
                    text: TextSpan(
                      style: const TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: feastBlack,
                      ),
                      children: [
                        const TextSpan(
                          text: 'Report ',
                          style: TextStyle(color: Colors.red),
                        ),
                        TextSpan(text: '${widget.targetTitle}?'),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, size: 20, color: Colors.black45),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // ── Warning ──────────────────────────────────────────────────────
            RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 12,
                  color: Colors.black54,
                ),
                children: [
                  TextSpan(
                    text: 'WARNING: ',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(text: 'False reports are subject to penalties.'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Report title ─────────────────────────────────────────────────
            const Text(
              'Content Report Title',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: feastBlack,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _titleCtrl,
              style: const TextStyle(fontFamily: 'Outfit', fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Insert Report Subject Here...',
                hintStyle: const TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 13,
                    color: Colors.black38),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: feastGreen, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // ── Description ──────────────────────────────────────────────────
            TextField(
              controller: _descCtrl,
              maxLines: 3,
              style: const TextStyle(fontFamily: 'Outfit', fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Insert Report Description Here...',
                hintStyle: const TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 13,
                    color: Colors.black38),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: feastGreen, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Buttons ──────────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _btn('No', Colors.red, () => Navigator.pop(context)),
                const SizedBox(width: 10),
                _btn('Yes', feastBlue, _submit),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _btn(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        decoration: BoxDecoration(
          color: color,
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
