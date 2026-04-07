import 'package:flutter/material.dart';

/// InviteCollaboratorsModal
/// Lets a group admin search and invite collaborators by name.
/// Supports adding multiple search fields dynamically.
///
/// Parameters:
///   [title]       — Dialog title. Defaults to "Invite Collaborators".
///   [subtitle]    — Subtitle text.
///   [onConfirm]   — Callback with the list of entered names when Confirm is tapped.
///   [onCancel]    — Callback when Cancel is tapped (defaults to pop).
///
/// Usage:
/// ```dart
/// showDialog(
///   context: context,
///   builder: (_) => InviteCollaboratorsModal(
///     onConfirm: (names) {
///       // send invites to Firebase
///     },
///   ),
/// );
/// ```
class InviteCollaboratorsModal extends StatefulWidget {
  final String title;
  final String subtitle;
  final void Function(List<String> names)? onConfirm;
  final VoidCallback? onCancel;

  const InviteCollaboratorsModal({
    super.key,
    this.title = 'Invite Collaborators',
    this.subtitle =
        'We encourage you to invite new collaborators to help you out with all charity-related activities.',
    this.onConfirm,
    this.onCancel,
  });

  @override
  State<InviteCollaboratorsModal> createState() =>
      _InviteCollaboratorsModalState();
}

class _InviteCollaboratorsModalState extends State<InviteCollaboratorsModal> {
  final List<TextEditingController> _controllers = [
    TextEditingController(),
    TextEditingController(),
  ];

  void _addField() {
    setState(() => _controllers.add(TextEditingController()));
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

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
            // Icon + close row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.person_add_alt_1, size: 22),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed:
                      widget.onCancel ?? () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 10),

            Text(widget.title,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(widget.subtitle,
                style: const TextStyle(fontSize: 13, color: Colors.black87)),
            const SizedBox(height: 14),

            const Text('Collaborator Names',
                style:
                    TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),

            // Search fields
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: SingleChildScrollView(
                child: Column(
                  children: _controllers
                      .map(
                        (ctrl) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: TextField(
                            controller: ctrl,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.search, size: 20),
                              hintText: 'Collaborator Name',
                              hintStyle:
                                  const TextStyle(color: Colors.grey),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade300),
                              ),
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),

            // Add Another
            GestureDetector(
              onTap: _addField,
              child: const Row(
                children: [
                  Icon(Icons.add, color: Colors.green, size: 18),
                  SizedBox(width: 4),
                  Text('Add Another',
                      style: TextStyle(color: Colors.green, fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Confirm
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => widget.onConfirm
                    ?.call(_controllers.map((c) => c.text).toList()),
                child: const Text('Confirm', style: TextStyle(fontSize: 15)),
              ),
            ),
            const SizedBox(height: 10),

            // Cancel
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed:
                    widget.onCancel ?? () => Navigator.of(context).pop(),
                child: const Text('Cancel', style: TextStyle(fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}