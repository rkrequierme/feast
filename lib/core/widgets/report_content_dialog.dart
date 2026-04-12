import 'package:flutter/material.dart';
import 'package:feast/core/core.dart';

// ---------------------------------------------------------------------------
// ReportContentDialog
// ---------------------------------------------------------------------------
// Shown when the user taps the warning/report button on a request.
//
// Usage:
//   showDialog(
//     context: context,
//     builder: (_) => ReportContentDialog(
//       title: 'Surgery Med & Treatment',
//       onConfirm: (reportTitle, reportDesc) { /* submit to Firestore */ },
//     ),
//   );
// ---------------------------------------------------------------------------

class ReportContentDialog extends StatefulWidget {
  /// The name / title of the content being reported.
  final String title;

  /// Called when the user taps "Yes". Receives the filled-in title and body.
  final void Function(String reportTitle, String reportDescription)? onConfirm;

  const ReportContentDialog({
    super.key,
    required this.title,
    this.onConfirm,
  });

  @override
  State<ReportContentDialog> createState() => _ReportContentDialogState();
}

class _ReportContentDialogState extends State<ReportContentDialog> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
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
                        TextSpan(text: widget.title + '?'),
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

            const SizedBox(height: 4),

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

            // ── Report Title ─────────────────────────────────────────────────
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
              controller: _titleController,
              style: const TextStyle(fontFamily: 'Outfit', fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Insert Report Subject Here...',
                hintStyle: const TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 13,
                  color: Colors.black38,
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // ── Description ──────────────────────────────────────────────────
            TextField(
              controller: _descController,
              maxLines: 3,
              style: const TextStyle(fontFamily: 'Outfit', fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Insert Report Description Here...',
                hintStyle: const TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 13,
                  color: Colors.black38,
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),

            const SizedBox(height: 16),

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
                  onTap: () {
                    widget.onConfirm?.call(
                      _titleController.text.trim(),
                      _descController.text.trim(),
                    );
                    Navigator.pop(context);
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