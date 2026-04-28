import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feast/core/core.dart';
import 'package:feast/core/services/firestore_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// messages_screen.dart
//
// FIX (Image 1):
//   The old _ChatList called ChatListItem(data: data, chatId: doc.id, ...)
//   which doesn't match ChatListItem's required named params
//   (id, displayName, lastMessage).
//
//   Resolution: use the ChatListItem.fromMap() factory constructor that
//   was added to chat_list_item.dart precisely for this Firestore use-case.
//   The factory reads 'groupName', 'lastMessage', 'lastMessageAt', and
//   'groupImageUrl' from the document map and returns a correctly-typed widget.
// ─────────────────────────────────────────────────────────────────────────────

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _searchController.addListener(
      () => setState(
        () => _searchQuery = _searchController.text.toLowerCase(),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FeastAppBar(title: 'Messages'),
      drawer: const FeastDrawer(username: ''),
      body: Column(
        children: [
          // ── Search bar ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(15),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  Icon(Icons.search,
                      color: feastGray.withAlpha(150), size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'Outfit',
                        color: feastBlack,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search Your Chats',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Outfit',
                          color: feastGray.withAlpha(150),
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  if (_searchQuery.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: _searchController.clear,
                    ),
                ],
              ),
            ),
          ),

          // ── Tab bar ──────────────────────────────────────────────────────
          TabBar(
            controller: _tabController,
            labelColor: feastGreen,
            unselectedLabelColor: feastGray,
            indicatorColor: feastGreen,
            labelStyle: const TextStyle(
              fontFamily: 'Outfit',
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            tabs: const [
              Tab(text: 'All Chats'),
              Tab(text: 'Personal'),
              Tab(text: 'Events'),
              Tab(text: 'My Groups'),
            ],
          ),

          // ── Tab views ────────────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _ChatList(filter: 'all', searchQuery: _searchQuery),
                _ChatList(filter: 'personal', searchQuery: _searchQuery),
                _ChatList(filter: 'event', searchQuery: _searchQuery),
                _ChatList(filter: 'group', searchQuery: _searchQuery),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const FeastBottomNav(currentIndex: 3),
      floatingActionButton: FloatingActionButton(
        backgroundColor: feastGreen,
        tooltip: 'New Chat',
        child: const Icon(Icons.add_comment_outlined, color: Colors.white),
        onPressed: () => showDialog(
          context: context,
          builder: (_) => CreateChatModal(
            onCreated: (chatId, isGroup) => Navigator.pushNamed(
              context,
              isGroup ? AppRoutes.groupDetail : AppRoutes.chatDetail,
              arguments: chatId,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ChatList
//
// FIX (Image 1):
//   Changed the itemBuilder from:
//     return ChatListItem(data: data, chatId: doc.id, onTap: ...)
//   to:
//     return ChatListItem.fromMap(data, doc.id, onTap: ...)
//
//   ChatListItem.fromMap() is the factory defined in chat_list_item.dart
//   that converts the raw Firestore map into the widget's required named
//   fields (id, displayName, lastMessage, timeAgo, avatarUrl).
// ─────────────────────────────────────────────────────────────────────────────

class _ChatList extends StatelessWidget {
  final String filter; // 'all' | 'personal' | 'event' | 'group'
  final String searchQuery;

  const _ChatList({required this.filter, required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirestoreService.instance.chatsStream(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: feastGreen),
          );
        }

        // All chat documents the current user participates in
        var docs = snap.data?.docs ?? [];

        // ── Filter by tab ────────────────────────────────────────────────
        docs = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final isGroup = data['isGroup'] as bool? ?? false;
          final isEvent = data['isEventChat'] as bool? ?? false;
          switch (filter) {
            case 'personal':
              return !isGroup && !isEvent;
            case 'event':
              return isEvent;
            case 'group':
              return isGroup && !isEvent;
            default: // 'all'
              return true;
          }
        }).toList();

        // ── Filter by search query ───────────────────────────────────────
        if (searchQuery.isNotEmpty) {
          docs = docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final name =
                (data['groupName'] as String? ?? '').toLowerCase();
            return name.contains(searchQuery);
          }).toList();
        }

        if (docs.isEmpty) {
          return const EmptyStateWidget(message: 'No chats yet.');
        }

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final doc = docs[i];
            final data = doc.data() as Map<String, dynamic>;
            final isGroup = data['isGroup'] as bool? ?? false;

            // ── FIX: use the fromMap factory instead of named-field ctor ──
            // ChatListItem requires id, displayName, and lastMessage.
            // Passing raw `data:` and `chatId:` caused Image 1 errors.
            // fromMap() extracts those fields from the Firestore document.
            return ChatListItem.fromMap(
              data,
              doc.id,
              onTap: () => Navigator.pushNamed(
                context,
                isGroup ? AppRoutes.groupDetail : AppRoutes.chatDetail,
                arguments: doc.id,
              ),
            );
          },
        );
      },
    );
  }
}

// ■■ REACT.JS INTEGRATION NOTE ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
// Collection : chats
// Fields    : participantIds[], isGroup, isEventChat, groupName,
//             groupImageUrl, lastMessage, lastMessageAt,
//             creatorId, adminIds[]
// React     : onSnapshot(
//               query(collection(db,'chats'),
//               where('participantIds','array-contains', uid),
//               orderBy('lastMessageAt','desc'))
//             )
// Note      : Message content in sub-collection 'messages' is never
//             readable by admins — Firestore Security Rules enforce this.
// ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
