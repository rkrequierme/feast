// lib/features/messages/screens/messages_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  String _username = 'User';

  @override
  void initState() {
    super.initState();
    _loadUsername();
    _tabController = TabController(length: 4, vsync: this);
    _searchController.addListener(
      () => setState(() => _searchQuery = _searchController.text.toLowerCase()),
    );
  }

  Future<void> _loadUsername() async {
    final name = await FirestoreService.instance.getCurrentUserName();
    if (mounted) setState(() => _username = name);
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
      appBar: FeastAppBar(title: 'Messages', username: _username),
      drawer: FeastDrawer(username: _username),
      body: Column(
        children: [
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
            onCreated: (chatId, isGroup) {
              debugPrint('Chat created: $chatId, isGroup: $isGroup');
              Navigator.pushNamed(
                context,
                isGroup ? AppRoutes.groupDetail : AppRoutes.chatDetail,
                arguments: chatId,
              );
            },
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
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    
    // First, get the user's chat IDs from their chats subcollection
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(FirestorePaths.users)
          .doc(currentUserId)
          .collection('chats')
          .snapshots(),
      builder: (context, userChatsSnap) {
        if (userChatsSnap.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: feastGreen),
          );
        }

        if (userChatsSnap.hasError) {
          debugPrint('User chats error: ${userChatsSnap.error}');
          return const Center(
            child: Text('Error loading chats. Please try again.'),
          );
        }

        final chatDocs = userChatsSnap.data?.docs ?? [];
        if (chatDocs.isEmpty) {
          return const EmptyStateWidget(message: 'No chats yet. Start a conversation!');
        }

        // Get all chat IDs
        final chatIds = chatDocs.map((doc) => doc.id).toList();
        
        if (chatIds.isEmpty) {
          return const EmptyStateWidget(message: 'No chats yet. Start a conversation!');
        }

        // Now fetch the actual chat documents
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection(FirestorePaths.chats)
              .where(FieldPath.documentId, whereIn: chatIds)
              .snapshots(),
          builder: (context, chatsSnap) {
            if (chatsSnap.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: feastGreen),
              );
            }

            if (chatsSnap.hasError) {
              debugPrint('Chats error: ${chatsSnap.error}');
              return const Center(
                child: Text('Error loading chats. Please try again.'),
              );
            }

            var docs = chatsSnap.data?.docs ?? [];
            debugPrint('Found ${docs.length} chats for user $currentUserId');

            // Sort by lastMessageAt (manual sort since whereIn doesn't support orderBy)
            docs.sort((a, b) {
              final aData = a.data() as Map<String, dynamic>;
              final bData = b.data() as Map<String, dynamic>;
              final aTime = aData['lastMessageAt'] as Timestamp?;
              final bTime = bData['lastMessageAt'] as Timestamp?;
              if (aTime == null && bTime == null) return 0;
              if (aTime == null) return 1;
              if (bTime == null) return -1;
              return bTime.compareTo(aTime);
            });

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
                
                // For DMs, we need to fetch the other user's name
                if (!isGroup) {
                  return FutureBuilder<DocumentSnapshot>(
                    future: _getOtherUser(data, currentUserId),
                    builder: (context, userSnap) {
                      if (userSnap.connectionState == ConnectionState.waiting) {
                        return const ListTile(
                          leading: CircleAvatar(child: Icon(Icons.person)),
                          title: Text('Loading...'),
                        );
                      }
                      
                      final userData = userSnap.data?.data() as Map<String, dynamic>?;
                      final displayName = userData?['displayName'] as String?;
                      final firstName = userData?['firstName'] as String? ?? '';
                      final lastName = userData?['lastName'] as String? ?? '';
                      final name = displayName ?? '$firstName $lastName'.trim();
                      final imageUrl = userData?['profilePictureUrl'] as String?;
                      final lastMessage = data['lastMessage'] as String? ?? 'No messages yet';
                      final lastMessageAt = data['lastMessageAt'] as Timestamp?;
                      
                      return ChatListItem(
                        id: doc.id,
                        displayName: name.isEmpty ? 'Chat' : name,
                        lastMessage: lastMessage,
                        timeAgo: _formatTimeAgo(lastMessageAt),
                        unreadCount: 0,
                        avatarUrl: imageUrl,
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.chatDetail,
                          arguments: doc.id,
                        ),
                      );
                    },
                  );
                }
                
                // For groups
                final name = data['groupName'] as String? ?? 'Group Chat';
                final imageUrl = data['groupImageUrl'] as String?;
                final lastMessage = data['lastMessage'] as String? ?? 'No messages yet';
                final lastMessageAt = data['lastMessageAt'] as Timestamp?;
                
                return ChatListItem(
                  id: doc.id,
                  displayName: name,
                  lastMessage: lastMessage,
                  timeAgo: _formatTimeAgo(lastMessageAt),
                  unreadCount: 0,
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
      },
    );
  }
  
  Future<DocumentSnapshot> _getOtherUser(Map<String, dynamic> chatData, String currentUserId) async {
    final participants = List<String>.from(chatData['participantIds'] as List? ?? []);
    final otherId = participants.firstWhere((id) => id != currentUserId, orElse: () => '');
    if (otherId.isEmpty) return Future.value(null as DocumentSnapshot);
    return FirebaseFirestore.instance.collection(FirestorePaths.users).doc(otherId).get();
  }
}
