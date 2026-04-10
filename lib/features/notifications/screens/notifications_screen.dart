import 'package:flutter/material.dart';

// Import the reusable list view widget generated previously.
// Adjust the path to match your project's folder structure.
import 'package:feast/core/core.dart';

// ---------------------------------------------------------------------------
// NotificationsScreen
// ---------------------------------------------------------------------------
// Full screen that hosts the NotificationsListView widget.
//
// FIREBASE INTEGRATION:
//   1. Replace _buildPlaceholderData() with real Firestore streams.
//   2. Use three separate StreamBuilders (or one combined stream) for:
//        - announcements   → collection('announcements')
//        - systemNotifs    → collection('users/{uid}/notifications')
//                              .where('type', isEqualTo: 'system')
//        - userNotifs      → same collection, type == 'user'
//   3. Mark all as read when the screen is opened:
//        WriteBatch batch = FirebaseFirestore.instance.batch();
//        for (var doc in unreadDocs) batch.update(doc.reference, {'isRead': true});
//        await batch.commit();
//   4. The delete confirmation dialog already calls `onDelete`; wire that
//        callback to: FirebaseFirestore.instance
//          .doc('users/$uid/notifications/$notifId').delete()
// ---------------------------------------------------------------------------

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // ── Placeholder data ──────────────────────────────────────────────────────
  // Replace these lists with data mapped from Firestore DocumentSnapshots.

  final List<NotificationListItem> _announcements = const [
    NotificationListItem(
      id: 'a1',
      title: 'Updated Guidelines & Policies',
      body: 'Barangay Almarza Dos has decided to implement new guidelines...',
      timeAgo: '2m',
      status: NotificationStatus.info,
      isRead: false,
    ),
  ];

  // Mutable so we can remove items when the user deletes them.
  late List<NotificationListItem> _systemNotifications;
  late List<NotificationListItem> _userNotifications;

  @override
  void initState() {
    super.initState();

    // TODO: replace with Firestore stream subscription.
    _systemNotifications = [
      NotificationListItem(
        id: 's1',
        title: 'System: Aid Request Accepted',
        body: '"Surgery Bills" has been accepted and is now listed...',
        timeAgo: '5m',
        status: NotificationStatus.accepted,
        isRead: false,
        onTap: () => _onNotifTap('s1'),
      ),
      NotificationListItem(
        id: 's2',
        title: 'System: Awaiting Edit Approval',
        body: 'Donated ₱100 to your "Surgery Bills" aid request.',
        timeAgo: '8m',
        status: NotificationStatus.pending,
        isRead: false,
        onTap: () => _onNotifTap('s2'),
      ),
      NotificationListItem(
        id: 's3',
        title: 'System: Awaiting Event Approval',
        body: 'Is helping you with your "Family Needs Furniture" aid...',
        timeAgo: '30m',
        status: NotificationStatus.pending,
        isRead: false,
        onTap: () => _onNotifTap('s3'),
      ),
      NotificationListItem(
        id: 's4',
        title: 'System: Edits Denied',
        body: 'Just joined your "T.S. Cruz Food Bank."',
        timeAgo: '44m',
        status: NotificationStatus.denied,
        isRead: true,
        showDeleteButton: true,
        onTap: () => _onNotifTap('s4'),
        onDelete: () => _confirmDelete('s4', isSystem: true),
      ),
      NotificationListItem(
        id: 's5',
        title: 'System: Charity Event Denied',
        body: 'Accepted your collaborator request for "Almarza Dos..."',
        timeAgo: '1h',
        status: NotificationStatus.denied,
        isRead: true,
        onTap: () => _onNotifTap('s5'),
      ),
      NotificationListItem(
        id: 's6',
        title: 'System: Aid Request Denied',
        body: 'Your report on David Garcia will be reviewed.',
        timeAgo: '2h',
        status: NotificationStatus.denied,
        isRead: true,
        onTap: () => _onNotifTap('s6'),
      ),
    ];

    _userNotifications = [
      NotificationListItem(
        id: 'u1',
        title: 'David Garcia',
        body: 'Commented on your "Almarza Dos Food Bank" campaign...',
        timeAgo: '5m',
        status: NotificationStatus.info,
        isRead: false,
        onTap: () => _onNotifTap('u1'),
      ),
      NotificationListItem(
        id: 'u2',
        title: 'Theresa Reyes',
        body: 'Donated ₱100 to your "Surgery Bills" aid request.',
        timeAgo: '8m',
        status: NotificationStatus.info,
        isRead: false,
        onTap: () => _onNotifTap('u2'),
      ),
      NotificationListItem(
        id: 'u3',
        title: 'Marvin Ramos',
        body: 'Is helping you with your "Family Needs Furniture" aid...',
        timeAgo: '30m',
        status: NotificationStatus.info,
        isRead: false,
        onTap: () => _onNotifTap('u3'),
      ),
      NotificationListItem(
        id: 'u4',
        title: 'Devon Mendoza',
        body: 'Just joined your "T.S. Cruz Food Bank."',
        timeAgo: '44m',
        status: NotificationStatus.info,
        isRead: true,
        showDeleteButton: true,
        onTap: () => _onNotifTap('u4'),
        onDelete: () => _confirmDelete('u4', isSystem: false),
      ),
      NotificationListItem(
        id: 'u5',
        title: 'Eleanor Santos',
        body: 'Accepted your collaborator request for "Almarza Dos..."',
        timeAgo: '1h',
        status: NotificationStatus.info,
        isRead: true,
        onTap: () => _onNotifTap('u5'),
      ),
      NotificationListItem(
        id: 'u6',
        title: 'Jesus Ramirez',
        body: 'Sent you a message.',
        timeAgo: '2m',
        status: NotificationStatus.info,
        isRead: false,
        onTap: () => _onNotifTap('u6'),
      ),
    ];
  }

  // ── Handlers ──────────────────────────────────────────────────────────────

  void _onNotifTap(String id) {
    // TODO: navigate to the relevant screen depending on notification type.
    // e.g. Navigator.pushNamed(context, '/aid-request', arguments: relatedId);
    // Also mark isRead = true in Firestore here if not done via batch on open.
    debugPrint('Tapped notification: $id');
  }

  /// Shows the delete confirmation dialog (matches the design).
  /// On confirm, removes from local state AND should delete from Firestore.
  Future<void> _confirmDelete(String id, {required bool isSystem}) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _DeleteConfirmDialog(
        onConfirm: () => Navigator.pop(ctx, true),
        onCancel: () => Navigator.pop(ctx, false),
      ),
    );

    if (confirmed == true) {
      setState(() {
        if (isSystem) {
          _systemNotifications =
              _systemNotifications.where((n) => n.id != id).toList();
        } else {
          _userNotifications =
              _userNotifications.where((n) => n.id != id).toList();
        }
      });

      // TODO: delete from Firestore:
      // await FirebaseFirestore.instance
      //     .doc('users/$currentUid/notifications/$id')
      //     .delete();
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ── Gradient background matching the app's green-to-white style ───────
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFB8E6C8), Colors.white],
            stops: [0.0, 0.35],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── AppBar ───────────────────────────────────────────────────
              _NotificationsAppBar(),
              const SizedBox(height: 4),

              // ── NotificationsListView (the reusable widget) ───────────────
              Expanded(
                child: NotificationsListView(
                  announcements: _announcements,
                  systemNotifications: _systemNotifications,
                  userNotifications: _userNotifications,
                ),
              ),
            ],
          ),
        ),
      ),

      // ── Bottom nav bar ───────────────────────────────────────────────────
      bottomNavigationBar: const FeastBottomNav(currentIndex: -1),
    );
  }
}

// ---------------------------------------------------------------------------
// _NotificationsAppBar
// ---------------------------------------------------------------------------
class _NotificationsAppBar extends StatelessWidget {
  const _NotificationsAppBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          // Hamburger menu
          IconButton(
            onPressed: () {
              // TODO: open drawer or navigate to settings
            },
            icon: const Icon(Icons.menu, color: Colors.black87),
          ),
          const Expanded(
            child: Text(
              'Notifications',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          // Profile avatar
          GestureDetector(
            onTap: () {
              // TODO: navigate to profile screen
            },
            child: const CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.black54),
              // TODO: replace child with CachedNetworkImage of current user's avatar
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _DeleteConfirmDialog
// ---------------------------------------------------------------------------
// The confirmation modal shown before permanently deleting a notification.
// Matches the design: red Delete button, black Cancel button.
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
                  child:
                      const Icon(Icons.delete_outline, color: Colors.red, size: 22),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: onCancel,
                  child: const Icon(Icons.close, color: Colors.black45, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Text(
              'Delete Notification',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 6),
            const Text(
              'Are you sure you want to delete this bookmark?\nThis action cannot be undone.',
              style: TextStyle(fontSize: 13, color: Colors.black54),
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
                ),
                child: const Text('Delete',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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
                ),
                child: const Text('Cancel',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
