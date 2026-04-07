import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// CharityEventListItem
// ---------------------------------------------------------------------------
// A reusable card widget for displaying a single Charity Event in a list.
//
// FIREBASE INTEGRATION:
//   Collection : `charity_events`
//   Document fields expected:
//     - id               : String  (document ID)
//     - title            : String  (e.g. "Flood Relief Project")
//     - description      : String  (short blurb)
//     - category         : String  (e.g. "Disaster Management (Support & Supply)")
//     - location         : String
//     - duration         : String  (e.g. "9:00 AM – 5:00 PM | Feb 28, 2026")
//     - itemsDonated     : int
//     - participantCount : int
//     - maxParticipants  : int
//     - isNotYetStarted  : bool
//     - collaboratorNames: List<String>
//     - collaboratorAvatarUrls: List<String> (Storage URLs)
//     - heroImageUrl     : String (Storage URL)
//
//   To wire up:
//     1. Create a `CharityEvent` model that maps from DocumentSnapshot.
//     2. Use StreamBuilder with `charity_events` collection.
//     3. Pass each CharityEvent into this widget replacing placeholders.
// ---------------------------------------------------------------------------

class CharityEventListItem extends StatelessWidget {
  final String id;
  final String title;
  final String description;
  final String category;
  final String location;
  final String duration;
  final int itemsDonated;
  final int participantCount;
  final int maxParticipants;
  final bool isNotYetStarted;
  final List<String> collaboratorNames;
  final List<String?> collaboratorAvatarUrls;
  final String? heroImageUrl;
  final VoidCallback? onTap;

  const CharityEventListItem({
    super.key,
    this.id = 'placeholder_id',
    this.title = 'Charity Event Title',
    this.description =
        'Helping Filipino families by delivering food and essential supplies '
        'to those in need.',
    this.category = 'Disaster Management (Support & Supply)',
    this.location = 'BF Almarza, Almarza Dos',
    this.duration = 'Not Yet Started',
    this.itemsDonated = 0,
    this.participantCount = 11,
    this.maxParticipants = 20,
    this.isNotYetStarted = true,
    this.collaboratorNames = const ['Collaborator A', 'Collaborator B'],
    this.collaboratorAvatarUrls = const [null, null],
    this.heroImageUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero image ─────────────────────────────────────────────────
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: Stack(
                children: [
                  // TODO: replace with CachedNetworkImage(imageUrl: heroImageUrl)
                  Container(
                    height: 140,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: heroImageUrl != null
                        ? Image.network(heroImageUrl!, fit: BoxFit.cover)
                        : const Center(
                            child:
                                Icon(Icons.image, size: 48, color: Colors.grey)),
                  ),
                  // Title overlay card
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 160,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [
                          BoxShadow(color: Colors.black26, blurRadius: 4)
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 4),
                          // Collaborator avatars
                          _CollaboratorAvatarRow(
                            names: collaboratorNames,
                            avatarUrls: collaboratorAvatarUrls,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            description,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 10, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Meta info ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _MetaRow(
                      icon: Icons.category_outlined,
                      text: 'Event Category: $category'),
                  _MetaRow(
                      icon: Icons.location_on_outlined,
                      text: 'Location: $location'),
                  _MetaRow(
                      icon: Icons.schedule,
                      text: 'Duration: $duration',
                      valueColor:
                          isNotYetStarted ? Colors.orange : Colors.black87),
                  _MetaRow(
                      icon: Icons.inventory_2_outlined,
                      text: 'Items Donated: $itemsDonated'),
                  _MetaRow(
                      icon: Icons.people_outline,
                      text: 'Participants: $participantCount / $maxParticipants'),
                ],
              ),
            ),

            // ── Tap link ───────────────────────────────────────────────────
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 12, bottom: 10),
                child: GestureDetector(
                  onTap: onTap,
                  child: const Text(
                    'Tap To View Event →',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
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
}

// ---------------------------------------------------------------------------
// CharityEventListView
// ---------------------------------------------------------------------------
// FIREBASE INTEGRATION:
//   StreamBuilder<QuerySnapshot>(
//     stream: FirebaseFirestore.instance.collection('charity_events').snapshots(),
//     builder: (context, snapshot) {
//       if (!snapshot.hasData) return CircularProgressIndicator();
//       final events = snapshot.data!.docs
//           .map((doc) => CharityEvent.fromDoc(doc))
//           .toList();
//       return CharityEventListView(items: events);
//     },
//   );
// ---------------------------------------------------------------------------

class CharityEventListView extends StatelessWidget {
  final List<CharityEventListItem> items;

  const CharityEventListView({super.key, required this.items});

  factory CharityEventListView.placeholder() {
    return CharityEventListView(
      items: List.generate(
        3,
        (i) => CharityEventListItem(id: 'placeholder_$i', title: 'Event ${i + 1}'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: items.length,
      itemBuilder: (context, index) => items[index],
    );
  }
}

// ---------------------------------------------------------------------------
// Private helpers
// ---------------------------------------------------------------------------
class _CollaboratorAvatarRow extends StatelessWidget {
  final List<String> names;
  final List<String?> avatarUrls;

  const _CollaboratorAvatarRow(
      {required this.names, required this.avatarUrls});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        names.length.clamp(0, 3),
        (i) => Padding(
          padding: const EdgeInsets.only(right: 4),
          child: Row(
            children: [
              CircleAvatar(
                radius: 9,
                backgroundImage:
                    avatarUrls[i] != null ? NetworkImage(avatarUrls[i]!) : null,
                child:
                    avatarUrls[i] == null ? const Icon(Icons.person, size: 10) : null,
              ),
              const SizedBox(width: 3),
              Text(names[i],
                  style:
                      const TextStyle(fontSize: 9, color: Colors.black87)),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? valueColor;

  const _MetaRow({required this.icon, required this.text, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.black54),
          const SizedBox(width: 6),
          Expanded(
            child: Text(text,
                style: TextStyle(
                    fontSize: 11, color: valueColor ?? Colors.black87)),
          ),
        ],
      ),
    );
  }
}