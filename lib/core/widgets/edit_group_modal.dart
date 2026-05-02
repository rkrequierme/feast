import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../constants/app_colors.dart';
import '../constants/firestore_paths.dart';
import '../core.dart'; // Add this for TermsConditionsDialog
import '../../features/legal/widgets/terms_conditions_dialog.dart';

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
  String? _imageError;

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
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );
      
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final fileSize = file.size;
        
        // Check file size (max 5MB)
        if (fileSize > 5 * 1024 * 1024) {
          setState(() {
            _imageError = 'Image size must be less than 5MB';
          });
          return;
        }
        
        // Check file extension
        final extension = file.extension?.toLowerCase() ?? '';
        const allowedExtensions = ['jpg', 'jpeg', 'png', 'webp', 'gif'];
        
        if (!allowedExtensions.contains(extension)) {
          setState(() {
            _imageError = 'Only JPG, PNG, WEBP, and GIF images are allowed';
          });
          return;
        }
        
        setState(() {
          _newPhoto = File(file.path!);
          _imageError = null;
        });
      }
    } catch (e) {
      setState(() {
        _imageError = 'Failed to pick image. Please try again.';
      });
    }
  }

  // ── Save to Firestore ─────────────────────────────────────────────────────

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();

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
      widget.onConfirm!(name, _descCtrl.text.trim());
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
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      // ALWAYS update description - set to empty string if empty
      // This ensures empty descriptions are saved correctly
      final description = _descCtrl.text.trim();
      updates['description'] = description; // Always set, even if empty

      // Upload new photo if picked
      if (_newPhoto != null) {
        final ref = FirebaseStorage.instance
            .ref('group_images/${widget.chatId}/avatar.jpg');
        
        final task = await ref.putFile(_newPhoto!);
        final downloadUrl = await task.ref.getDownloadURL();
        updates['groupImageUrl'] = downloadUrl;
      }

      await FirebaseFirestore.instance
          .collection(FirestorePaths.chats)
          .doc(widget.chatId)
          .update(updates);

      if (!mounted) return;
      Navigator.of(context).pop();
      widget.onSaved?.call();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Group details updated successfully!'),
          backgroundColor: feastSuccess,
        ),
      );
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Title ────────────────────────────────────────────────────
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: feastLightGreen.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.group, color: feastGreen, size: 24),
                ),
                const SizedBox(width: 12),
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
                GestureDetector(
                  onTap: widget.onCancel ?? () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: feastLightGreen,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, size: 18, color: feastGray),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Photo row with better UI ─────────────────────────────────
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: feastLightGreen.withAlpha(120),
                        backgroundImage: _newPhoto != null
                            ? FileImage(_newPhoto!)
                            : widget.initialPhotoUrl != null && widget.initialPhotoUrl!.isNotEmpty
                                ? NetworkImage(widget.initialPhotoUrl!)
                                : null,
                        child: _newPhoto == null && (widget.initialPhotoUrl == null || widget.initialPhotoUrl!.isEmpty)
                            ? const Icon(Icons.group, size: 50, color: feastGreen)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickPhoto,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: feastGreen,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_imageError != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _imageError!,
                      style: const TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 11,
                        color: feastError,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: _pickPhoto,
                    icon: const Icon(Icons.upload, size: 16),
                    label: const Text(
                      'Change Group Photo',
                      style: TextStyle(fontFamily: 'Outfit'),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: feastGreen,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Group Name ───────────────────────────────────────────────
            const Text(
              'Group Name *',
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
                hintText: 'Enter group name',
                hintStyle: const TextStyle(color: feastGray, fontFamily: 'Outfit'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: feastGreen, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              ),
            ),
            const SizedBox(height: 16),

            // ── Description (Optional) ──────────────────────────────────────
            const Text(
              'Group Description (Optional)',
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
              maxLines: 3,
              style: const TextStyle(fontFamily: 'Outfit', fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Write a brief description (optional)...',
                hintStyle: const TextStyle(color: feastGray, fontFamily: 'Outfit'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: feastGreen, width: 2),
                ),
                contentPadding: const EdgeInsets.all(14),
              ),
            ),
            const SizedBox(height: 20),

            // ── T&C checkbox with link to dialog ─────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: _termsAccepted,
                    activeColor: feastGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    onChanged: (v) => setState(() => _termsAccepted = v ?? false),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                      children: [
                        const TextSpan(text: 'I agree with the '),
                        WidgetSpan(
                          child: GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (_) => TermsConditionsDialog(
                                  onAccept: () {
                                    // I Understand - check the checkbox
                                    if (mounted) {
                                      setState(() => _termsAccepted = true);
                                    }
                                  },
                                  onDecline: () {
                                    // Decline - uncheck the checkbox
                                    if (mounted) {
                                      setState(() => _termsAccepted = false);
                                    }
                                  },
                                ),
                              );
                            },
                            child: const Text(
                              'terms and conditions',
                              style: TextStyle(
                                color: feastBlue,
                                decoration: TextDecoration.underline,
                                fontFamily: 'Outfit',
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
              ],
            ),
            const SizedBox(height: 24),

            // ── Buttons (Cancel on left, Confirm on right) ─────────────────
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.onCancel ?? () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: feastError,
                      side: const BorderSide(color: feastError),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: (_termsAccepted && !_isSaving) ? _save : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _termsAccepted ? feastGreen : Colors.grey.shade400,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Confirm',
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
