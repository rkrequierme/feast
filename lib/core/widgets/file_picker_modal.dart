// lib/core/widgets/file_picker_modal.dart
//
// Replaces BOTH the old file_picker_modal.dart AND file_picker.dart.
// The standalone FeastFilePicker widget (file_picker.dart) was a plain
// read-only text field that only showed a filename — it had no picking
// logic of its own and duplicated what FilePickerModal already does.
// Everything is now in one place.
//
// Public API
// ──────────
//  FilePickerModal          – Dialog widget; pass to showDialog(builder:)
//  FilePickerMode           – enum that controls which file types are accepted
//
// FilePickerMode values
// ─────────────────────
//  FilePickerMode.imagesOnly  – JPG, JPEG, PNG, WEBP, GIF
//                               (posts, legal ID, profile picture)
//  FilePickerMode.allFiles    – any file type (chat attachments)
//
// Usage example
// ─────────────
//  showDialog(
//    context: context,
//    builder: (_) => FilePickerModal(
//      mode: FilePickerMode.imagesOnly,
//      onConfirm: (files) { /* handle List<File> */ },
//    ),
//  );
//
// ── REACT.JS INTEGRATION NOTE ──────────────────────────────────────────────
// This widget handles client-side file selection only. After the user
// confirms, the calling code is responsible for uploading to Firebase Storage.
// In the React.js web app, replicate the two-mode behaviour with an <input>
// element:
//   Images only : <input type="file" accept="image/jpeg,image/png,image/webp,image/gif" />
//   All files   : <input type="file" />
// Upload the result with Firebase JS SDK:
//   import { ref, uploadBytes } from 'firebase/storage';
//   await uploadBytes(ref(storage, `uploads/${uid}/${file.name}`), file);
// ───────────────────────────────────────────────────────────────────────────

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

// Controls which file types the modal accepts.
enum FilePickerMode { imagesOnly, allFiles }

class FilePickerModal extends StatefulWidget {
  /// [mode] defaults to [FilePickerMode.imagesOnly].
  final FilePickerMode mode;

  /// Called with the confirmed [List<File>] when the user taps Confirm.
  final void Function(List<File> files)? onConfirm;

  const FilePickerModal({
    super.key,
    this.mode = FilePickerMode.imagesOnly,
    this.onConfirm,
  });

  @override
  State<FilePickerModal> createState() => _FilePickerModalState();
}

class _FilePickerModalState extends State<FilePickerModal> {
  // Image extensions enforced when mode == imagesOnly.
  static const _imageExtensions = ['jpg', 'jpeg', 'png', 'webp', 'gif'];

  final List<_PickedEntry> _picked = [];

  // ── File picking ──────────────────────────────────────────────────────────

  Future<void> _pick() async {
    final isImagesOnly = widget.mode == FilePickerMode.imagesOnly;

    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      // Use FileType.image for images-only so the OS restricts the picker;
      // use FileType.any for all-files mode.
      type: isImagesOnly ? FileType.image : FileType.any,
    );

    if (result == null) return;

    for (final pf in result.files) {
      // Extra extension guard for imagesOnly (in case OS picker leaks types).
      if (isImagesOnly) {
        final ext = (pf.extension ?? '').toLowerCase();
        if (!_imageExtensions.contains(ext)) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '"${pf.name}" is not an accepted image type. '
                  'Use JPG, JPEG, PNG, WEBP, or GIF.',
                ),
                backgroundColor: feastError,
              ),
            );
          }
          continue;
        }
      }

      if (pf.path == null) continue;

      // Human-readable file size label.
      final bytes = pf.size;
      final sizeLabel = bytes >= 1024 * 1024
          ? '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB'
          : '${(bytes / 1024).round()} KB';

      setState(() {
        _picked.add(_PickedEntry(
          file: File(pf.path!),
          name: pf.name,
          sizeLabel: sizeLabel,
        ));
      });
    }
  }

  void _remove(int index) => setState(() => _picked.removeAt(index));

  void _confirm() {
    Navigator.of(context).pop();
    widget.onConfirm?.call(_picked.map((e) => e.file).toList());
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isImagesOnly = widget.mode == FilePickerMode.imagesOnly;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ────────────────────────────────────────────────────
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Upload & Attach Files',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: feastBlack,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Upload and attach files to this field.',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Drop zone ─────────────────────────────────────────────────
            GestureDetector(
              onTap: _pick,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.upload_outlined, size: 32, color: feastGreen),
                    const SizedBox(height: 8),
                    const Text(
                      'Click to upload and attach files',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        color: feastGreen,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      isImagesOnly
                          ? 'JPG, JPEG, PNG, WEBP or GIF (max. 800×400 px)'
                          : 'All file types accepted',
                      style: const TextStyle(
                        fontFamily: 'Outfit',
                        color: Colors.grey,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── File list ─────────────────────────────────────────────────
            if (_picked.isNotEmpty)
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 200),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _picked.length,
                  itemBuilder: (_, i) {
                    final entry = _picked[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.insert_drive_file_outlined,
                            size: 26,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry.name,
                                  style: const TextStyle(
                                    fontFamily: 'Outfit',
                                    fontSize: 13,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  entry.sizeLabel,
                                  style: const TextStyle(
                                    fontFamily: 'Outfit',
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                // Progress bar at 100 % — file is already local.
                                LinearProgressIndicator(
                                  value: 1.0,
                                  backgroundColor: Colors.grey.shade200,
                                  color: feastGreen,
                                  minHeight: 4,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: feastSuccess,
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: () => _remove(i),
                                child: const Icon(
                                  Icons.delete_outline,
                                  color: feastError,
                                  size: 18,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),

            // ── Confirm ───────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _confirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: feastBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Confirm',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // ── Cancel ────────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Internal data model ───────────────────────────────────────────────────────

class _PickedEntry {
  final File file;
  final String name;
  final String sizeLabel;

  const _PickedEntry({
    required this.file,
    required this.name,
    required this.sizeLabel,
  });
}
