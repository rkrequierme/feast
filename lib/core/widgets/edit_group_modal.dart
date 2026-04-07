import 'package:flutter/material.dart';

/// EditGroupModal
/// Lets a group admin update the group photo, name, and description.
///
/// Parameters:
///   [initialPhotoUrl]   — Current group photo URL (Firebase Storage URL).
///   [initialName]       — Pre-filled group name.
///   [initialDescription]— Pre-filled group description.
///   [onUploadPhoto]     — Callback when "Upload Photo" is tapped.
///   [onConfirm]         — Callback with (name, description) when Confirm is tapped.
///   [onCancel]          — Callback when Cancel is tapped (defaults to pop).
///
/// Usage:
/// ```dart
/// showDialog(
///   context: context,
///   builder: (_) => EditGroupModal(
///     initialName: groupData['name'],
///     initialDescription: groupData['description'],
///     initialPhotoUrl: groupData['photoUrl'],
///     onUploadPhoto: () { /* pick image */ },
///     onConfirm: (name, desc) { /* update Firebase */ },
///   ),
/// );
/// ```
class EditGroupModal extends StatefulWidget {
  final String? initialPhotoUrl;
  final String initialName;
  final String initialDescription;
  final VoidCallback? onUploadPhoto;
  final void Function(String name, String description)? onConfirm;
  final VoidCallback? onCancel;

  const EditGroupModal({
    super.key,
    this.initialPhotoUrl,
    this.initialName = '',
    this.initialDescription = '',
    this.onUploadPhoto,
    this.onConfirm,
    this.onCancel,
  });

  @override
  State<EditGroupModal> createState() => _EditGroupModalState();
}

class _EditGroupModalState extends State<EditGroupModal> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  bool _termsAccepted = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initialName);
    _descCtrl = TextEditingController(text: widget.initialDescription);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title + close
            Row(
              children: [
                const Expanded(
                  child: Text('Edit Group Details',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed:
                      widget.onCancel ?? () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Text('Change your group photo, name & description.',
                style: TextStyle(fontSize: 13, color: Colors.black54)),
            const SizedBox(height: 16),

            // Photo row
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: widget.initialPhotoUrl != null
                      ? NetworkImage(widget.initialPhotoUrl!)
                      : null,
                  child: widget.initialPhotoUrl == null
                      ? const Icon(Icons.group, size: 28)
                      : null,
                ),
                const SizedBox(width: 14),
                OutlinedButton.icon(
                  onPressed: widget.onUploadPhoto,
                  icon: const Icon(Icons.upload, size: 18),
                  label: const Text('Upload Photo'),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade400),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Group Name
            const Text('Group Name*',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextField(
              controller: _nameCtrl,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
            const SizedBox(height: 14),

            // Group Description
            const Text('Group Description*',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextField(
              controller: _descCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Write a brief description...',
                hintStyle: const TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 12),

            // Terms checkbox
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
                  child: RichText(
                    text: const TextSpan(
                      style:
                          TextStyle(fontSize: 13, color: Colors.black87),
                      children: [
                        TextSpan(text: 'I agree with the '),
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
              ],
            ),
            const SizedBox(height: 16),

            // Confirm
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _termsAccepted ? Colors.blue : Colors.grey,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _termsAccepted
                    ? () =>
                        widget.onConfirm?.call(_nameCtrl.text, _descCtrl.text)
                    : null,
                child:
                    const Text('Confirm', style: TextStyle(fontSize: 15)),
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
                child:
                    const Text('Cancel', style: TextStyle(fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}