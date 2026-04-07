import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class UploadedFile {
  final String name;
  final String size;
  final double progress;

  UploadedFile({required this.name, required this.size, this.progress = 1.0});
}

class FilePickerModal {
  static Future<void> show({
    required BuildContext context,
    required TextEditingController controller,
  }) async {
    List<UploadedFile> files = [];

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                    const Text(
                      "Upload & Attach Files",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Outfit",
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Text(
                  "Upload and attach files to this field.",
                  style: TextStyle(fontSize: 12, color: Colors.grey, fontFamily: "Outfit"),
                ),
                const SizedBox(height: 16),
                // Drop zone
                GestureDetector(
                  onTap: () async {
                    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
                    if (result != null) {
                      setModalState(() {
                        for (final f in result.files) {
                          final kb = (f.size / 1024).round();
                          final label = kb >= 1024
                              ? "${(kb / 1024).toStringAsFixed(0)} MB"
                              : "$kb KB";
                          files.add(UploadedFile(name: f.name, size: label));
                        }
                      });
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.upload_outlined, size: 32, color: Colors.green),
                        SizedBox(height: 8),
                        Text(
                          "Click to upload and attach files",
                          style: TextStyle(color: Colors.green, fontSize: 13, fontFamily: "Outfit"),
                        ),
                        Text(
                          "SVG, PNG, JPG or GIF (max. 800×400px)",
                          style: TextStyle(color: Colors.grey, fontSize: 11, fontFamily: "Outfit"),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // File list
                if (files.isNotEmpty)
                  ...files.map((f) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade200),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.insert_drive_file_outlined, size: 28, color: Colors.grey),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    f.name,
                                    style: const TextStyle(fontSize: 13, fontFamily: "Outfit"),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    f.size,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                      fontFamily: "Outfit",
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  LinearProgressIndicator(
                                    value: f.progress,
                                    backgroundColor: Colors.grey.shade200,
                                    color: Colors.green,
                                    minHeight: 4,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            f.progress >= 1.0
                                ? const Icon(Icons.check_circle, color: Colors.green, size: 20)
                                : IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                    onPressed: () => setModalState(() => files.remove(f)),
                                  ),
                          ],
                        ),
                      )),
                const SizedBox(height: 16),
                // Confirm
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (files.isNotEmpty) {
                        controller.text = files.map((f) => f.name).join(", ");
                      }
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text("Confirm",
                        style: TextStyle(fontFamily: "Outfit", color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 8),
                // Cancel
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text("Cancel",
                        style: TextStyle(fontFamily: "Outfit", color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}