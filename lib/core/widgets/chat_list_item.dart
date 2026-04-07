import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// ChatListItem
// ---------------------------------------------------------------------------
// A reusable list tile for the Messages screen, showing one chat thread.
//
// FIREBASE INTEGRATION:
//   Collection : `chats`  (or `conversations`)
//   Document fields expected:
//     - id              : String  (document ID)
//     - participantIds  : List<String>  (user UIDs)
//     - isGroup         : bool
//     - groupName       : String?  (for group chats / Food Bank groups)
//     - groupType       : String?  ('event' | 'personal' | 'my_group')
//     - lastMessage     : String
//     - lastMessageTime : Timestamp
//     - unreadCount     : int  (per-user subcollection or map field)
//     - avatarUrl       : String?  (Storage URL; use first participant's photo for 1:1)
//     - isOnline        : bool  (use Realtime Database presence for live status)
//
//   To wire up:
//     1. Create a `ChatThread` model from DocumentSnapshot.
//     2. Use StreamBuilder on `chats` filtered by current user UID.
//     3. For unread badges, store per-user unread counts in a map field
//        or a subcollection `chats/{id}/unread/{uid}`.
//     4. Online status: use Firebase Realtime Database `status/{uid}/online`.
// ---------------------------------------------------------------------------

class ChatListItem extends StatelessWidget {
  final String id;
  final String displayName;
  final String lastMessage;
  final String timeAgo;      // e.g. "5 min", "30 min", "Yesterday"
  final int unreadCount;
  final bool isOnline;
  final String? avatarUrl;
  final VoidCallback? onTap;

  const ChatListItem({
    super.key,
    this.id = 'placeholder_id',
    this.displayName = 'User Name',
    this.lastMessage = 'Last message preview...',
    this.timeAgo = '5 min',
    this.unreadCount = 0,
    this.isOnline = false,
    this.avatarUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            // ── Avatar with online indicator ───────────────────────────────
            Stack(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundImage:
                      avatarUrl != null ? NetworkImage(avatarUrl!) : null,
                  // TODO: replace with CachedNetworkImage when Firebase connected
                  child: avatarUrl == null
                      ? const Icon(Icons.person, size: 28)
                      : null,
                ),
                if (isOnline)
                  Positioned(
                    bottom: 1,
                    right: 1,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),

            // ── Name + last message ────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 13, color: Colors.black54),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // ── Time + unread badge ────────────────────────────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(timeAgo,
                    style: const TextStyle(
                        fontSize: 11, color: Colors.black45)),
                const SizedBox(height: 4),
                if (unreadCount > 0)
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$unreadCount',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold),
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

// ---------------------------------------------------------------------------
// ChatListView
// ---------------------------------------------------------------------------
// Combines a tab filter (All / Personal / Events / My Groups) and
// the scrollable list of ChatListItems.
//
// FIREBASE INTEGRATION:
//   Filter queries by `groupType` field in Firestore depending on tab:
//     'all'       → no filter
//     'personal'  → where('isGroup', isEqualTo: false)
//     'event'     → where('groupType', isEqualTo: 'event')
//     'my_group'  → where('groupType', isEqualTo: 'my_group')
//               AND where('participantIds', arrayContains: currentUserUid)
// ---------------------------------------------------------------------------

class ChatListView extends StatefulWidget {
  final List<ChatListItem> allItems;

  const ChatListView({super.key, required this.allItems});

  factory ChatListView.placeholder() {
    return ChatListView(
      allItems: [
        const ChatListItem(
            id: '1',
            displayName: 'Darlene Lopez',
            lastMessage: 'Pls take a look at the donations.',
            timeAgo: '5 min',
            unreadCount: 5,
            isOnline: true),
        const ChatListItem(
            id: '2',
            displayName: 'T.S. Cruz Food Bank',
            lastMessage: 'Hello guys, we have discussed about ...',
            timeAgo: '30 min',
            isOnline: true),
        const ChatListItem(
            id: '3',
            displayName: 'Lee Fernandez',
            lastMessage: "Yes, that's gonna help them out, hopefully.",
            timeAgo: '1 hr'),
        const ChatListItem(
            id: '4',
            displayName: 'Ronald Mendoza',
            lastMessage: 'Thank you po! 😊',
            timeAgo: 'Yesterday'),
        const ChatListItem(
            id: '5',
            displayName: 'Albert Flores',
            lastMessage: "I'm happy this event has such grea...",
            timeAgo: 'Yesterday'),
      ],
    );
  }

  @override
  State<ChatListView> createState() => _ChatListViewState();
}

class _ChatListViewState extends State<ChatListView> {
  // Tab labels – map these to Firestore query filters when wiring Firebase
  final _tabs = const ['All Chats', 'Personal Chats', 'Events', 'My Groups'];
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Tab bar ───────────────────────────────────────────────────────
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: List.generate(_tabs.length, (i) {
              final selected = i == _selectedTab;
              return GestureDetector(
                onTap: () => setState(() => _selectedTab = i),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: selected ? Colors.green : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: selected ? Colors.green : Colors.grey.shade300),
                  ),
                  child: Text(
                    _tabs[i],
                    style: TextStyle(
                      color: selected ? Colors.white : Colors.black87,
                      fontWeight: selected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),

        // ── Chat list ─────────────────────────────────────────────────────
        // TODO: when Firebase is connected, replace widget.allItems with
        //       a filtered stream based on _selectedTab value.
        Expanded(
          child: ListView.separated(
            itemCount: widget.allItems.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, indent: 70),
            itemBuilder: (_, i) => widget.allItems[i],
          ),
        ),
      ],
    );
  }
}