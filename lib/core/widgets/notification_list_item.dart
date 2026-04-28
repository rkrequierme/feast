import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// notification_list_item.dart
//
// Reusable notification tile with:
//  • Swipe-to-delete (with confirmation)
//  • Tap to open full-message dialog
//  • Unread dot + light background
//  • Status icon (approved / pending / denied / info)
//
// FIREBASE WIRING (caller-side):
//   StreamBuilder<QuerySnapshot>(
//     stream: db.collection('users').doc(uid).collection('notifications')
//              .orderBy('createdAt', desc: true).snapshots(),
//     builder: (ctx, snap) {
//       return ListView.builder(
//         itemCount: snap.data!.docs.length,
//         itemBuilder: (_, i) {
//           final d = snap.data!.docs[i];
//           return NotificationListItem.fromMap(
//             d.id, d.data() as Map<String, dynamic>,
//             onDelete: () => d.reference.delete(),
//             onMarkRead: () => d.reference.update({'isRead': true}),
//           );
//         },
//       );
//     },
//   );
// ─────────────────────────────────────────────────────────────────────────────

enum NotificationStatus { accepted, pending, denied, info }

class NotificationListItem extends StatelessWidget {
  final String id;
  final String title;
  final String body;
  final String timeAgo;
  final NotificationStatus status;
  final bool isRead;
  final String? senderAvatarUrl;

  /// Called after the user confirms deletion. Caller handles Firestore delete.
  final VoidCallback? onDelete;

  /// Called when the user taps the notification (mark as read).
  final VoidCallback? onMarkRead;

  const NotificationListItem({
    super.key,
    required this.id,
    required this.title,
    required this.body,
    required this.timeAgo,
    this.status = NotificationStatus.info,
    this.isRead = false,
    this.senderAvatarUrl,
    this.onDelete,
    this.onMarkRead,
  });

  /// Build from a Firestore document map.
  factory NotificationListItem.fromMap(
    String docId,
    Map<String, dynamic> data, {
    VoidCallback? onDelete,
    VoidCallback? onMarkRead,
  }) {
    NotificationStatus status;
    switch (data['status'] as String? ?? 'info') {
      case 'accepted':
      case 'approved':
        status = NotificationStatus.accepted;
        break;
      case 'pending':
        status = NotificationStatus.pending;
        break;
      case 'denied':
      case 'rejected':
        status = NotificationStatus.denied;
        break;
      default:
        status = NotificationStatus.info;
    }
    return NotificationListItem(
      id: docId,
      title: data['title'] as String? ?? '',
      body: data['body'] as String? ?? '',
      timeAgo: _relativeTime(data['createdAt']),
      status: status,
      isRead: data['isRead'] as bool? ?? false,
      senderAvatarUrl: data['senderAvatarUrl'] as String?,
      onDelete: onDelete,
      onMarkRead: onMarkRead,
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  static String _relativeTime(dynamic ts) {
    if (ts == null) return '';
    try {
      final dt = (ts as dynamic).toDate() as DateTime;
      final diff = DateTime.now().difference(dt);
      if (diff.inSeconds < 60) return '${diff.inSeconds}s';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m';
      if (diff.inHours < 24) return '${diff.inHours}h';
      return '${diff.inDays}d';
    } catch (_) {
      return '';
    }
  }

  Color get _statusColor {
    switch (status) {
      case NotificationStatus.accepted:
        return feastSuccess;
      case NotificationStatus.pending:
        return feastPending;
      case NotificationStatus.denied:
        return feastError;
      case NotificationStatus.info:
        return feastBlue;
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

  // ── Full-message dialog ───────────────────────────────────────────────────

  void _showFullMessage(BuildContext context) {
    onMarkRead?.call();
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _statusColor.withAlpha(38),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(_statusIcon, color: _statusColor, size: 22),
                  ),
                  const SizedBox(width: 10),
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
                  GestureDetector(
                    onTap: () => Navigator.of(ctx).pop(),
                    child:
                        const Icon(Icons.close, size: 20, color: Colors.black45),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(height: 1),
              const SizedBox(height: 14),

              // Body
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

              // Close button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Close',
                    style: TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w700,
                        fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        color: feastError,
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
      child: InkWell(
        onTap: () => _showFullMessage(context),
        child: Container(
          color: isRead ? Colors.transparent : feastGreen.withAlpha(15),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Unread dot
              Container(
                margin: const EdgeInsets.only(top: 6, right: 8),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isRead ? Colors.transparent : feastBlue,
                ),
              ),

              // Avatar or status icon
              senderAvatarUrl != null
                  ? CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(senderAvatarUrl!),
                    )
                  : Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _statusColor.withAlpha(38),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(_statusIcon, color: _statusColor, size: 22),
                    ),
              const SizedBox(width: 10),

              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight:
                            isRead ? FontWeight.normal : FontWeight.bold,
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

              // Time
              Text(
                timeAgo,
                style:
                    const TextStyle(fontSize: 11, color: Colors.black38),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Delete confirm dialog ─────────────────────────────────────────────────────

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
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: onCancel,
                child: const Icon(Icons.close, size: 20, color: Colors.black45),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.delete_outline,
                  color: Colors.red.shade400, size: 26),
            ),
            const SizedBox(height: 12),
            const Text(
              'Delete Notification',
              style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
            const SizedBox(height: 6),
            const Text(
              'Are you sure you want to delete this notification?\nThis action cannot be undone.',
              style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 13,
                  color: Colors.black54),
            ),
            const SizedBox(height: 20),
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
                child: const Text('Delete',
                    style: TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
              ),
            ),
            const SizedBox(height: 8),
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
                child: const Text('Cancel',
                    style: TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NotificationsListView
// Tab-filtered (All / Users / System) list with section grouping.
// ─────────────────────────────────────────────────────────────────────────────

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

  @override
  State<NotificationsListView> createState() =>
      _NotificationsListViewState();
}

class _NotificationsListViewState extends State<NotificationsListView> {
  int _tab = 0; // 0=All, 1=Users, 2=System

  List<Widget> _section(String header, List<NotificationListItem> items) {
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
    final tabs = ['All', 'Users', 'System'];

    final showSystem = _tab == 0 || _tab == 2;
    final showUsers  = _tab == 0 || _tab == 1;

    final rows = <Widget>[
      ..._section('Official Announcements', widget.announcements),
      if (showSystem)
        ..._section('System Notifications', widget.systemNotifications),
      if (showUsers)
        ..._section('User Notifications', widget.userNotifications),
    ];

    return Column(
      children: [
        // Tab bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: List.generate(tabs.length, (i) {
              final sel = i == _tab;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _tab = i),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: sel ? feastGreen : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: sel ? feastGreen : Colors.grey.shade300,
                      ),
                    ),
                    child: Text(
                      tabs[i],
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
          child: rows.isEmpty
              ? const Center(
                  child: Text(
                    'No notifications.',
                    style: TextStyle(
                        fontFamily: 'Nunito', color: Colors.black45),
                  ),
                )
              : ListView(children: rows),
        ),
      ],
    );
  }
}
