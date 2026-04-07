import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// AidRequestListItem
// ---------------------------------------------------------------------------
// A reusable card widget for displaying a single Aid Request in a list.
//
// FIREBASE INTEGRATION:
//   Collection : `aid_requests`
//   Document fields expected:
//     - id            : String  (document ID)
//     - title         : String  (e.g. "Surgery Meds & Treatment")
//     - description   : String  (short blurb shown on card)
//     - category      : String  (e.g. "Health (Support & Supply)")
//     - location      : String  (e.g. "DBP Village, Almarza Dos")
//     - daysRemaining : int     (e.g. 7)
//     - aidFundsGoal  : double  (e.g. 5000)
//     - itemsDonated  : int
//     - donorCount    : int
//     - beneficiaryName : String
//     - beneficiaryAvatarUrl : String (Storage URL)
//     - imageUrls     : List<String> (Storage URLs for the card hero image)
//
//   To wire up:
//     1. Create a `AidRequest` model class that maps from DocumentSnapshot.
//     2. Use a StreamBuilder / FutureBuilder with FirebaseFirestore.instance
//        .collection('aid_requests').snapshots() to obtain a List<AidRequest>.
//     3. Pass each AidRequest into this widget replacing the placeholder values.
// ---------------------------------------------------------------------------

class AidRequestListItem extends StatelessWidget {
  // Replace these with fields from your AidRequest model once Firebase is wired.
  final String id;
  final String title;
  final String description;
  final String category;
  final String location;
  final int daysRemaining;
  final double aidFundsGoal;
  final int itemsDonated;
  final int donorCount;
  final String beneficiaryName;
  final String? beneficiaryAvatarUrl; // nullable until real data arrives
  final String? heroImageUrl;         // nullable until real data arrives
  final VoidCallback? onTap;

  const AidRequestListItem({
    super.key,
    // --- Placeholder defaults (remove defaults once Firebase is connected) ---
    this.id = 'placeholder_id',
    this.title = 'Aid Request Title',
    this.description =
        'Your generous contribution can provide life-saving support '
        'and essential care for someone in urgent need.',
    this.category = 'Health (Support & Supply)',
    this.location = 'DBP Village, Almarza Dos',
    this.daysRemaining = 7,
    this.aidFundsGoal = 5000,
    this.itemsDonated = 3,
    this.donorCount = 5,
    this.beneficiaryName = 'Jacob Vasquez',
    this.beneficiaryAvatarUrl,
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
            // ── Hero image + title overlay ──────────────────────────────────
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
                            child: Icon(Icons.image, size: 48, color: Colors.grey)),
                  ),
                  // Title card in top-right corner
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
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
                          Text(
                            title,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              // Beneficiary avatar
                              CircleAvatar(
                                radius: 10,
                                backgroundImage: beneficiaryAvatarUrl != null
                                    ? NetworkImage(beneficiaryAvatarUrl!)
                                    : null,
                                child: beneficiaryAvatarUrl == null
                                    ? const Icon(Icons.person, size: 12)
                                    : null,
                              ),
                              const SizedBox(width: 4),
                              Text(beneficiaryName,
                                  style: const TextStyle(fontSize: 11)),
                            ],
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
                      icon: Icons.category_outlined, text: 'Request Category: $category'),
                  _MetaRow(
                      icon: Icons.location_on_outlined, text: 'Location: $location'),
                  _MetaRow(
                      icon: Icons.access_time,
                      text: 'Time Remaining: $daysRemaining Days Left'),
                  _MetaRow(
                      icon: Icons.attach_money,
                      text:
                          'Aid Funds Donated: ₱${aidFundsGoal.toStringAsFixed(0)}'),
                  _MetaRow(
                      icon: Icons.inventory_2_outlined,
                      text: 'Items Donated: $itemsDonated'),
                  _MetaRow(
                      icon: Icons.people_outline, text: 'Donors: $donorCount'),
                ],
              ),
            ),

            // ── "Tap To View Request" link ─────────────────────────────────
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 12, bottom: 10),
                child: GestureDetector(
                  onTap: onTap,
                  child: const Text(
                    'Tap To View Request →',
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
// AidRequestListView
// ---------------------------------------------------------------------------
// Wraps a list of [AidRequestListItem] widgets in a scrollable ListView.
//
// FIREBASE INTEGRATION:
//   Replace the `items` placeholder list with data fetched from Firestore.
//   Example usage inside a Screen:
//
//     StreamBuilder<QuerySnapshot>(
//       stream: FirebaseFirestore.instance.collection('aid_requests').snapshots(),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) return CircularProgressIndicator();
//         final requests = snapshot.data!.docs
//             .map((doc) => AidRequest.fromDoc(doc))
//             .toList();
//         return AidRequestListView(items: requests);
//       },
//     );
// ---------------------------------------------------------------------------

class AidRequestListView extends StatelessWidget {
  /// Pass a real list of AidRequestListItem widgets built from your model.
  final List<AidRequestListItem> items;

  const AidRequestListView({super.key, required this.items});

  // Placeholder factory – remove once Firebase data is supplied.
  factory AidRequestListView.placeholder() {
    return AidRequestListView(
      items: List.generate(
        4,
        (i) => AidRequestListItem(
          id: 'placeholder_$i',
          title: 'Aid Request ${i + 1}',
        ),
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
// Private helper
// ---------------------------------------------------------------------------
class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MetaRow({required this.icon, required this.text});

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
                style:
                    const TextStyle(fontSize: 11, color: Colors.black87)),
          ),
        ],
      ),
    );
  }
}