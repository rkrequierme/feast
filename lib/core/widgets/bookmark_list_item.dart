import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// BookmarkListItem
// ---------------------------------------------------------------------------
// A reusable tile for the Bookmarks screen (both Aid Requests & Events).
//
// FIREBASE INTEGRATION:
//   Subcollection : `users/{uid}/bookmarks`
//   Document fields expected:
//     - id          : String  (document ID = original request/event ID)
//     - type        : String  ('request' | 'event')
//     - title       : String
//     - author      : String  (e.g. "By: Jose De La Cruz")
//     - category    : String  (e.g. "Category: Disaster")
//     - description : String
//     - thumbnailUrl: String? (Storage URL)
//
//   To wire up:
//     1. Create a `Bookmark` model from DocumentSnapshot.
//     2. StreamBuilder on `users/{uid}/bookmarks` with optional type filter.
//     3. To remove bookmark: delete the document from the subcollection.
//     4. Share button: use Flutter's share_plus package with a deep link.
//
//   DATABASE STRUCTURE NEEDED:
//     users/{uid}/bookmarks/{itemId}  ← stores a copy of key fields
//     so reads are fast without joining back to the original collection.
// ---------------------------------------------------------------------------

enum BookmarkType { request, event }

class BookmarkListItem extends StatelessWidget {
  final String id;
  final BookmarkType type;
  final String title;
  final String author;
  final String category;
  final String description;
  final String? thumbnailUrl;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;
  final VoidCallback? onShare;

  const BookmarkListItem({
    super.key,
    this.id = 'placeholder_id',
    this.type = BookmarkType.request,
    this.title = 'Bookmarked Item Title',
    this.author = 'By: Placeholder Author',
    this.category = 'Category: Placeholder',
    this.description = 'A short description of this bookmarked item.',
    this.thumbnailUrl,
    this.onTap,
    this.onRemove,
    this.onShare,
  });

  Color get _accentColor =>
      type == BookmarkType.event ? Colors.blue.shade100 : Colors.yellow.shade100;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: _accentColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 3)],
        ),
        child: Row(
          children: [
            // ── Thumbnail ──────────────────────────────────────────────────
            ClipRRect(
              borderRadius:
                  const BorderRadius.horizontal(left: Radius.circular(14)),
              child: SizedBox(
                width: 80,
                height: 90,
                // TODO: replace with CachedNetworkImage(imageUrl: thumbnailUrl)
                child: thumbnailUrl != null
                    ? Image.network(thumbnailUrl!, fit: BoxFit.cover)
                    : Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.image,
                            size: 32, color: Colors.grey)),
              ),
            ),

            // ── Text content ───────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 2),
                    Text(author,
                        style: const TextStyle(
                            fontSize: 11, color: Colors.black54)),
                    Text(category,
                        style: const TextStyle(
                            fontSize: 11, color: Colors.black54)),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 11, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ),

            // ── Action buttons ─────────────────────────────────────────────
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ActionIconButton(
                  icon: Icons.share,
                  color: Colors.green,
                  onTap: onShare,
                ),
                const SizedBox(height: 6),
                _ActionIconButton(
                  icon: Icons.bookmark_remove,
                  color: Colors.red,
                  onTap: onRemove,
                ),
              ],
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// BookmarksListView
// ---------------------------------------------------------------------------
// Tab-filtered list of Aid Requests and Charity Events bookmarks.
//
// FIREBASE INTEGRATION:
//   - Stream `users/{uid}/bookmarks` and split by `type` field.
//   - Tabs: 'All', 'Requests', 'Events'
//   - On remove: FirebaseFirestore.instance
//       .doc('users/$uid/bookmarks/$itemId').delete()
//   - On share: SharePlus.share(deepLink) where deepLink navigates to item.
// ---------------------------------------------------------------------------

class BookmarksListView extends StatefulWidget {
  final List<BookmarkListItem> allItems;

  const BookmarksListView({super.key, required this.allItems});

  factory BookmarksListView.placeholder() {
    return BookmarksListView(
      allItems: [
        const BookmarkListItem(
            id: '1',
            type: BookmarkType.request,
            title: "My Kid's Cancer Treatment",
            author: 'By: Jacob Velasquez',
            category: 'Category: Health'),
        const BookmarkListItem(
            id: '2',
            type: BookmarkType.request,
            title: "Our Family's Tuition Fee Aid",
            author: 'By: Anne Rosales',
            category: 'Category: Education'),
        const BookmarkListItem(
            id: '3',
            type: BookmarkType.request,
            title: 'The Gallardas Need Food',
            author: 'By: Nora Gallarda',
            category: 'Category: Food'),
        const BookmarkListItem(
            id: '4',
            type: BookmarkType.event,
            title: 'Flood Relief Project',
            author: 'By: Jose De La Cruz',
            category: 'Category: Disaster'),
        const BookmarkListItem(
            id: '5',
            type: BookmarkType.event,
            title: 'Give Children Books',
            author: 'By: Lee Guzman',
            category: 'Category: Education'),
      ],
    );
  }

  @override
  State<BookmarksListView> createState() => _BookmarksListViewState();
}

class _BookmarksListViewState extends State<BookmarksListView> {
  int _selectedTab = 0; // 0=All, 1=Requests, 2=Events
  final _tabs = ['All', 'Requests', 'Events'];

  List<BookmarkListItem> get _filtered {
    if (_selectedTab == 1) {
      return widget.allItems
          .where((b) => b.type == BookmarkType.request)
          .toList();
    }
    if (_selectedTab == 2) {
      return widget.allItems
          .where((b) => b.type == BookmarkType.event)
          .toList();
    }
    return widget.allItems;
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtered;
    return Column(
      children: [
        // ── Tab bar ───────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: List.generate(_tabs.length, (i) {
              final sel = i == _selectedTab;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedTab = i),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: sel ? Colors.green : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: sel ? Colors.green : Colors.grey.shade300),
                    ),
                    child: Text(
                      _tabs[i],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: sel ? Colors.white : Colors.black87,
                        fontWeight:
                            sel ? FontWeight.bold : FontWeight.normal,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),

        // ── Items ─────────────────────────────────────────────────────────
        Expanded(
          child: items.isEmpty
              ? const Center(
                  child: Text('No bookmarks.',
                      style: TextStyle(color: Colors.black45)))
              : ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (_, i) => items[i],
                ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Private helper
// ---------------------------------------------------------------------------
class _ActionIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _ActionIconButton(
      {required this.icon, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }
}