import 'package:flutter/material.dart';
import 'package:feast/core/core.dart';

// ---------------------------------------------------------------------------
// BookmarksScreen
// ---------------------------------------------------------------------------
// Hosts the BookmarksListView widget.
//
// FIREBASE INTEGRATION:
//   1. Replace _allItems with a real Firestore stream:
//        StreamBuilder on `users/{uid}/bookmarks` ordered by savedAt desc.
//   2. Map each DocumentSnapshot to a BookmarkListItem, passing onRemove:
//        () => FirebaseFirestore.instance
//               .doc('users/$uid/bookmarks/$itemId').delete()
//   3. For share, pass shareLink: the deep-link URL for the item.
// ---------------------------------------------------------------------------

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  // ── Placeholder data ──────────────────────────────────────────────────────
  // Replace with data mapped from Firestore DocumentSnapshots.
  late List<BookmarkListItem> _allItems;

  @override
  void initState() {
    super.initState();

    // TODO: replace with Firestore stream subscription.
    _allItems = [
      BookmarkListItem(
        id: '1',
        type: BookmarkType.request,
        title: "My Kid's Cancer Treatment",
        author: 'By: Jacob Velasquez',
        category: 'Category: Health',
        description:
            'Your generous contribution can give life-saving support '
            'to a child fighting cancer. Every peso counts toward '
            'treatment and recovery.',
        onRemove: () => _removeItem('1'),
        shareLink: 'https://feast.app/requests/1',
      ),
      BookmarkListItem(
        id: '2',
        type: BookmarkType.request,
        title: "Our Family's Tuition Fee Aid",
        author: 'By: Anne Rosales',
        category: 'Category: Education',
        description:
            'Help my sister pay off her tuition fees so she can '
            'continue her studies and build a better future.',
        onRemove: () => _removeItem('2'),
        shareLink: 'https://feast.app/requests/2',
      ),
      BookmarkListItem(
        id: '3',
        type: BookmarkType.request,
        title: 'The Gallardas Need Food',
        author: 'By: Nora Gallarda',
        category: 'Category: Food',
        description:
            'The Gallarda family is currently facing a difficult period '
            'and is seeking community support to secure essential groceries '
            'and daily meals.',
        onRemove: () => _removeItem('3'),
        shareLink: 'https://feast.app/requests/3',
      ),
      BookmarkListItem(
        id: '4',
        type: BookmarkType.event,
        title: 'Flood Relief Project',
        author: 'By: Jose De La Cruz',
        category: 'Category: Disaster',
        description:
            'Helping Filipino families get back on their feet after '
            'devastating floods by providing emergency relief goods '
            'and temporary shelter.',
        onRemove: () => _removeItem('4'),
        shareLink: 'https://feast.app/events/4',
      ),
      BookmarkListItem(
        id: '5',
        type: BookmarkType.event,
        title: 'Give Children Books',
        author: 'By: Lee Guzman',
        category: 'Category: Education',
        description:
            'Sharing the joy of reading by collecting, sorting, and '
            'distributing books to underprivileged children across '
            'Almanza Dos.',
        onRemove: () => _removeItem('5'),
        shareLink: 'https://feast.app/events/5',
      ),
    ];
  }

  // ── Handlers ──────────────────────────────────────────────────────────────

  /// Removes the item from local state after the confirm dialog resolves true.
  /// Wire the TODO below to Firestore when integrating.
  void _removeItem(String id) {
    setState(() {
      _allItems = _allItems.where((item) => item.id != id).toList();
    });

    // TODO: delete from Firestore:
    // await FirebaseFirestore.instance
    //     .doc('users/$currentUid/bookmarks/$id')
    //     .delete();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FeastAppBar(title: 'Bookmarks'),
      drawer: const FeastDrawer(username: 'Juan De La Cruz'),
      bottomNavigationBar: const FeastBottomNav(currentIndex: -1),
      body: FeastBackground(
        child: SafeArea(
          child: BookmarksListView(allItems: _allItems),
        ),
      ),
    );
  }
}