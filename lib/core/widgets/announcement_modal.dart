import 'package:flutter/material.dart';
 
/// AnnouncementModal
/// Displays an official announcement with an optional image, title, body text,
/// and an optional hyperlink. Triggered by a barangay/community admin.
///
/// Usage:
/// ```dart
/// showDialog(
///   context: context,
///   builder: (_) => AnnouncementModal(
///     imageUrl: 'https://your-firebase-image-url',
///     title: 'Updated Policies & Guidelines',
///     body: 'We've refreshed our community playbook...',
///     linkText: 'Click this link for additional information.',
///     linkUrl: 'https://your-link-here',
///   ),
/// );
/// ```
class AnnouncementModal extends StatelessWidget {
  final String? imageUrl;
  final String title;
  final String body;
  final String? linkText;
  final String? linkUrl;
  final VoidCallback? onLinkTap;
 
  const AnnouncementModal({
    super.key,
    this.imageUrl,
    this.title = 'Announcement Title',
    this.body = 'Announcement body text goes here.',
    this.linkText,
    this.linkUrl,
    this.onLinkTap,
  });
 
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // --- Header image ---
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: imageUrl != null
                ? Image.network(
                    imageUrl!,
                    height: 180,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholderImage(),
                  )
                : _placeholderImage(),
          ),
 
          // --- Close button ---
          Stack(
            children: [
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
 
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  body,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
                if (linkText != null) ...[
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: onLinkTap,
                    child: Text(
                      linkText!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close Window',
                        style: TextStyle(fontSize: 15)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
 
  Widget _placeholderImage() {
    return Container(
      height: 180,
      color: Colors.grey.shade300,
      child: const Center(
        child: Icon(Icons.image, size: 48, color: Colors.grey),
      ),
    );
  }
}
