// lib/core/widgets/file_picker_modal.dart

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

enum FilePickerMode { imagesOnly, allFiles }

class FilePickerModal extends StatefulWidget {
  final FilePickerMode mode;
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
  static const _imageExtensions = ['jpg', 'jpeg', 'png', 'webp', 'gif'];
  final List<_PickedEntry> _picked = [];

  Future<void> _pick() async {
    final isImagesOnly = widget.mode == FilePickerMode.imagesOnly;

    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: isImagesOnly ? FileType.image : FileType.any,
    );

    if (result == null) return;

    for (final pf in result.files) {
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
            // Header
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

            // Drop zone
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

            // File list
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

            // ── BUTTONS (SIDE BY SIDE) ──
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: feastError,
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
                const SizedBox(width: 12),
                Expanded(
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}

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
