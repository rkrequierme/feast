import 'package:flutter/material.dart';

/// ReportModal
/// A form modal for submitting a content report, with a red warning about
/// false reports.
///
/// Parameters:
///   [titlePrefix]     — Red prefix word in the title (e.g. "Report").
///   [titleSuffix]     — Rest of the title (e.g. "Surgery Med & Treatment?").
///   [warningText]     — Bold warning text (e.g. "WARNING: False reports are subject to penalties.").
///   [subjectController] — Controller for the report subject/title field.
///   [descController]    — Controller for the report description field.
///   [onNo]            — Callback when No is tapped (defaults to pop).
///   [onYes]           — Callback with (subject, description) when Yes is tapped.
///
/// Usage:
/// ```dart
/// showDialog(
///   context: context,
///   builder: (_) => ReportModal(
///     titleSuffix: 'Surgery Med & Treatment?',
///     onYes: (subject, desc) {
///       // submit report to Firebase
///     },
///   ),
/// );
/// ```
class ReportModal extends StatelessWidget {
  final String titlePrefix;
  final String titleSuffix;
  final String warningText;
  final TextEditingController? subjectController;
  final TextEditingController? descController;
  final VoidCallback? onNo;
  final void Function(String subject, String description)? onYes;

  const ReportModal({
    super.key,
    this.titlePrefix = 'Report',
    this.titleSuffix = 'Surgery Med & Treatment?',
    this.warningText =
        'WARNING: False reports are subject to penalties.',
    this.subjectController,
    this.descController,
    this.onNo,
    this.onYes,
  });

  @override
  Widget build(BuildContext context) {
    final _subjectCtrl = subjectController ?? TextEditingController();
    final _descCtrl    = descController    ?? TextEditingController();

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                      children: [
                        TextSpan(
                          text: '$titlePrefix ',
                          style: const TextStyle(color: Colors.red),
                        ),
                        TextSpan(text: titleSuffix),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: onNo ?? () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Warning
            RichText(
              text: TextSpan(
                style:
                    const TextStyle(fontSize: 13, color: Colors.black87),
                children: [
                  const TextSpan(
                    text: 'WARNING: ',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                  TextSpan(
                      text: warningText
                          .replaceFirst('WARNING: ', '')),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Subject field
            TextField(
              controller: _subjectCtrl,
              decoration: InputDecoration(
                hintText: 'Content Report Title',
                hintStyle: const TextStyle(
                    color: Colors.black54, fontWeight: FontWeight.bold),
                border: InputBorder.none,
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Description field
            TextField(
              controller: _descCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Insert Report Description Here...',
                hintStyle: const TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 20),

            // No / Yes
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 22, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: onNo ?? () => Navigator.of(context).pop(),
                  child: const Text('No'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 22, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () =>
                      onYes?.call(_subjectCtrl.text, _descCtrl.text),
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