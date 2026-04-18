import 'package:flutter/material.dart';
import 'package:feast/core/core.dart';

// ---------------------------------------------------------------------------
// NotificationsScreen
// ---------------------------------------------------------------------------
// Full screen that hosts the NotificationsListView widget.
//
// CHANGES:
//   - Removed `showDeleteButton` from all NotificationListItems — deletion is
//     now handled universally via swipe-to-dismiss on the component itself.
//   - Removed `onTap` callbacks — tapping a tile now opens a full-message
//     dialog handled internally by NotificationListItem.
//   - Removed the local `_DeleteConfirmDialog` — it now lives inside
//     notification_list_item.dart alongside the component that uses it.
//   - `onDelete` callbacks are kept here so the screen can update local state
//     and (eventually) call Firestore delete.
//
// FIREBASE INTEGRATION:
//   1. Replace _systemNotifications / _userNotifications init with real
//      Firestore stream subscriptions in initState.
//   2. Use three separate StreamBuilders (or one combined stream) for:
//        - announcements   → collection('announcements')
//        - systemNotifs    → collection('users/{uid}/notifications')
//                              .where('type', isEqualTo: 'system')
//        - userNotifs      → same collection, type == 'user'
//   3. Mark all as read when the screen is opened:
//        WriteBatch batch = FirebaseFirestore.instance.batch();
//        for (var doc in unreadDocs) batch.update(doc.reference, {'isRead': true});
//        await batch.commit();
//   4. The onDelete callback is already wired; add the Firestore call there:
//        await FirebaseFirestore.instance
//          .doc('users/$uid/notifications/$notifId').delete();
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
      body: 'Barangay Almarza Dos has decided to implement new guidelines '
          'effective immediately. Please review the updated community '
          'policies in the announcements section.',
      timeAgo: '2m',
      status: NotificationStatus.info,
      isRead: false,
    ),
  ];

  // Mutable so we can remove items after swipe-to-dismiss is confirmed.
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
        body: '"Surgery Bills" has been accepted and is now listed on the '
            'community aid board. Donors can now view and contribute to '
            'your request.',
        timeAgo: '5m',
        status: NotificationStatus.accepted,
        isRead: false,
        onDelete: () => _deleteNotification('s1', isSystem: true),
      ),
      NotificationListItem(
        id: 's2',
        title: 'System: Awaiting Edit Approval',
        body: 'Your recent edits to "Surgery Bills" are pending admin '
            'approval. You will be notified once a decision has been made.',
        timeAgo: '8m',
        status: NotificationStatus.pending,
        isRead: false,
        onDelete: () => _deleteNotification('s2', isSystem: true),
      ),
      NotificationListItem(
        id: 's3',
        title: 'System: Awaiting Event Approval',
        body: 'Your event submission "T.S. Cruz Food Bank Drive" is awaiting '
            'approval from the barangay admin. Check back soon for updates.',
        timeAgo: '30m',
        status: NotificationStatus.pending,
        isRead: false,
        onDelete: () => _deleteNotification('s3', isSystem: true),
      ),
      NotificationListItem(
        id: 's4',
        title: 'System: Edits Denied',
        body: 'Your requested edits to "T.S. Cruz Food Bank" have been '
            'denied by the admin team. Please contact support for further '
            'clarification.',
        timeAgo: '44m',
        status: NotificationStatus.denied,
        isRead: true,
        onDelete: () => _deleteNotification('s4', isSystem: true),
      ),
      NotificationListItem(
        id: 's5',
        title: 'System: Charity Event Denied',
        body: 'Your charity event "Almanza Dos Community Outreach" was not '
            'approved. Please review the event guidelines and resubmit.',
        timeAgo: '1h',
        status: NotificationStatus.denied,
        isRead: true,
        onDelete: () => _deleteNotification('s5', isSystem: true),
      ),
      NotificationListItem(
        id: 's6',
        title: 'System: Aid Request Denied',
        body: 'Your aid request has been reviewed and unfortunately was not '
            'approved at this time. You may re-submit with additional '
            'supporting details.',
        timeAgo: '2h',
        status: NotificationStatus.denied,
        isRead: true,
        onDelete: () => _deleteNotification('s6', isSystem: true),
      ),
    ];

    _userNotifications = [
      NotificationListItem(
        id: 'u1',
        title: 'David Garcia',
        body: 'Commented on your "Almarza Dos Food Bank" campaign: '
            '"This is a great initiative, happy to help in any way I can!"',
        timeAgo: '5m',
        status: NotificationStatus.info,
        isRead: false,
        onDelete: () => _deleteNotification('u1', isSystem: false),
      ),
      NotificationListItem(
        id: 'u2',
        title: 'Theresa Reyes',
        body: 'Donated ₱100 to your "Surgery Bills" aid request. '
            'Consider sending them a thank-you message through the platform.',
        timeAgo: '8m',
        status: NotificationStatus.info,
        isRead: false,
        onDelete: () => _deleteNotification('u2', isSystem: false),
      ),
      NotificationListItem(
        id: 'u3',
        title: 'Marvin Ramos',
        body: 'Is now helping you with your "Family Needs Furniture" aid '
            'request as a volunteer contributor.',
        timeAgo: '30m',
        status: NotificationStatus.info,
        isRead: false,
        onDelete: () => _deleteNotification('u3', isSystem: false),
      ),
      NotificationListItem(
        id: 'u4',
        title: 'Devon Mendoza',
        body: 'Just joined your "T.S. Cruz Food Bank" as a volunteer. '
            'You can coordinate with them via the Messages tab.',
        timeAgo: '44m',
        status: NotificationStatus.info,
        isRead: true,
        onDelete: () => _deleteNotification('u4', isSystem: false),
      ),
      NotificationListItem(
        id: 'u5',
        title: 'Eleanor Santos',
        body: 'Accepted your collaborator request for "Almarza Dos Community '
            'Pantry." You can now co-manage the event together.',
        timeAgo: '1h',
        status: NotificationStatus.info,
        isRead: true,
        onDelete: () => _deleteNotification('u5', isSystem: false),
      ),
      NotificationListItem(
        id: 'u6',
        title: 'Jesus Ramirez',
        body: 'Sent you a message. Tap to open the conversation in the '
            'Messages tab.',
        timeAgo: '2m',
        status: NotificationStatus.info,
        isRead: false,
        onDelete: () => _deleteNotification('u6', isSystem: false),
      ),
    ];
  }

  // ── Handlers ──────────────────────────────────────────────────────────────

  /// Removes the notification from local state after swipe-dismiss is confirmed.
  /// Called by the onDelete callback passed to each NotificationListItem.
  void _deleteNotification(String id, {required bool isSystem}) {
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

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FeastAppBar(title: 'Notifications'),
      drawer: const FeastDrawer(username: 'Juan De La Cruz'),
      body: FeastBackground(
        child: SafeArea(
          child: Column(
            children: [
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
      // ── Bottom nav bar ────────────────────────────────────────────────────
      bottomNavigationBar: const FeastBottomNav(currentIndex: -1),
    );
  }
}