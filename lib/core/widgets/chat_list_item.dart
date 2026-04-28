import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// chat_list_item.dart
//
// FIX (Image 2): MessagesScreen called ChatListItem with `data:` and `chatId:`
// parameters that didn't exist. Widget now accepts a Firestore map via
// `ChatListItem.fromMap(data, chatId, onTap)` factory AND keeps all the
// original named-field constructor for backward compatibility.
//
// Firestore document shape (collection: 'chats'):
//   participantIds : List<String>
//   isGroup        : bool
//   isEventChat    : bool
//   groupName      : String
//   groupImageUrl  : String?
//   lastMessage    : String
//   lastMessageAt  : Timestamp
//   creatorId      : String
//   adminIds       : List<String>
// ─────────────────────────────────────────────────────────────────────────────

class ChatListItem extends StatelessWidget {
  final String id;
  final String displayName;
  final String lastMessage;
  final String timeAgo;
  final int unreadCount;
  final bool isOnline;
  final String? avatarUrl;
  final VoidCallback? onTap;

  const ChatListItem({
    super.key,
    required this.id,
    required this.displayName,
    required this.lastMessage,
    this.timeAgo = '',
    this.unreadCount = 0,
    this.isOnline = false,
    this.avatarUrl,
    this.onTap,
  });

  /// Builds directly from a Firestore document map.
  /// This is what MessagesScreen uses — fixes Image 2.
  factory ChatListItem.fromMap(
    Map<String, dynamic> data,
    String chatId, {
    VoidCallback? onTap,
  }) {
    final lastAt = data['lastMessageAt'];
    String timeStr = '';
    if (lastAt != null) {
      try {
        final dt = (lastAt as dynamic).toDate() as DateTime;
        final now = DateTime.now();
        final diff = now.difference(dt);
        if (diff.inMinutes < 60) {
          timeStr = diff.inMinutes <= 0 ? 'Just now' : '${diff.inMinutes}m';
        } else if (diff.inHours < 24) {
          timeStr = '${diff.inHours}h';
        } else if (diff.inDays == 1) {
          timeStr = 'Yesterday';
        } else {
          timeStr = DateFormat('MMM d').format(dt);
        }
      } catch (_) {}
    }

    return ChatListItem(
      id: chatId,
      displayName: data['groupName'] as String? ?? 'Chat',
      lastMessage: data['lastMessage'] as String? ?? '',
      timeAgo: timeStr,
      unreadCount: 0, // per-user unread count stored separately
      avatarUrl: data['groupImageUrl'] as String?,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: feastLightGreen.withAlpha(60),
      highlightColor: feastLightGreen.withAlpha(30),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            // ── Avatar + online dot ──────────────────────────────────────
            Stack(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: feastLightGreen.withAlpha(120),
                  backgroundImage:
                      avatarUrl != null ? NetworkImage(avatarUrl!) : null,
                  child: avatarUrl == null
                      ? const Icon(Icons.person, size: 28, color: feastGreen)
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
                        color: feastSuccess,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),

            // ── Name + last message ────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: feastBlack,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 13,
                      color: feastGray.withAlpha(200),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // ── Time + unread badge ────────────────────────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  timeAgo,
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 11,
                    color: Colors.black45,
                  ),
                ),
                const SizedBox(height: 4),
                if (unreadCount > 0)
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                      color: feastGreen,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$unreadCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Outfit',
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
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
