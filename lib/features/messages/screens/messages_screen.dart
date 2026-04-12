import 'package:flutter/material.dart';
import 'package:feast/core/core.dart';

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

  // ─── Placeholder chat data ───
  final List<Map<String, dynamic>> _chats = [
    {
      'name': 'Darlene Lopez',
      'message': 'Pls take a look at the donations.',
      'time': '5 min',
      'unread': 5,
      'isOnline': true,
      'type': 'personal',
    },
    {
      'name': 'T.S. Cruz Food Bank',
      'message': 'Hello guys, we have discussed about ...',
      'time': '30 min',
      'unread': 0,
      'isOnline': true,
      'type': 'group',
    },
    {
      'name': 'Lee Fernandez',
      'message': "Yes, that's gonna help them out, hopefully.",
      'time': '1 hr',
      'unread': 0,
      'isOnline': false,
      'type': 'personal',
    },
    {
      'name': 'Ronald Mendoza',
      'message': '✔✔ Thank you po! 😊',
      'time': 'Yesterday',
      'unread': 0,
      'isOnline': false,
      'type': 'personal',
    },
    {
      'name': 'Albert Flores',
      'message': "I'm happy this event has such grea...",
      'time': 'Yesterday',
      'unread': 0,
      'isOnline': false,
      'type': 'event',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FeastAppBar(title: 'Messages'),
      drawer: const FeastDrawer(username: 'Juan De La Cruz'),
      body: FeastBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const SizedBox(height: 12),

              // ─── Search Bar ───
              _buildSearchBar(),

              const SizedBox(height: 12),

              // ─── Filter Tabs ───
              _buildFilterTabs(),

              const SizedBox(height: 8),

              // ─── Chat List ───
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: _chats.length,
                  separatorBuilder: (_, __) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Divider(height: 1, color: feastGray.withAlpha(40)),
                  ),
                  itemBuilder: (context, index) =>
                      _buildChatListItem(_chats[index]),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: FeastBottomNav(currentIndex: 3),
      floatingActionButton: FeastFloatingButton(
        icon: Icons.chat_bubble_outline,
        onPressed: () {
          // Create new chat action
        },
        tooltip: 'New Chat',
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  // ─── SEARCH BAR ───
  // ═══════════════════════════════════════════════════
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
            IconButton(
              icon: Icon(
                Icons.close,
                color: feastGray.withAlpha(150),
                size: 20,
              ),
              onPressed: () {
                _searchController.clear();
              },
              splashRadius: 20,
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  // ─── FILTER TABS ───
  // ═══════════════════════════════════════════════════
  Widget _buildFilterTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(_tabs.length, (i) {
          final selected = i == _selectedTab;
          return GestureDetector(
            onTap: () => setState(() => _selectedTab = i),
            child: Container(
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

  // ═══════════════════════════════════════════════════
  // ─── CHAT LIST ITEM ───
  // ═══════════════════════════════════════════════════
  Widget _buildChatListItem(Map<String, dynamic> chat) {
    final bool isGroup = chat['type'] == 'group' || chat['type'] == 'event';

    return InkWell(
      onTap: () {
        if (isGroup) {
          Navigator.pushNamed(context, AppRoutes.chatDetail);
        } else {
          Navigator.pushNamed(context, AppRoutes.chatDetail);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // ── Avatar with online indicator ──
            Stack(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: feastLightGreen.withAlpha(128),
                  child: Icon(
                    isGroup ? Icons.group : Icons.person,
                    size: 28,
                    color: feastGreen,
                  ),
                ),
                if (chat['isOnline'] == true)
                  Positioned(
                    bottom: 1,
                    right: 1,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: feastGreen,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.5),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),

            // ── Name + last message ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chat['name'] as String,
                    style: TextStyle(
                      fontWeight: (chat['unread'] as int) > 0
                          ? FontWeight.bold
                          : FontWeight.w600,
                      fontSize: 15,
                      fontFamily: 'Outfit',
                      color: feastBlack,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    chat['message'] as String,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'Outfit',
                      color: feastGray.withAlpha(180),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // ── Time + unread badge ──
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  chat['time'] as String,
                  style: TextStyle(
                    fontSize: 11,
                    fontFamily: 'Outfit',
                    color: feastGray.withAlpha(150),
                  ),
                ),
                const SizedBox(height: 6),
                if ((chat['unread'] as int) > 0)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: feastGreen,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${chat['unread']}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Outfit',
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
