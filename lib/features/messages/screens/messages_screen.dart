import 'package:flutter/material.dart';
import 'package:feast/core/core.dart';
import 'selected_chat_screen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedTab = 0;

  final List<String> _tabs = [
    'All Chats',
    'Personal Chats',
    'Events',
    'My Groups',
  ];

  // Maps tab index → chat type filter (null = show all)
  static const List<ChatType?> _tabTypeFilter = [
    null,
    ChatType.personal,
    ChatType.event,
    ChatType.myGroup,
  ];

  List<ChatItem> get _filteredChats {
    final query = _searchController.text.toLowerCase().trim();
    final typeFilter = _tabTypeFilter[_selectedTab];

    return ChatStore.chats.where((c) {
      final matchesTab = typeFilter == null || c.type == typeFilter;
      final matchesSearch = query.isEmpty ||
          c.name.toLowerCase().contains(query) ||
          c.lastMessage.toLowerCase().contains(query);
      return matchesTab && matchesSearch;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openChat(ChatItem chat) {
    // Clear unread badge before navigating
    setState(() {
      ChatStore.markRead(chat.id);
    });
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SelectedChatScreen(chatId: chat.id),
      ),
    ).then((_) => setState(() {})); // Refresh on return
  }

  void _showNewChatModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => NewChatModal(
        onCreated: () => setState(() {}),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FeastAppBar(title: 'Messages'),
      drawer: const FeastDrawer(username: 'Juan De La Cruz'),
      body: FeastBackground(
        child: Column(
          children: [
            const SizedBox(height: 12),
            _buildSearchBar(),
            const SizedBox(height: 10),
            _buildFilterTabs(),
            const SizedBox(height: 4),
            Expanded(child: _buildChatList()),
          ],
        ),
      ),
      bottomNavigationBar: const FeastBottomNav(currentIndex: 3),
      floatingActionButton: FeastFloatingButton(
        icon: Icons.chat_bubble_outline,
        onPressed: _showNewChatModal,
        tooltip: 'New Chat',
      ),
    );
  }

  // ─── SEARCH BAR ───────────────────────────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: feastGray.withAlpha(40)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(12),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            Icon(Icons.search, color: feastGray.withAlpha(160), size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
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
            if (_searchController.text.isNotEmpty)
              IconButton(
                icon: Icon(Icons.close, color: feastGray.withAlpha(150), size: 18),
                onPressed: () {
                  _searchController.clear();
                  setState(() {});
                },
                splashRadius: 18,
              ),
          ],
        ),
      ),
    );
  }

  // ─── FILTER TABS ──────────────────────────────────
  Widget _buildFilterTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(_tabs.length, (i) {
          final selected = i == _selectedTab;
          return GestureDetector(
            onTap: () => setState(() => _selectedTab = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? feastGreen : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected ? feastGreen : feastGray.withAlpha(80),
                  width: 1.5,
                ),
              ),
              child: Text(
                _tabs[i],
                style: TextStyle(
                  color: selected ? Colors.white : feastBlack,
                  fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 13,
                  fontFamily: 'Outfit',
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ─── CHAT LIST ────────────────────────────────────
  Widget _buildChatList() {
    final chats = _filteredChats;

    if (chats.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.chat_bubble_outline, size: 48, color: feastGray.withAlpha(80)),
            const SizedBox(height: 12),
            Text(
              _searchController.text.isNotEmpty
                  ? 'No chats match your search'
                  : 'No chats here yet',
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Outfit',
                color: feastGray.withAlpha(150),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: chats.length,
      separatorBuilder: (_, __) => Divider(
        height: 1,
        indent: 72,
        color: feastGray.withAlpha(30),
      ),
      itemBuilder: (context, index) => _buildChatItem(chats[index]),
    );
  }

  // ─── CHAT LIST ITEM ───────────────────────────────
  Widget _buildChatItem(ChatItem chat) {
    final isGroup = chat.type != ChatType.personal;
    final unread = chat.unreadCount;

    return InkWell(
      onTap: () => _openChat(chat),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        child: Row(
          children: [
            // Avatar
            Stack(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: feastLightGreen.withAlpha(140),
                  backgroundImage: chat.avatarUrl != null
                      ? NetworkImage(chat.avatarUrl!)
                      : null,
                  child: chat.avatarUrl == null
                      ? Icon(
                          isGroup ? Icons.group : Icons.person,
                          size: 26,
                          color: feastGreen,
                        )
                      : null,
                ),
                if (chat.isOnline)
                  Positioned(
                    bottom: 1,
                    right: 1,
                    child: Container(
                      width: 13,
                      height: 13,
                      decoration: BoxDecoration(
                        color: feastGreen,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),

            // Name + preview
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat.name,
                          style: TextStyle(
                            fontWeight: unread > 0 ? FontWeight.bold : FontWeight.w600,
                            fontSize: 15,
                            fontFamily: 'Outfit',
                            color: feastBlack,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (chat.type == ChatType.event)
                        Container(
                          margin: const EdgeInsets.only(left: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: feastLightGreen,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Event',
                            style: TextStyle(fontSize: 9, color: feastGreen, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
                          ),
                        ),
                      if (chat.type == ChatType.myGroup)
                        Container(
                          margin: const EdgeInsets.only(left: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: feastLightGreen,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Group',
                            style: TextStyle(fontSize: 9, color: feastGreen, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    chat.lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'Outfit',
                      color: unread > 0
                          ? feastBlack.withAlpha(200)
                          : feastGray.withAlpha(180),
                      fontWeight: unread > 0 ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Time + unread badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  chat.lastMessageTime,
                  style: TextStyle(
                    fontSize: 11,
                    fontFamily: 'Outfit',
                    color: feastGray.withAlpha(150),
                  ),
                ),
                const SizedBox(height: 5),
                if (unread > 0)
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                      color: feastGreen,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$unread',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Outfit',
                      ),
                    ),
                  )
                else
                  const SizedBox(height: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}