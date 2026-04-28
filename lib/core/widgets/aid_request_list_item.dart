import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// aid_request_list_item.dart
//
// Reusable card for the Aid Requests list screen.
// Data comes from Firestore; this widget is purely presentational.
//
// FIREBASE WIRING (caller-side):
//   StreamBuilder<QuerySnapshot>(
//     stream: AidRequestService.instance.approvedRequestsQuery().snapshots(),
//     builder: (ctx, snap) {
//       final docs = snap.data?.docs ?? [];
//       return ListView.builder(
//         itemCount: docs.length,
//         itemBuilder: (_, i) {
//           final d = docs[i].data() as Map<String, dynamic>;
//           return AidRequestListItem.fromMap(d, onTap: () => ...);
//         },
//       );
//     },
//   );
// ─────────────────────────────────────────────────────────────────────────────

class AidRequestListItem extends StatefulWidget {
  final String id;
  final String title;
  final String description;
  final String category;
  final String location;
  final int daysRemaining;
  final double? fundsGoal;      // null when request type is In-Kind only
  final double? fundsRaised;
  final int itemsDonated;
  final int donorCount;
  final String beneficiaryName;
  final String? beneficiaryAvatarUrl;
  final String? heroImageUrl;
  final VoidCallback? onTap;

  const AidRequestListItem({
    super.key,
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.daysRemaining,
    this.fundsGoal,
    this.fundsRaised,
    this.itemsDonated = 0,
    this.donorCount = 0,
    required this.beneficiaryName,
    this.beneficiaryAvatarUrl,
    this.heroImageUrl,
    this.onTap,
  });

  /// Convenience constructor — build directly from a Firestore map.
  factory AidRequestListItem.fromMap(
    Map<String, dynamic> data, {
    VoidCallback? onTap,
  }) {
    // Calculate days remaining from expiresAt timestamp
    final expiresAt = data['expiresAt'];
    int days = 0;
    if (expiresAt != null) {
      final dt = (expiresAt as dynamic).toDate() as DateTime;
      days = dt.difference(DateTime.now()).inDays.clamp(0, 9999);
    }
    final images = List<String>.from(data['imageUrls'] as List? ?? []);
    return AidRequestListItem(
      id: data['id'] as String? ?? '',
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      category: data['category'] as String? ?? '',
      location: data['location'] as String? ?? '',
      daysRemaining: days,
      fundsGoal: (data['fundraiserGoal'] as num?)?.toDouble(),
      fundsRaised: (data['fundraiserRaised'] as num?)?.toDouble(),
      itemsDonated: (data['itemsDonated'] as int?) ?? 0,
      donorCount: (data['donorCount'] as int?) ?? 0,
      beneficiaryName: data['fullName'] as String? ?? 'Unknown',
      heroImageUrl: images.isNotEmpty ? images.first : null,
      onTap: onTap,
    );
  }

  @override
  State<AidRequestListItem> createState() => _AidRequestListItemState();
}

class _AidRequestListItemState extends State<AidRequestListItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero image ────────────────────────────────────────────────
            _HeroImageWithTitle(
              heroImageUrl: widget.heroImageUrl,
              title: widget.title,
              beneficiaryName: widget.beneficiaryName,
              beneficiaryAvatarUrl: widget.beneficiaryAvatarUrl,
              description: widget.description,
            ),

            // ── Meta rows ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _MetaRow(
                    icon: Icons.category_outlined,
                    text: 'Request Category: ${widget.category}',
                  ),
                  _MetaRow(
                    icon: Icons.location_on_outlined,
                    text: 'Location: ${widget.location}',
                  ),
                  _MetaRow(
                    icon: Icons.access_time,
                    text: 'Time Remaining: ${widget.daysRemaining} Day${widget.daysRemaining == 1 ? '' : 's'} Left',
                    valueColor: widget.daysRemaining <= 1
                        ? feastError
                        : widget.daysRemaining <= 3
                            ? feastPending
                            : null,
                  ),

                  // Expanded details
                  if (_expanded) ...[
                    if (widget.fundsGoal != null && widget.fundsGoal! > 0)
                      _MetaRow(
                        icon: Icons.attach_money,
                        text:
                            'Aid Funds Donated: ₱${widget.fundsRaised?.toStringAsFixed(0) ?? '0'} / ₱${widget.fundsGoal!.toStringAsFixed(0)}',
                        valueColor: feastGreen,
                      ),
                    _MetaRow(
                      icon: Icons.inventory_2_outlined,
                      text: 'Items Donated: ${widget.itemsDonated}',
                    ),
                    _MetaRow(
                      icon: Icons.people_outline,
                      text: 'Donors: ${widget.donorCount}',
                    ),
                  ],
                ],
              ),
            ),

            // ── Footer: expand toggle + view link ─────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Expand/collapse toggle
                  GestureDetector(
                    onTap: () => setState(() => _expanded = !_expanded),
                    child: Row(
                      children: [
                        Icon(
                          _expanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          size: 18,
                          color: Colors.black45,
                        ),
                        Text(
                          _expanded ? 'Less' : 'More details',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.black45,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // View request link
                  GestureDetector(
                    onTap: widget.onTap,
                    child: const Text(
                      'Tap To View Request →',
                      style: TextStyle(
                        color: feastGreen,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Hero image with title overlay ────────────────────────────────────────────

class _HeroImageWithTitle extends StatelessWidget {
  final String? heroImageUrl;
  final String title;
  final String beneficiaryName;
  final String? beneficiaryAvatarUrl;
  final String description;

  const _HeroImageWithTitle({
    required this.heroImageUrl,
    required this.title,
    required this.beneficiaryName,
    this.beneficiaryAvatarUrl,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          heroImageUrl != null
              ? Image.network(heroImageUrl!, fit: BoxFit.cover)
              : Container(color: Colors.grey[300]),

          // Gradient for readability
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black38],
              ),
            ),
          ),

          // Title card overlay (top-right)
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
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 9,
                        backgroundImage: beneficiaryAvatarUrl != null
                            ? NetworkImage(beneficiaryAvatarUrl!)
                            : null,
                        child: beneficiaryAvatarUrl == null
                            ? const Icon(Icons.person, size: 10)
                            : null,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          beneficiaryName,
                          style: const TextStyle(fontSize: 10),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 9, color: Colors.black54),
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

// ── Shared meta row widget ────────────────────────────────────────────────────

class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? valueColor;

  const _MetaRow({
    required this.icon,
    required this.text,
    this.valueColor,
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
                color: valueColor ?? Colors.black87,
                fontWeight:
                    valueColor != null ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
