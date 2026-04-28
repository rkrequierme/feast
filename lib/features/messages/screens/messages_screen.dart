// lib/features/messages/screens/messages_screen.dart
//
// Real-time chat list from Firestore.
// No placeholder data — all chats come from the database.
//
// REACT.JS INTEGRATION NOTE:
// =========================
// Collection: chats
// Fields: participantIds[], isGroup, groupName, groupImageUrl,
//         lastMessage, lastMessageAt, creatorId, adminIds[]
// React query:
//   const q = query(
//     collection(db, 'chats'),
//     where('participantIds', 'array-contains', uid),
//     orderBy('lastMessageAt', 'desc')
//   );
//   const snapshot = await getDocs(q);

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:feast/core/core.dart';
import 'package:feast/features/features.dart';

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
      () => setState(() => _searchQuery = _searchController.text.toLowerCase()),
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
          // Search bar
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
                  Icon(Icons.search, color: feastGray.withAlpha(150), size: 22),
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
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
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

          // Tab bar
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

          // Tab views
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

// ──────────────────────────────────────────────────────────────────────────
// _ChatList - Real-time Firestore chat list
// ──────────────────────────────────────────────────────────────────────────

class _ChatList extends StatelessWidget {
  final String filter;
  final String searchQuery;

  const _ChatList({required this.filter, required this.searchQuery});

  String _formatTimeAgo(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final date = timestamp.toDate();
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays == 1) return 'Yesterday';
    return DateFormat('MMM d').format(date);
  }

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

        var docs = snap.data?.docs ?? [];

        // Filter by tab
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
            default:
              return true;
          }
        }).toList();

        // Filter by search query
        if (searchQuery.isNotEmpty) {
          docs = docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final name = (data['groupName'] as String? ?? '').toLowerCase();
            return name.contains(searchQuery);
          }).toList();
        }

        if (docs.isEmpty) {
          return const EmptyStateWidget(message: 'No chats yet. Start a conversation!');
        }

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final doc = docs[i];
            final data = doc.data() as Map<String, dynamic>;
            final isGroup = data['isGroup'] as bool? ?? false;
            final name = data['groupName'] as String? ?? 
                (isGroup ? 'Group Chat' : 'Chat');
            final lastMessage = data['lastMessage'] as String? ?? '';
            final lastMessageAt = data['lastMessageAt'] as Timestamp?;
            final imageUrl = data['groupImageUrl'] as String?;
            final unreadCount = 0; // Implement unread count logic if needed

            return ChatListItem(
              id: doc.id,
              displayName: name,
              lastMessage: lastMessage.isEmpty ? 'No messages yet' : lastMessage,
              timeAgo: _formatTimeAgo(lastMessageAt),
              unreadCount: unreadCount,
              avatarUrl: imageUrl,
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
