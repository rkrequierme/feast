// lib/features/notifications/screens/notifications_screen.dart
//
// Real-time notifications pulled from Firestore.
// Three tabs: All | User (social) | System (approvals/rejections).
// Announcements pinned at the top of every tab.
// Swipe-to-delete with confirmation; marks items read on open.

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:feast/core/core.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _markAllRead();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Batch-mark all unread notifications as read when screen opens.
  Future<void> _markAllRead() async {
    await FirestoreService.instance.markAllNotificationsRead();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FeastAppBar(title: 'Notifications'),
      drawer: const FeastDrawer(username: ''),
      body: FeastBackground(
        child: Column(
          children: [
            // Tabs
            TabBar(
              controller: _tabController,
              labelColor: feastGreen,
              unselectedLabelColor: feastGray,
              indicatorColor: feastGreen,
              labelStyle: const TextStyle(
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.bold,
                  fontSize: 13),
              tabs: const [
                Tab(text: 'All'),
                Tab(text: 'Users'),
                Tab(text: 'System'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _NotifList(typeFilter: null),
                  _NotifList(typeFilter: 'user'),
                  _NotifList(typeFilter: 'system'),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const FeastBottomNav(currentIndex: -1),
    );
  }
}

// ─── Notification List for each tab ──────────────────────────────────────────

class _NotifList extends StatelessWidget {
  final String? typeFilter; // null = all, 'user', 'system'

  const _NotifList({required this.typeFilter});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirestoreService.instance.notificationsStream(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: feastGreen));
        }

        var docs = snap.data?.docs ?? [];

        // Filter by tab type
        if (typeFilter != null) {
          docs = docs
              .where((d) =>
                  (d.data() as Map<String, dynamic>)['type'] == typeFilter)
              .toList();
        }

        // Separate announcements (type == 'announcement') pinned at top
        final announcements = docs
            .where((d) =>
                (d.data() as Map<String, dynamic>)['type'] == 'announcement')
            .toList();
        final rest = docs
            .where((d) =>
                (d.data() as Map<String, dynamic>)['type'] != 'announcement')
            .toList();

        if (docs.isEmpty) {
          return const EmptyStateWidget(message: 'No notifications yet.');
        }

        return ListView(
          padding: const EdgeInsets.only(bottom: 40),
          children: [
            // Pinned announcements section
            if (announcements.isNotEmpty) ...[
              _sectionHeader('Official Announcements'),
              ...announcements
                  .map((doc) => _NotifTile(doc: doc))
                  .toList(),
            ],

            // Rest of notifications
            if (rest.isNotEmpty) ...[
              _sectionHeader(
                  typeFilter == 'user'
                      ? 'User Notifications'
                      : typeFilter == 'system'
                          ? 'System Notifications'
                          : 'All Notifications'),
              ...rest.map((doc) => _NotifTile(doc: doc)).toList(),
            ],
          ],
        );
      },
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Outfit',
          fontWeight: FontWeight.bold,
          fontSize: 13,
          color: feastGray,
        ),
      ),
    );
  }
}

// ─── Individual Notification Tile ─────────────────────────────────────────────

class _NotifTile extends StatelessWidget {
  final QueryDocumentSnapshot doc;

  const _NotifTile({required this.doc});

  Color _statusColor(String status) {
    switch (status) {
      case 'approved':
        return feastSuccess;
      case 'pending':
        return feastOrange;
      case 'rejected':
      case 'denied':
      case 'warning':
      case 'banned':
        return feastError;
      default:
        return feastBlue;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'approved':
        return Icons.check_circle_outline;
      case 'pending':
        return Icons.hourglass_top_outlined;
      case 'rejected':
      case 'denied':
        return Icons.cancel_outlined;
      case 'warning':
        return Icons.warning_amber_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  String _formatTime(Timestamp? ts) {
    if (ts == null) return '';
    final diff = DateTime.now().difference(ts.toDate());
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inDays < 1) return '${diff.inHours}h';
    return DateFormat('MMM d').format(ts.toDate());
  }

  @override
  Widget build(BuildContext context) {
    final data = doc.data() as Map<String, dynamic>;
    final title = data['title'] as String? ?? '';
    final body = data['body'] as String? ?? '';
    final status = data['status'] as String? ?? 'info';
    final isRead = data['read'] as bool? ?? false;
    final createdAt = data['createdAt'] as Timestamp?;

    return Dismissible(
      key: Key(doc.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: feastError,
        child: const Icon(Icons.delete_outline,
            color: Colors.white, size: 28),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Delete Notification',
                style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold)),
            content: const Text(
                'Are you sure you want to delete this notification? This action cannot be undone.'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: feastError),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) async {
        await FirestoreService.instance.deleteNotification(doc.id);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: isRead ? Colors.white : feastLighterBlue.withAlpha(60),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(12),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          leading: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _statusColor(status).withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _statusIcon(status),
              color: _statusColor(status),
              size: 22,
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontWeight:
                        isRead ? FontWeight.w500 : FontWeight.bold,
                    fontSize: 13,
                    color: feastBlack,
                  ),
                ),
              ),
              Text(
                _formatTime(createdAt),
                style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 10,
                    color: feastGray),
              ),
              if (!isRead) ...[
                const SizedBox(width: 6),
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                      color: feastBlue, shape: BoxShape.circle),
                ),
              ],
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              body,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 12,
                  color: feastGray,
                  height: 1.4),
            ),
          ),
        ),
      ),
    );
  }
}

// ■■ REACT.JS INTEGRATION NOTE ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
// Collection : users/{uid}/notifications
// Fields    : title, body, type ('system'|'user'|'announcement'),
//             status ('approved'|'pending'|'rejected'|'warning'|'info'),
//             read, createdAt
// React     : onSnapshot(collection(db,'users',uid,'notifications'),
//               orderBy('createdAt','desc'))
// Mark read : updateDoc(doc.ref, { read: true })
// Delete    : deleteDoc(doc.ref)
// Admin     : addDoc to target user's notifications sub-collection
//             to trigger a notification from admin actions.
// ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
