import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// bookmark_list_item.dart
//
// Swipeable bookmark card used in BookmarksScreen.
//   Swipe RIGHT → share (copy deep link to clipboard)
//   Swipe LEFT  → remove bookmark (confirmation dialog)
//
// FIREBASE WIRING (caller-side):
//   StreamBuilder<QuerySnapshot>(
//     stream: db.collection('users').doc(uid).collection('bookmarks')
//              .orderBy('createdAt', descending: true).snapshots(),
//     builder: (ctx, snap) {
//       final docs = snap.data?.docs ?? [];
//       return ListView.builder(
//         itemCount: docs.length,
//         itemBuilder: (_, i) {
//           final d = docs[i].data() as Map<String, dynamic>;
//           return BookmarkListItem.fromMap(d,
//             onRemove: () => docs[i].reference.delete(),
//           );
//         },
//       );
//     },
//   );
// ─────────────────────────────────────────────────────────────────────────────

enum BookmarkType { request, event }

class BookmarkListItem extends StatefulWidget {
  final String id;
  final BookmarkType type;
  final String title;
  final String author;
  final String category;
  final String description;
  final String? thumbnailUrl;
  final String? shareLink;

  /// Triggered after the user confirms removal.
  /// Caller is responsible for the Firestore delete.
  final VoidCallback? onRemove;

  const BookmarkListItem({
    super.key,
    required this.id,
    required this.type,
    required this.title,
    required this.author,
    required this.category,
    required this.description,
    this.thumbnailUrl,
    this.shareLink,
    this.onRemove,
  });

  /// Build from a Firestore map.
  factory BookmarkListItem.fromMap(
    Map<String, dynamic> data, {
    VoidCallback? onRemove,
  }) {
    return BookmarkListItem(
      id: data['id'] as String? ?? '',
      type: (data['type'] as String?) == 'event'
          ? BookmarkType.event
          : BookmarkType.request,
      title: data['title'] as String? ?? '',
      author: 'By: ${data['authorName'] ?? 'Unknown'}',
      category: 'Category: ${data['category'] ?? ''}',
      description: data['description'] as String? ?? '',
      thumbnailUrl: data['thumbnailUrl'] as String?,
      shareLink: data['shareLink'] as String?,
      onRemove: onRemove,
    );
  }

  Color get _accentColor =>
      type == BookmarkType.event
          ? feastLighterBlue.withAlpha(120)
          : feastLightYellow.withAlpha(180);

  @override
  State<BookmarkListItem> createState() => _BookmarkListItemState();
}

class _BookmarkListItemState extends State<BookmarkListItem> {
  bool _expanded = false;

  // ── Share ─────────────────────────────────────────────────────────────────

  Future<void> _handleShare() async {
    final link = widget.shareLink ?? 'https://feast.app/items/${widget.id}';
    await Clipboard.setData(ClipboardData(text: link));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Copied To Clipboard.',
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.black87,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ── Remove confirm ────────────────────────────────────────────────────────

  Future<bool> _confirmRemove() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _RemoveBookmarkDialog(
        onConfirm: () => Navigator.pop(ctx, true),
        onCancel: () => Navigator.pop(ctx, false),
      ),
    );
    return confirmed == true;
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(widget.id),
      // Swipe right = share
      background: _SwipeBackground(
        alignment: Alignment.centerLeft,
        color: feastGreen,
        icon: Icons.share,
        label: 'Share',
        padding: const EdgeInsets.only(left: 20),
      ),
      // Swipe left = remove
      secondaryBackground: _SwipeBackground(
        alignment: Alignment.centerRight,
        color: feastError,
        icon: Icons.bookmark_remove,
        label: 'Remove',
        padding: const EdgeInsets.only(right: 20),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          await _handleShare();
          return false; // never actually dismiss on share
        }
        return _confirmRemove();
      },
      onDismissed: (_) => widget.onRemove?.call(),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: widget._accentColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 3)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Collapsed row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(14),
                    bottomLeft: _expanded
                        ? Radius.zero
                        : const Radius.circular(14),
                  ),
                  child: SizedBox(
                    width: 80,
                    height: 80,
                    child: widget.thumbnailUrl != null
                        ? Image.network(widget.thumbnailUrl!, fit: BoxFit.cover)
                        : Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.image,
                                size: 32, color: Colors.grey),
                          ),
                  ),
                ),

                // Text content
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
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.author,
                          style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 11,
                              color: Colors.black54),
                        ),
                        Text(
                          widget.category,
                          style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 11,
                              color: Colors.black54),
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

            // Expanded description
            if (_expanded)
              Padding(
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

// ── Swipe background helper ───────────────────────────────────────────────────

class _SwipeBackground extends StatelessWidget {
  final Alignment alignment;
  final Color color;
  final IconData icon;
  final String label;
  final EdgeInsets padding;

  const _SwipeBackground({
    required this.alignment,
    required this.color,
    required this.icon,
    required this.label,
    required this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: padding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 26),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Remove confirmation dialog ────────────────────────────────────────────────

class _RemoveBookmarkDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const _RemoveBookmarkDialog({
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Close
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: onCancel,
                child: const Icon(Icons.close, size: 20, color: Colors.black45),
              ),
            ),
            // Icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.bookmark_remove,
                  color: Colors.red.shade400, size: 26),
            ),
            const SizedBox(height: 12),
            const Text(
              'Remove Bookmark',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Are you sure you want to remove this bookmark?',
              style: TextStyle(
                  fontFamily: 'Nunito', fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onConfirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  elevation: 0,
                ),
                child: const Text('Remove',
                    style: TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onCancel,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  elevation: 0,
                ),
                child: const Text('Cancel',
                    style: TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BookmarksListView
// Tab-filtered (All / Requests / Events) wrapper around BookmarkListItem.
// ─────────────────────────────────────────────────────────────────────────────

class BookmarksListView extends StatefulWidget {
  final List<BookmarkListItem> items;

  const BookmarksListView({super.key, required this.items});

  @override
  State<BookmarksListView> createState() => _BookmarksListViewState();
}

class _BookmarksListViewState extends State<BookmarksListView> {
  int _tab = 0; // 0=All, 1=Requests, 2=Events

  List<BookmarkListItem> get _requests =>
      widget.items.where((b) => b.type == BookmarkType.request).toList();
  List<BookmarkListItem> get _events =>
      widget.items.where((b) => b.type == BookmarkType.event).toList();

  @override
  Widget build(BuildContext context) {
    final tabs = ['All', 'Requests', 'Events'];

    return Column(
      children: [
        // Tab bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: List.generate(tabs.length, (i) {
              final sel = i == _tab;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _tab = i),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: sel ? feastGreen : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: sel ? feastGreen : Colors.grey.shade300,
                      ),
                    ),
                    child: Text(
                      tabs[i],
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

        // List
        Expanded(
          child: Builder(builder: (ctx) {
            late List<BookmarkListItem> visible;
            late String? requestHeader;
            late String? eventHeader;

            if (_tab == 0) {
              // All tab — show section headers
              final r = _requests;
              final e = _events;
              if (r.isEmpty && e.isEmpty) return _empty();
              return ListView(
                children: [
                  if (r.isNotEmpty) ...[
                    _sectionHeader('Aid Requests'),
                    ...r,
                  ],
                  if (e.isNotEmpty) ...[
                    _sectionHeader('Charity Events'),
                    ...e,
                  ],
                  _noMoreLabel(),
                ],
              );
            } else if (_tab == 1) {
              visible = _requests;
            } else {
              visible = _events;
            }

            if (visible.isEmpty) return _empty();
            return ListView(
              children: [...visible, _noMoreLabel()],
            );
          }),
        ),
      ],
    );
  }

  Widget _sectionHeader(String label) => Padding(
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

  Widget _empty() => const Center(
        child: Text(
          'No bookmarks here yet.',
          style: TextStyle(fontFamily: 'Nunito', color: Colors.black45),
        ),
      );

  Widget _noMoreLabel() => const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(
            'No more bookmarks.',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 12,
              color: Colors.black38,
            ),
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// BookmarksRegistry
// Lightweight in-memory registry for bookmark state across screens.
// REPLACE with a Firestore ChangeNotifier in production.
// ─────────────────────────────────────────────────────────────────────────────

class BookmarksRegistry extends ChangeNotifier {
  BookmarksRegistry._();
  static final BookmarksRegistry instance = BookmarksRegistry._();

  final Set<String> _bookmarkedIds = {};
  bool contains(String id) => _bookmarkedIds.contains(id);

  void add(String id) {
    _bookmarkedIds.add(id);
    notifyListeners();
  }

  void remove(String id) {
    _bookmarkedIds.remove(id);
    notifyListeners();
  }

  void toggle(String id) {
    if (contains(id)) {
      remove(id);
    } else {
      add(id);
    }
  }
}
