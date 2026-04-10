import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// NotificationListItem
// ---------------------------------------------------------------------------
// A reusable tile for the Notifications screen.
//
// CHANGES:
//   - Removed `showDeleteButton` in favor of universal swipe-to-delete
//     (Dismissible). Every notification can be dismissed by swiping left.
//   - `onTap` now opens a full-message modal via `_showFullMessageDialog`.
//     The parent screen no longer needs to supply a custom onTap handler.
//
// FIREBASE INTEGRATION:
//   Collection : `notifications`  (subcollection per user: `users/{uid}/notifications`)
//   Document fields expected:
//     - id          : String
//     - type        : String  ('system' | 'user' | 'announcement')
//     - status      : String  ('accepted' | 'pending' | 'denied' | 'info')
//     - title       : String  (e.g. "System: Aid Request Accepted")
//     - body        : String  (e.g. '"Surgery Bills" has been accepted...')
//     - timeAgo     : String  (e.g. "5m", "30m") — or store Timestamp & format client-side
//     - isRead      : bool
//     - senderName  : String?   (for user notifications)
//     - senderAvatarUrl : String? (Storage URL)
//
//   To wire up:
//     1. Create a `AppNotification` model from DocumentSnapshot.
//     2. Use StreamBuilder on `users/{uid}/notifications` ordered by timestamp desc.
//     3. Mark isRead = true when the user views/taps a notification.
//     4. For delete: call doc.reference.delete() inside onDelete callback.
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

  /// Called after the user confirms deletion (swipe-to-dismiss confirmed).
  /// Wire this to Firestore delete in the parent screen.
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
    this.onDelete,
  });

  // ── Helpers ────────────────────────────────────────────────────────────────

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

  /// Opens a dialog showing the full, untruncated notification message.
  void _showFullMessageDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ─────────────────────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _statusColor.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(_statusIcon, color: _statusColor, size: 22),
                  ),
                  const SizedBox(width: 10),
                  // Title + time
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          timeAgo,
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 12,
                            color: Colors.black38,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Close button
                  GestureDetector(
                    onTap: () => Navigator.of(ctx).pop(),
                    child: const Icon(Icons.close, size: 20, color: Colors.black45),
                  ),
                ],
              ),

              const SizedBox(height: 14),
              const Divider(height: 1),
              const SizedBox(height: 14),

              // ── Full body ──────────────────────────────────────────────
              Text(
                body,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 20),

              // ── Dismiss button ─────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Close',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(id),
      direction: DismissDirection.endToStart,
      // ── Red delete background revealed on swipe ─────────────────────────
      background: Container(
        alignment: Alignment.centerRight,
        color: Colors.red,
        padding: const EdgeInsets.only(right: 20),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline, color: Colors.white, size: 26),
            SizedBox(height: 4),
            Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
      // ── Confirm before fully dismissing ────────────────────────────────
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => _DeleteConfirmDialog(
            onConfirm: () => Navigator.pop(ctx, true),
            onCancel: () => Navigator.pop(ctx, false),
          ),
        );
      },
      onDismissed: (_) => onDelete?.call(),
      // ── Tile ────────────────────────────────────────────────────────────
      child: InkWell(
        onTap: () => _showFullMessageDialog(context),
        child: Container(
          color: isRead ? Colors.transparent : Colors.green.withOpacity(0.06),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Unread dot ───────────────────────────────────────────────
              Container(
                margin: const EdgeInsets.only(top: 6, right: 8),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isRead ? Colors.transparent : Colors.blue,
                ),
              ),

              // ── Status icon or sender avatar ─────────────────────────────
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

              // ── Text ─────────────────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                        fontSize: 13,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // ── Time ─────────────────────────────────────────────────────
              Text(
                timeAgo,
                style: const TextStyle(fontSize: 11, color: Colors.black38),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _DeleteConfirmDialog  (private — only used within this file)
// ---------------------------------------------------------------------------
class _DeleteConfirmDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const _DeleteConfirmDialog({
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.delete_outline,
                      color: Colors.red, size: 22),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: onCancel,
                  child:
                      const Icon(Icons.close, color: Colors.black45, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Text(
              'Delete Notification',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Are you sure you want to delete this notification?\nThis action cannot be undone.',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 13,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 20),

            // Delete button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onConfirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  elevation: 0,
                ),
                child: const Text(
                  'Delete',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Cancel button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onCancel,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  elevation: 0,
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
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
          body: 'Barangay Almarza Dos has decided to implement new guidelines '
              'effective immediately. Please review the updated community '
              'policies in the announcements section.',
          timeAgo: '2m',
          status: NotificationStatus.info,
        ),
      ],
      systemNotifications: [
        const NotificationListItem(
          id: 's1',
          title: 'System: Aid Request Accepted',
          body: '"Surgery Bills" has been accepted and is now listed on the '
              'community aid board. Donors can now view and contribute to '
              'your request.',
          timeAgo: '5m',
          status: NotificationStatus.accepted,
        ),
        const NotificationListItem(
          id: 's2',
          title: 'System: Awaiting Edit Approval',
          body: 'Your recent edits to "Surgery Bills" are pending admin '
              'approval. You will be notified once a decision has been made.',
          timeAgo: '8m',
          status: NotificationStatus.pending,
        ),
        const NotificationListItem(
          id: 's3',
          title: 'System: Edits Denied',
          body: 'Your requested edits to "T.S. Cruz Food Bank" have been '
              'denied. Please contact the admin team for further clarification.',
          timeAgo: '44m',
          status: NotificationStatus.denied,
        ),
      ],
      userNotifications: [
        const NotificationListItem(
          id: 'u1',
          title: 'David Garcia',
          body: 'Commented on your "Almarza Dos Food Bank" campaign: '
              '"This is a great initiative, happy to help in any way I can!"',
          timeAgo: '5m',
          status: NotificationStatus.info,
        ),
        const NotificationListItem(
          id: 'u2',
          title: 'Theresa Reyes',
          body: 'Donated ₱100 to your "Surgery Bills" aid request. '
              'Thank them by sending a message through the platform.',
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
        child: Text(
          header,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: Colors.black54,
          ),
        ),
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
                        color: sel ? Colors.green : Colors.grey.shade300,
                      ),
                    ),
                    child: Text(
                      _tabs[i],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Nunito',
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