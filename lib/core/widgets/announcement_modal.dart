// lib/core/widgets/announcement_modal.dart
//
// Displays a full official announcement when a card on HomeScreen is tapped.
//
// The home screen calls it as:
//   showDialog(context: context, builder: (_) => AnnouncementModal(data: data));
// where `data` is the raw Firestore document map from the 'announcements' collection.
//
// Firestore fields consumed:
//   imageUrls : List<String>  — first item used as header image
//   title     : String
//   body      : String
//   linkText  : String?       — optional call-to-action label
//   linkUrl   : String?       — optional URL for the call-to-action

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_colors.dart';

class AnnouncementModal extends StatelessWidget {
  // ── Primary constructor: accepts the raw Firestore map ──────────────────
  final Map<String, dynamic>? data;

  // ── Named-param constructor kept for direct / test usage ─────────────────
  final String? imageUrl;
  final String? title;
  final String? body;
  final String? linkText;
  final String? linkUrl;

  /// Pass a Firestore document map (from the 'announcements' collection).
  const AnnouncementModal({
    super.key,
    this.data,
    // Named overrides — used when constructing the modal directly without a map.
    this.imageUrl,
    this.title,
    this.body,
    this.linkText,
    this.linkUrl,
  });

  // ── Resolve values: map takes precedence, named params are fallback ───────
  String get _resolvedTitle {
    if (data != null) return data!['title'] as String? ?? '';
    return title ?? '';
  }

  String get _resolvedBody {
    if (data != null) return data!['body'] as String? ?? '';
    return body ?? '';
  }

  String? get _resolvedImageUrl {
    if (data != null) {
      final urls = (data!['imageUrls'] as List?)?.cast<String>() ?? [];
      return urls.isNotEmpty ? urls.first : null;
    }
    return imageUrl;
  }

  String? get _resolvedLinkText {
    if (data != null) return data!['linkText'] as String?;
    return linkText;
  }

  String? get _resolvedLinkUrl {
    if (data != null) return data!['linkUrl'] as String?;
    return linkUrl;
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final imgUrl = _resolvedImageUrl;
    final lText = _resolvedLinkText;
    final lUrl = _resolvedLinkUrl;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      // Matches the card style used throughout the home screen
      backgroundColor: Colors.white,
      insetPadding:
          const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header image ────────────────────────────────────────────
            Stack(
              children: [
                SizedBox(
                  height: 190,
                  width: double.infinity,
                  child: imgUrl != null
                      ? Image.network(
                          imgUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _placeholderImage(),
                        )
                      : _placeholderImage(),
                ),
                // Close button overlaid on the image
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(140),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // ── Body ────────────────────────────────────────────────────
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      _resolvedTitle,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Outfit',
                        color: feastBlack,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Body text
                    Text(
                      _resolvedBody,
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'Outfit',
                        color: feastGray.withAlpha(220),
                        height: 1.55,
                      ),
                    ),

                    // Optional link
                    if (lText != null && lText.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      GestureDetector(
                        onTap: () {
                          if (lUrl != null && lUrl.isNotEmpty) {
                            _launchUrl(lUrl);
                          }
                        },
                        child: Text(
                          lText,
                          style: const TextStyle(
                            fontSize: 13,
                            fontFamily: 'Outfit',
                            color: feastBlue,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 22),

                    // Close button — matches FEAST button style
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: feastBlack,
                          foregroundColor: Colors.white,
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Close Window',
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: 'Outfit',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Placeholder shown when imageUrls is empty or the network image fails
  Widget _placeholderImage() {
    return Container(
      height: 190,
      color: feastLightYellow.withAlpha(180),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.campaign_outlined,
                size: 52, color: feastOrange.withAlpha(160)),
            const SizedBox(height: 6),
            Text(
              'Official Announcement',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 12,
                color: feastGray.withAlpha(180),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ■■ REACT.JS INTEGRATION NOTE ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
// Collection : announcements
// Document   : {auto-id}
// Fields     : title (String), body (String), imageUrls (List<String>),
//              linkText (String?), linkUrl (String?), createdAt (Timestamp)
// React query:
//   const q = query(collection(db, 'announcements'),
//     orderBy('createdAt', 'desc'), limit(5));
// Notes: All users can read; only admins can write.
// ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
