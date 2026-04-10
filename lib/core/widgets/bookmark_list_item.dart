import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ---------------------------------------------------------------------------
// BookmarkListItem
// ---------------------------------------------------------------------------
// A reusable, expandable tile for the Bookmarks screen.
//
// BEHAVIOUR:
//   - Arrow button on the right toggles the description visible/hidden.
//   - Swipe RIGHT  → reveals red   "Remove" background → confirm dialog.
//   - Swipe LEFT   → reveals green "Share"  background → copies a link to
//                    the clipboard and shows a "Copied To Clipboard." snackbar.
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
//     - shareLink   : String? (deep link for share)
//
//   To wire up:
//     1. Create a `Bookmark` model from DocumentSnapshot.
//     2. StreamBuilder on `users/{uid}/bookmarks` with optional type filter.
//     3. To remove bookmark: delete the document from the subcollection.
//     4. Share: replace Clipboard.setData with share_plus SharePlus.share().
// ---------------------------------------------------------------------------

enum BookmarkType { request, event }

class BookmarkListItem extends StatefulWidget {
  final String id;
  final BookmarkType type;
  final String title;
  final String author;
  final String category;
  final String description;
  final String? thumbnailUrl;

  /// Called after the user confirms removal via the dialog.
  final VoidCallback? onRemove;

  /// Optional deep link string copied to clipboard on share.
  /// Defaults to a placeholder if not provided.
  final String? shareLink;

  const BookmarkListItem({
    super.key,
    this.id = 'placeholder_id',
    this.type = BookmarkType.request,
    this.title = 'Bookmarked Item Title',
    this.author = 'By: Placeholder Author',
    this.category = 'Category: Placeholder',
    this.description = 'A short description of this bookmarked item.',
    this.thumbnailUrl,
    this.onRemove,
    this.shareLink,
  });

  Color get accentColor => type == BookmarkType.event
      ? Colors.blue.shade100
      : Colors.yellow.shade100;

  @override
  State<BookmarkListItem> createState() => _BookmarkListItemState();
}

class _BookmarkListItemState extends State<BookmarkListItem> {
  bool _expanded = false;

  // ── Share action ──────────────────────────────────────────────────────────

  Future<void> _handleShare() async {
    final link = widget.shareLink ??
        'https://feast.app/items/${widget.id}'; // TODO: replace with real deep link
    await Clipboard.setData(ClipboardData(text: link));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Copied To Clipboard.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        backgroundColor: Colors.black87,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ── Remove confirm dialog ─────────────────────────────────────────────────

  Future<bool> _confirmRemove() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.bookmark_remove,
                        color: Colors.red, size: 22),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx, false),
                    child: const Icon(Icons.close,
                        color: Colors.black45, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Text(
                'Remove Bookmark',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Are you sure you want to remove this bookmark?',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 13,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 20),
              // Remove button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Remove',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Cancel button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    return confirmed == true;
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(widget.id),
      // ── Swipe RIGHT → Share (green) ──────────────────────────────────────
      background: Container(
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.only(left: 20),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.share, color: Colors.white, size: 26),
            SizedBox(height: 4),
            Text(
              'Share',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
      // ── Swipe LEFT → Remove (red) ────────────────────────────────────────
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.only(right: 20),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_remove, color: Colors.white, size: 26),
            SizedBox(height: 4),
            Text(
              'Remove',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Swipe right = share — never actually dismiss the tile
          await _handleShare();
          return false;
        } else {
          // Swipe left = remove
          return await _confirmRemove();
        }
      },
      onDismissed: (_) => widget.onRemove?.call(),
      // ── Tile ──────────────────────────────────────────────────────────────
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: widget.accentColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 3),
          ],
        ),
        child: Column(
          children: [
            // ── Collapsed row ──────────────────────────────────────────────
            Row(
              children: [
                // Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(14),
                    bottomLeft:
                        _expanded ? Radius.zero : const Radius.circular(14),
                  ),
                  child: SizedBox(
                    width: 80,
                    height: 80,
                    child: widget.thumbnailUrl != null
                        ? Image.network(widget.thumbnailUrl!,
                            fit: BoxFit.cover)
                        : Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.image,
                                size: 32, color: Colors.grey),
                          ),
                  ),
                ),

                // Text
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.author,
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 11,
                            color: Colors.black54,
                          ),
                        ),
                        Text(
                          widget.category,
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 11,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Expand/collapse arrow
                GestureDetector(
                  onTap: () => setState(() => _expanded = !_expanded),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      _expanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      size: 22,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ],
            ),

            // ── Expanded description ───────────────────────────────────────
            if (_expanded)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Text(
                  widget.description,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12,
                    color: Colors.black87,
                    height: 1.5,
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
// BookmarksListView
// ---------------------------------------------------------------------------
// Tab-filtered list of Aid Requests and Charity Events bookmarks.
// In "All" tab, items are grouped under section headers.
//
// FIREBASE INTEGRATION:
//   - Stream `users/{uid}/bookmarks` and split by `type` field.
//   - Tabs: 'All', 'Requests', 'Events'
//   - onRemove: FirebaseFirestore.instance
//       .doc('users/$uid/bookmarks/$itemId').delete()
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
          category: 'Category: Health',
          description:
              'Your generous contribution can give life-saving support '
              'to a child fighting cancer. Every peso counts toward '
              'treatment and recovery.',
        ),
        const BookmarkListItem(
          id: '2',
          type: BookmarkType.request,
          title: "Our Family's Tuition Fee Aid",
          author: 'By: Anne Rosales',
          category: 'Category: Education',
          description:
              'Help my sister pay off her tuition fees so she can '
              'continue her studies and build a better future.',
        ),
        const BookmarkListItem(
          id: '3',
          type: BookmarkType.request,
          title: 'The Gallardas Need Food',
          author: 'By: Nora Gallarda',
          category: 'Category: Food',
          description:
              'The Gallarda family is currently facing a difficult period '
              'and is seeking community support to secure essential groceries '
              'and daily meals.',
        ),
        const BookmarkListItem(
          id: '4',
          type: BookmarkType.event,
          title: 'Flood Relief Project',
          author: 'By: Jose De La Cruz',
          category: 'Category: Disaster',
          description:
              'Helping Filipino families get back on their feet after '
              'devastating floods by providing emergency relief goods '
              'and temporary shelter.',
        ),
        const BookmarkListItem(
          id: '5',
          type: BookmarkType.event,
          title: 'Give Children Books',
          author: 'By: Lee Guzman',
          category: 'Category: Education',
          description:
              'Sharing the joy of reading by collecting, sorting, and '
              'distributing books to underprivileged children across '
              'Almanza Dos.',
        ),
      ],
    );
  }

  @override
  State<BookmarksListView> createState() => _BookmarksListViewState();
}

class _BookmarksListViewState extends State<BookmarksListView> {
  int _selectedTab = 0; // 0=All, 1=Requests, 2=Events
  final _tabs = ['All', 'Requests', 'Events'];

  List<BookmarkListItem> get _requests => widget.allItems
      .where((b) => b.type == BookmarkType.request)
      .toList();

  List<BookmarkListItem> get _events => widget.allItems
      .where((b) => b.type == BookmarkType.event)
      .toList();

  // ── Section header widget ──────────────────────────────────────────────────

  Widget _sectionHeader(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Nunito',
          fontWeight: FontWeight.bold,
          fontSize: 13,
          color: Colors.black54,
        ),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Tab bar ─────────────────────────────────────────────────────────
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
                        color: sel ? Colors.green : Colors.grey.shade300,
                      ),
                    ),
                    child: Text(
                      _tabs[i],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Nunito',
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

        // ── List ────────────────────────────────────────────────────────────
        Expanded(
          child: Builder(builder: (context) {
            // All tab: show grouped sections
            if (_selectedTab == 0) {
              final requests = _requests;
              final events = _events;
              if (requests.isEmpty && events.isEmpty) {
                return _emptyState();
              }
              return ListView(
                children: [
                  if (requests.isNotEmpty) ...[
                    _sectionHeader('Aid Requests'),
                    ...requests,
                  ],
                  if (events.isNotEmpty) ...[
                    _sectionHeader('Charity Events'),
                    ...events,
                  ],
                  _noMoreLabel(),
                ],
              );
            }

            // Requests tab
            if (_selectedTab == 1) {
              final items = _requests;
              if (items.isEmpty) return _emptyState();
              return ListView(
                children: [...items, _noMoreLabel()],
              );
            }

            // Events tab
            final items = _events;
            if (items.isEmpty) return _emptyState();
            return ListView(
              children: [...items, _noMoreLabel()],
            );
          }),
        ),
      ],
    );
  }

  Widget _emptyState() {
    return const Center(
      child: Text(
        'No bookmarks.',
        style: TextStyle(
          fontFamily: 'Nunito',
          color: Colors.black45,
        ),
      ),
    );
  }

  Widget _noMoreLabel() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Text(
          'No more notifications.',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 12,
            color: Colors.black38,
          ),
        ),
      ),
    );
  }
}