// lib/core/widgets/question_modal.dart

import 'package:flutter/material.dart';
import '../core.dart';

/// QuestionModal
/// A form modal that lets a user submit a question with a title and description.
///
/// Parameters:
///   [title]           — Dialog title. Defaults to "Submit a Question".
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
    this.title = 'Submit a Question',
    this.subtitle = 'Our team will review your question and respond within 24-48 hours.',
    this.titleController,
    this.descController,
    this.onCancel,
    this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final _titleCtrl = titleController ?? TextEditingController();
    final _descCtrl = descController ?? TextEditingController();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 12, offset: Offset(0, 4)),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: feastBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.question_answer, color: feastBlue, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        title,
                        style: const TextStyle(
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: feastBlack,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: onCancel ?? () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: feastLighterBlue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, size: 18, color: feastGray),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 16,
                  color: feastGray,
                ),
              ),
              const SizedBox(height: 20),

              // Title Field (hidden - used for internal tracking)
              if (!_titleCtrl.text.isEmpty) ...[
                TextField(
                  controller: _titleCtrl,
                  decoration: InputDecoration(
                    hintText: 'Question Title (Optional)',
                    hintStyle: const TextStyle(color: feastGray, fontFamily: 'Outfit'),
                    prefixIcon: const Icon(Icons.title, color: feastGray, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: feastLightGreen),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: feastGreen, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Description field (main content)
              TextField(
                controller: _descCtrl,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Your Question.',
                  hintStyle: const TextStyle(color: feastGray, fontFamily: 'Outfit'),
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: feastLightGreen),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: feastGreen, width: 2),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 20),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onCancel ?? () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: feastError,
                        side: const BorderSide(color: feastError),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final questionText = _descCtrl.text.trim();
                        if (questionText.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter your question.'),
                              backgroundColor: feastError,
                            ),
                          );
                          return;
                        }
                        onSubmit?.call(_titleCtrl.text.trim(), questionText);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: feastBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Submit'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
