// lib/core/widgets/charity_event_list_item.dart
//
// Reusable card for the Charity Events list screen.
//
// The screen calls it as:
//   CharityEventListItem(
//     data: data,           // raw Firestore map
//     docId: doc.id,
//     statusLabel: status,  // 'Not Yet Started' | 'Ongoing' | 'Concluded'
//     statusColor: _statusColor(status),
//     onTap: () => Navigator.pushNamed(...),
//   )
//
// All field extraction happens inside the widget from the map,
// so the screen never has to map fields manually.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../utils/date_parser.dart';

class CharityEventListItem extends StatelessWidget {
  // ── Primary map-based constructor (used by CharityEventsScreen) ──────────
  final Map<String, dynamic>? data;
  final String? docId;
  final String? statusLabel;
  final Color? statusColor;

  // ── Individual field overrides (used when constructing without a map) ────
  final String? id;
  final String? title;
  final String? description;
  final String? category;
  final String? location;
  final String? duration;
  final int? participantCount;
  final int? maxParticipants;
  final List<String>? collaboratorNames;
  final List<String?>? collaboratorAvatarUrls;
  final String? heroImageUrl;

  final VoidCallback? onTap;

  const CharityEventListItem({
    super.key,
    // Map-based params
    this.data,
    this.docId,
    this.statusLabel,
    this.statusColor,
    // Individual field params (fallbacks / direct construction)
    this.id,
    this.title,
    this.description,
    this.category,
    this.location,
    this.duration,
    this.participantCount,
    this.maxParticipants,
    this.collaboratorNames,
    this.collaboratorAvatarUrls,
    this.heroImageUrl,
    this.onTap,
  });

  // ── Resolve values: map takes precedence ─────────────────────────────────

  String get _title =>
      (data?['title'] as String?) ?? title ?? 'Charity Event';

  String get _description =>
      (data?['description'] as String?) ??
      description ??
      'Helping the community.';

  String get _category =>
      (data?['category'] as String?) ?? category ?? '';

  String get _location =>
      (data?['location'] as String?) ?? location ?? '';

  String get _duration {
    if (data != null) {
      final start = DateParser.parse(data!['startTime']);
      final end = DateParser.parse(data!['endTime']);
      if (start != null && end != null) {
        String _fmt(DateTime dt) {
          final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
          final m = dt.minute.toString().padLeft(2, '0');
          final ampm = dt.hour < 12 ? 'AM' : 'PM';
          return '$h:$m $ampm';
        }

        final months = [
          '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
        ];
        return '${_fmt(start)} – ${_fmt(end)} (${months[end.month]} ${end.day}, ${end.year})';
      }
    }
    return duration ?? statusLabel ?? 'TBD';
  }

  int get _participantCount =>
      (data?['participantCount'] as int?) ?? participantCount ?? 0;

  int get _maxParticipants =>
      (data?['maxParticipants'] as int?) ?? maxParticipants ?? 0;

  List<String> get _collaboratorNames {
    if (data != null) {
      return (data!['collaboratorNames'] as List?)?.cast<String>() ?? [];
    }
    return collaboratorNames ?? [];
  }

  List<String?> get _collaboratorAvatarUrls {
    if (data != null) {
      return (data!['collaboratorAvatarUrls'] as List?)
              ?.map((e) => e as String?)
              .toList() ??
          [];
    }
    return collaboratorAvatarUrls ?? [];
  }

  String? get _heroImageUrl {
    if (data != null) {
      final urls = (data!['imageUrls'] as List?)?.cast<String>() ?? [];
      return urls.isNotEmpty ? urls.first : null;
    }
    return heroImageUrl;
  }

  // Status resolved from the passed label or calculated from data
  String get _statusLabel {
    if (statusLabel != null) return statusLabel!;
    if (data != null) {
      final start = DateParser.parse(data!['startTime']);
      final end = DateParser.parse(data!['endTime']);
      final now = DateTime.now();
      if (start == null || now.isBefore(start)) return 'Not Yet Started';
      if (end != null && now.isAfter(end)) return 'Concluded';
      return 'Ongoing';
    }
    return 'Not Yet Started';
  }

  Color get _statusColor {
    if (statusColor != null) return statusColor!;
    switch (_statusLabel) {
      case 'Ongoing':
        return feastSuccess;
      case 'Concluded':
        return feastGray;
      default:
        return feastOrange;
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero image + overlay ───────────────────────────────────
            _buildHero(),

            // ── Meta rows ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _MetaRow(
                    icon: Icons.category_outlined,
                    text: 'Event Category: $_category',
                  ),
                  _MetaRow(
                    icon: Icons.location_on_outlined,
                    text: 'Location: $_location',
                  ),
                  _MetaRow(
                    icon: Icons.schedule,
                    text: 'Duration: $_duration',
                    valueWidget: Container(
                      margin: const EdgeInsets.only(left: 6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _statusColor.withAlpha(30),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: _statusColor.withAlpha(120),
                            width: 1),
                      ),
                      child: Text(
                        _statusLabel,
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: _statusColor,
                        ),
                      ),
                    ),
                  ),
                  _MetaRow(
                    icon: Icons.people_outline,
                    text:
                        'Participants: $_participantCount${_maxParticipants > 0 ? ' / $_maxParticipants' : ''}',
                  ),
                ],
              ),
            ),

            // ── Footer link ────────────────────────────────────────────
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 12, bottom: 10),
                child: GestureDetector(
                  onTap: onTap,
                  child: const Text(
                    'Tap To View Event →',
                    style: TextStyle(
                      color: feastBlue,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      fontFamily: 'Outfit',
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHero() {
    final img = _heroImageUrl;
    final names = _collaboratorNames;
    final avatars = _collaboratorAvatarUrls;

    return SizedBox(
      height: 140,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          img != null
              ? Image.network(img, fit: BoxFit.cover)
              : Container(
                  color: feastLighterBlue.withAlpha(80),
                  child: const Icon(Icons.event,
                      size: 48, color: feastBlue),
                ),

          // Gradient scrim for readability
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black26],
              ),
            ),
          ),

          // Title + collaborator overlay (top-right)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 170),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(230),
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 4),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _title,
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (names.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    _CollaboratorRow(
                        names: names, avatarUrls: avatars),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    _description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 9, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Collaborator avatar row ───────────────────────────────────────────────
class _CollaboratorRow extends StatelessWidget {
  final List<String> names;
  final List<String?> avatarUrls;

  const _CollaboratorRow(
      {required this.names, required this.avatarUrls});

  @override
  Widget build(BuildContext context) {
    final count = names.length.clamp(0, 3);
    return Row(
      children: List.generate(count, (i) {
        final url = i < avatarUrls.length ? avatarUrls[i] : null;
        return Padding(
          padding: const EdgeInsets.only(right: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 9,
                backgroundImage:
                    url != null ? NetworkImage(url) : null,
                child: url == null
                    ? const Icon(Icons.person, size: 10)
                    : null,
              ),
              const SizedBox(width: 3),
              Text(
                names[i],
                style: const TextStyle(
                    fontSize: 9, color: Colors.black87),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      }),
    );
  }
}

// ── Meta row helper ───────────────────────────────────────────────────────
class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? valueColor;
  // Optional widget appended after the text (e.g. status badge)
  final Widget? valueWidget;

  const _MetaRow({
    required this.icon,
    required this.text,
    this.valueColor,
    this.valueWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.black54),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 11,
                fontFamily: 'Outfit',
                color: valueColor ?? Colors.black87,
              ),
            ),
          ),
          if (valueWidget != null) valueWidget!,
        ],
      ),
    );
  }
}
