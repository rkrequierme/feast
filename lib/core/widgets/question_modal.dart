import 'package:flutter/material.dart';

/// QuestionModal
/// A form modal that lets a user submit a question with a title and description.
///
/// Parameters:
///   [title]           — Dialog title. Defaults to "Question Title".
///   [subtitle]        — Note/subtitle under the title.
///   [titleController] — TextEditingController for the question title field.
///   [descController]  — TextEditingController for the question description field.
///   [onCancel]        — Callback when Cancel is tapped (defaults to pop).
///   [onSubmit]        — Callback when Submit is tapped with (title, description).
///
/// Usage:
/// ```dart
/// final titleCtrl = TextEditingController();
/// final descCtrl  = TextEditingController();
///
/// showDialog(
///   context: context,
///   builder: (_) => QuestionModal(
///     titleController: titleCtrl,
///     descController:  descCtrl,
///     onSubmit: (title, desc) {
///       // send to Firebase
///     },
///   ),
/// );
/// ```
class QuestionModal extends StatelessWidget {
  final String title;
  final String subtitle;
  final TextEditingController? titleController;
  final TextEditingController? descController;
  final VoidCallback? onCancel;
  final void Function(String title, String description)? onSubmit;

  const QuestionModal({
    super.key,
    this.title = 'Question Title',
    this.subtitle = 'Note: Submit Your Questions Here',
    this.titleController,
    this.descController,
    this.onCancel,
    this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final _titleCtrl = titleController ?? TextEditingController();
    final _descCtrl  = descController  ?? TextEditingController();

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
                    title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: onCancel ?? () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 14),

            // Description field
            TextField(
              controller: _descCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Insert Question Description Here...',
                hintStyle: const TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 20),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: onCancel ?? () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    onSubmit?.call(_titleCtrl.text, _descCtrl.text);
                  },
                  child: const Text('Submit'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}