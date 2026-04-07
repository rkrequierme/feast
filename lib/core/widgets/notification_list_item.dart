import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// NotificationListItem
// ---------------------------------------------------------------------------
// A reusable tile for the Notifications screen.
//
// FIREBASE INTEGRATION:
//   Collection : `notifications`  (subcollection per user: `users/{uid}/notifications`)
//   Document fields expected:
//     - id          : String
//     - type        : String  ('system' | 'user' | 'announcement')
//     - status      : String  ('accepted' | 'pending' | 'denied' | 'info')
//     - title       : String  (e.g. "System: Aid Request Accepted")
//     - body        : String  (e.g. '"Surgery Bills" has been accepted...')
//     - timeAgo     : String  (e.g. "5m", "30m")  — or store Timestamp & format client-side
//     - isRead      : bool
//     - senderName  : String?   (for user notifications)
//     - senderAvatarUrl : String? (Storage URL)
//
//   To wire up:
//     1. Create a `AppNotification` model from DocumentSnapshot.
//     2. Use StreamBuilder on `users/{uid}/notifications` ordered by timestamp desc.
//     3. Mark isRead = true when the user views/taps a notification
//        (batch write or Cloud Function trigger).
//     4. For delete: call doc.reference.delete().
//
//   DATABASE STRUCTURE NEEDED:
//     users/{uid}/notifications/{notifId}  ← per-user notification inbox
//     (Optionally) global `announcements` collection for Official Announcements.
// ---------------------------------------------------------------------------

enum NotificationStatus { accepted, pending, denied, info }

class NotificationListItem extends StatelessWidget {
  final String id;
  final String title;
  final String body;
  final String timeAgo;
  final NotificationStatus status;
  final bool isRead;
  final String? senderAvatarUrl;
  final bool showDeleteButton;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const NotificationListItem({
    super.key,
    this.id = 'placeholder_id',
    this.title = 'Notification Title',
    this.body = 'Notification body preview text.',
    this.timeAgo = '5m',
    this.status = NotificationStatus.info,
    this.isRead = false,
    this.senderAvatarUrl,
    this.showDeleteButton = false,
    this.onTap,
    this.onDelete,
  });

  Color get _statusColor {
    switch (status) {
      case NotificationStatus.accepted:
        return Colors.green;
      case NotificationStatus.pending:
        return Colors.orange;
      case NotificationStatus.denied:
        return Colors.red;
      case NotificationStatus.info:
        return Colors.blueGrey;
    }
  }

  IconData get _statusIcon {
    switch (status) {
      case NotificationStatus.accepted:
        return Icons.check_circle;
      case NotificationStatus.pending:
        return Icons.access_time;
      case NotificationStatus.denied:
        return Icons.warning_rounded;
      case NotificationStatus.info:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: isRead ? Colors.transparent : Colors.green.withOpacity(0.06),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Unread dot ─────────────────────────────────────────────────
            Container(
              margin: const EdgeInsets.only(top: 6, right: 8),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isRead ? Colors.transparent : Colors.blue,
              ),
            ),

            // ── Status icon or sender avatar ───────────────────────────────
            senderAvatarUrl != null
                ? CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(senderAvatarUrl!),
                    // TODO: replace with CachedNetworkImage
                  )
                : Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _statusColor.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(_statusIcon, color: _statusColor, size: 22),
                  ),

            const SizedBox(width: 10),

            // ── Text ───────────────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontWeight:
                              isRead ? FontWeight.normal : FontWeight.bold,
                          fontSize: 13)),
                  const SizedBox(height: 3),
                  Text(
                    body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // ── Time + optional delete ─────────────────────────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(timeAgo,
                    style: const TextStyle(
                        fontSize: 11, color: Colors.black38)),
                if (showDeleteButton)
                  GestureDetector(
                    onTap: onDelete,
                    child: Container(
                      margin: const EdgeInsets.only(top: 6),
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6)),
                      child: const Icon(Icons.delete,
                          color: Colors.white, size: 16),
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
// NotificationsListView
// ---------------------------------------------------------------------------
// Groups notifications into sections (Official Announcements, System, User)
// and provides tab-based filtering (All / Users / System).
//
// FIREBASE INTEGRATION:
//   - Query `users/{uid}/notifications` ordered by `createdAt` descending.
//   - Filter by `type` field based on selected tab.
//   - Official Announcements: query separate `announcements` collection
//     and prepend to the list.
//   - To delete: call DocumentReference.delete() inside onDelete callback.
// ---------------------------------------------------------------------------

class NotificationsListView extends StatefulWidget {
  final List<NotificationListItem> announcements;
  final List<NotificationListItem> systemNotifications;
  final List<NotificationListItem> userNotifications;

  const NotificationsListView({
    super.key,
    required this.announcements,
    required this.systemNotifications,
    required this.userNotifications,
  });

  factory NotificationsListView.placeholder() {
    return NotificationsListView(
      announcements: [
        const NotificationListItem(
          id: 'a1',
          title: 'Updated Guidelines & Policies',
          body: 'Barangay Almarza Dos has decided to implement new...',
          timeAgo: '2m',
          status: NotificationStatus.info,
        ),
      ],
      systemNotifications: [
        const NotificationListItem(
          id: 's1',
          title: 'System: Aid Request Accepted',
          body: '"Surgery Bills" has been accepted and is now listed...',
          timeAgo: '5m',
          status: NotificationStatus.accepted,
        ),
        const NotificationListItem(
          id: 's2',
          title: 'System: Awaiting Edit Approval',
          body: 'Donated ₱100 to your "Surgery Bills" aid request.',
          timeAgo: '8m',
          status: NotificationStatus.pending,
        ),
        const NotificationListItem(
          id: 's3',
          title: 'System: Edits Denied',
          body: 'Just joined your "T.S. Cruz Food Bank."',
          timeAgo: '44m',
          status: NotificationStatus.denied,
          showDeleteButton: true,
        ),
      ],
      userNotifications: [
        const NotificationListItem(
          id: 'u1',
          title: 'David Garcia',
          body: 'Commented on your "Almarza Dos Food Bank" cam...',
          timeAgo: '5m',
          status: NotificationStatus.info,
        ),
        const NotificationListItem(
          id: 'u2',
          title: 'Theresa Reyes',
          body: 'Donated ₱100 to your "Surgery Bills" aid request.',
          timeAgo: '8m',
          status: NotificationStatus.info,
        ),
      ],
    );
  }

  @override
  State<NotificationsListView> createState() => _NotificationsListViewState();
}

class _NotificationsListViewState extends State<NotificationsListView> {
  int _selectedTab = 0; // 0=All, 1=Users, 2=System
  final _tabs = ['All', 'Users', 'System'];

  List<Widget> _buildSection(String header, List<NotificationListItem> items) {
    if (items.isEmpty) return [];
    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        child: Text(header,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black54)),
      ),
      ...items,
      const Divider(height: 1),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final showSystem = _selectedTab == 0 || _selectedTab == 2;
    final showUsers = _selectedTab == 0 || _selectedTab == 1;

    final rows = <Widget>[
      ..._buildSection('Official Announcements', widget.announcements),
      if (showSystem)
        ..._buildSection('System Notifications', widget.systemNotifications),
      if (showUsers)
        ..._buildSection('User Notifications', widget.userNotifications),
    ];

    return Column(
      children: [
        // ── Tab bar ───────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: List.generate(_tabs.length, (i) {
              final sel = i == _selectedTab;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedTab = i),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: sel ? Colors.green : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: sel ? Colors.green : Colors.grey.shade300),
                    ),
                    child: Text(
                      _tabs[i],
                      textAlign: TextAlign.center,
                      style: TextStyle(
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

        Expanded(
          child: ListView(children: rows),
        ),
      ],
    );
  }
}