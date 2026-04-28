import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../constants/app_colors.dart';
import '../constants/firestore_paths.dart';

// ─────────────────────────────────────────────────────────────────────────────
// edit_group_modal.dart
//
// FIX (Image 4): SelectedGroupScreen called EditGroupModal with:
//   chatId: widget.chatId
//   currentName: groupName
//   currentDescription: description
//   onSaved: _loadChat
//
// But the old widget defined:
//   initialName:, initialDescription:, onConfirm:  (no chatId, no onSaved)
//
// SOLUTION: Added `chatId`, `currentName`, `currentDescription`, `onSaved`
// parameters. The modal writes to Firestore directly when the user taps
// Confirm, then calls `onSaved` so the parent can refresh.
//
// Old parameters (initialName, initialDescription, onConfirm) are kept as
// aliases so any other callers don't break.
// ─────────────────────────────────────────────────────────────────────────────

class EditGroupModal extends StatefulWidget {
  // ── Parameters used by SelectedGroupScreen (Image 4 fix) ─────────────────
  final String? chatId;
  final String? currentName;
  final String? currentDescription;
  final VoidCallback? onSaved;

  // ── Legacy / alternative parameter names kept for compatibility ───────────
  final String? initialPhotoUrl;
  final String? initialName;
  final String? initialDescription;
  final void Function(String name, String description)? onConfirm;
  final VoidCallback? onCancel;

  const EditGroupModal({
    super.key,
    // New params
    this.chatId,
    this.currentName,
    this.currentDescription,
    this.onSaved,
    // Legacy params
    this.initialPhotoUrl,
    this.initialName,
    this.initialDescription,
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
  bool _isSaving = false;
  File? _newPhoto;

  @override
  void initState() {
    super.initState();
    // Prefer new params; fall back to legacy params
    _nameCtrl = TextEditingController(
      text: widget.currentName ?? widget.initialName ?? '',
    );
    _descCtrl = TextEditingController(
      text: widget.currentDescription ?? widget.initialDescription ?? '',
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  // ── Pick group photo ──────────────────────────────────────────────────────

  Future<void> _pickPhoto() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.isNotEmpty) {
      setState(() => _newPhoto = File(result.files.first.path!));
    }
  }

  // ── Save to Firestore ─────────────────────────────────────────────────────

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    final desc = _descCtrl.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Group name cannot be empty.'),
          backgroundColor: feastError,
        ),
      );
      return;
    }

    // If legacy onConfirm is provided and no chatId, use the old pathway
    if (widget.chatId == null && widget.onConfirm != null) {
      widget.onConfirm!(name, desc);
      Navigator.of(context).pop();
      return;
    }

    if (widget.chatId == null) {
      Navigator.of(context).pop();
      return;
    }

    setState(() => _isSaving = true);

    try {
      final updates = <String, dynamic>{
        'groupName': name,
        'description': desc,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Upload new photo if picked
      if (_newPhoto != null) {
        final ref = FirebaseStorage.instance
            .ref('group_images/${widget.chatId}/avatar.jpg');
        await ref.putFile(_newPhoto!);
        updates['groupImageUrl'] = await ref.getDownloadURL();
      }

      await FirebaseFirestore.instance
          .collection(FirestorePaths.chats)
          .doc(widget.chatId)
          .update(updates);

      if (!mounted) return;
      Navigator.of(context).pop();
      widget.onSaved?.call();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save group details. Please try again.'),
          backgroundColor: feastError,
        ),
      );
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Title ────────────────────────────────────────────────────
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Edit Group Details',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: feastBlack,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Change your group photo, name & description.',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: widget.onCancel ?? () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Photo row ────────────────────────────────────────────────
            Row(
              children: [
                GestureDetector(
                  onTap: _pickPhoto,
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: feastLightGreen.withAlpha(120),
                    backgroundImage: _newPhoto != null
                        ? FileImage(_newPhoto!)
                        : widget.initialPhotoUrl != null
                            ? NetworkImage(widget.initialPhotoUrl!)
                                as ImageProvider
                            : null,
                    child: _newPhoto == null && widget.initialPhotoUrl == null
                        ? const Icon(Icons.group, size: 28, color: feastGreen)
                        : null,
                  ),
                ),
                const SizedBox(width: 14),
                OutlinedButton.icon(
                  onPressed: _pickPhoto,
                  icon: const Icon(Icons.upload, size: 18),
                  label: const Text('Upload Photo',
                      style: TextStyle(fontFamily: 'Outfit')),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: feastGreen,
                    side: BorderSide(color: Colors.grey.shade400),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Group Name ───────────────────────────────────────────────
            const Text(
              'Group Name*',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: feastBlack,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _nameCtrl,
              style: const TextStyle(fontFamily: 'Outfit', fontSize: 14),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: feastGreen, width: 2),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
            const SizedBox(height: 14),

            // ── Description ──────────────────────────────────────────────
            const Text(
              'Group Description*',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: feastBlack,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _descCtrl,
              maxLines: 4,
              style: const TextStyle(fontFamily: 'Outfit', fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Write a brief description...',
                hintStyle:
                    const TextStyle(fontFamily: 'Outfit', color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: feastGreen, width: 2),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 12),

            // ── T&C checkbox ─────────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Checkbox(
                  value: _termsAccepted,
                  activeColor: feastGreen,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3)),
                  onChanged: (v) =>
                      setState(() => _termsAccepted = v ?? false),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () =>
                        setState(() => _termsAccepted = !_termsAccepted),
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 13,
                            color: Colors.black87),
                        children: [
                          TextSpan(text: 'I agree with the '),
                          TextSpan(
                            text: 'terms and conditions',
                            style: TextStyle(
                              color: feastBlue,
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
            const SizedBox(height: 16),

            // ── Confirm ──────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_termsAccepted && !_isSaving) ? _save : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _termsAccepted ? feastBlue : Colors.grey.shade400,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text(
                        'Confirm',
                        style: TextStyle(
                            fontFamily: 'Outfit',
                            fontWeight: FontWeight.bold,
                            fontSize: 15),
                      ),
              ),
            ),
            const SizedBox(height: 10),

            // ── Cancel ───────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    widget.onCancel ?? () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
