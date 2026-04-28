// lib/features/bookmarks/screens/bookmarks_screen.dart
//
// Real-time bookmarks from Firestore.
// Three tabs: All | Requests | Events.
// Left swipe: copy shareable link.
// Right swipe: remove bookmark (with confirmation).

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feast/core/core.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _username = 'User';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final name = await FirestoreService.instance.getCurrentUserName();
    if (mounted) setState(() => _username = name);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FeastAppBar(title: 'Bookmarks', username: _username),
      drawer: FeastDrawer(username: _username),
      body: FeastBackground(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                labelColor: feastGreen,
                unselectedLabelColor: feastGray,
                indicatorColor: feastGreen,
                indicatorWeight: 3,
                labelStyle: const TextStyle(
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
                tabs: const [
                  Tab(text: 'All'),
                  Tab(text: 'Requests'),
                  Tab(text: 'Events'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _BookmarkList(typeFilter: null),
                  _BookmarkList(typeFilter: 'request'),
                  _BookmarkList(typeFilter: 'event'),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const FeastBottomNav(currentIndex: -1),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────
// Bookmark List
// ──────────────────────────────────────────────────────────────────────────

class _BookmarkList extends StatelessWidget {
  final String? typeFilter;

  const _BookmarkList({required this.typeFilter});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirestoreService.instance.bookmarksStream(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: feastGreen));
        }

        var docs = snap.data?.docs ?? [];

        if (typeFilter != null) {
          docs = docs
              .where((d) => (d.data() as Map<String, dynamic>)['itemType'] == typeFilter)
              .toList();
        }

        if (docs.isEmpty) {
          return const EmptyStateWidget(message: 'No bookmarks saved yet.');
        }

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 40, top: 8),
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final doc = docs[i];
            final data = doc.data() as Map<String, dynamic>;
            return _BookmarkTile(doc: doc, data: data);
          },
        );
      },
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────
// Individual Bookmark Tile
// ──────────────────────────────────────────────────────────────────────────

class _BookmarkTile extends StatelessWidget {
  final QueryDocumentSnapshot doc;
  final Map<String, dynamic> data;

  const _BookmarkTile({required this.doc, required this.data});

  @override
  Widget build(BuildContext context) {
    final title = data['title'] as String? ?? '';
    final itemType = data['itemType'] as String? ?? 'request';
    final itemId = data['itemId'] as String? ?? doc.id;
    final isRequest = itemType == 'request';
    final accentColor = isRequest ? feastGreen : feastBlue;
    final route = isRequest ? AppRoutes.aidRequestDetail : AppRoutes.eventDetail;
    final shareLink = isRequest
        ? 'https://feast.app/requests/$itemId'
        : 'https://feast.app/events/$itemId';

    return Dismissible(
      key: Key(doc.id),
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 24),
        color: feastBlue,
        child: const Icon(Icons.copy, color: Colors.white, size: 28),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        color: feastError,
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          await Clipboard.setData(ClipboardData(text: shareLink));
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                  'Link copied to clipboard.',
                  style: TextStyle(fontFamily: 'Outfit'),
                ),
                backgroundColor: feastBlue,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                duration: const Duration(seconds: 2),
              ),
            );
          }
          return false;
        }
        return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                Icon(Icons.delete_forever_outlined, color: feastError, size: 28),
                const SizedBox(width: 8),
                const Text(
                  'Remove Bookmark',
                  style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: const Text(
              'Are you sure you want to remove this bookmark?',
              style: TextStyle(fontFamily: 'Outfit'),
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: feastError),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Remove', style: TextStyle(color: Colors.white)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel', style: TextStyle(fontFamily: 'Outfit')),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) async {
        if (direction == DismissDirection.endToStart) {
          await FirestoreService.instance.removeBookmark(itemId);
          if (context.mounted) {
            FeastToast.showSuccess(context, 'Bookmark removed.');
          }
        }
      },
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, route, arguments: itemId),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border(left: BorderSide(color: accentColor, width: 4)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(12),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: accentColor.withAlpha(25),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isRequest ? Icons.volunteer_activism_outlined : Icons.event_outlined,
                    color: accentColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: feastBlack,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: accentColor.withAlpha(20),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isRequest ? 'Aid Request' : 'Charity Event',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: accentColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: feastGray.withAlpha(120)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
