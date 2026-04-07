import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// HistoryLogListItem
// ---------------------------------------------------------------------------
// A reusable tile for the "Your History" / Activity Log screen.
//
// FIREBASE INTEGRATION:
//   Subcollection : `users/{uid}/activity_logs`
//   Document fields expected:
//     - id          : String  (document ID)
//     - actionType  : String  (e.g. "Post Handling", "User Authentication",
//                              "Credential Changes")
//     - description : String  (e.g. "Remove Charity Event.")
//     - timestamp   : Timestamp
//     - status      : String  ('Rejected' | 'Pending' | 'Approved' |
//                              'Success' | 'In Progress')
//
//   To wire up:
//     1. Create an `ActivityLog` model from DocumentSnapshot.
//     2. Use StreamBuilder on `users/{uid}/activity_logs`
//        ordered by `timestamp` descending.
//     3. Separate into "Recent" (last 30 days) and "Past" sections.
//     4. Cloud Function or client-side write to append a log entry whenever
//        a significant user action occurs (create/edit/remove request, event,
//        login, password change, etc.).
//
//   DATABASE STRUCTURE NEEDED:
//     users/{uid}/activity_logs/{logId}
//       - actionType  : String
//       - description : String
//       - timestamp   : Timestamp
//       - status      : String
// ---------------------------------------------------------------------------

enum LogStatus { approved, pending, rejected, success, inProgress }

class HistoryLogListItem extends StatelessWidget {
  final String id;
  final String actionType;
  final String description;
  final String formattedDate; // e.g. "03-08-2026 | 12:00 PM"
  final LogStatus status;

  const HistoryLogListItem({
    super.key,
    this.id = 'placeholder_id',
    this.actionType = 'Post Handling',
    this.description = 'Performed an action.',
    this.formattedDate = '03-08-2026 | 12:00 PM',
    this.status = LogStatus.success,
  });

  String get _statusLabel {
    switch (status) {
      case LogStatus.approved:
        return 'Approved';
      case LogStatus.pending:
        return 'Pending';
      case LogStatus.rejected:
        return 'Rejected';
      case LogStatus.success:
        return 'Success';
      case LogStatus.inProgress:
        return 'In Progress';
    }
  }

  Color get _statusColor {
    switch (status) {
      case LogStatus.approved:
        return Colors.green;
      case LogStatus.pending:
        return Colors.orange;
      case LogStatus.rejected:
        return Colors.red;
      case LogStatus.success:
        return Colors.green;
      case LogStatus.inProgress:
        return Colors.blue;
    }
  }

  IconData get _actionIcon {
    switch (actionType) {
      case 'User Authentication':
        return Icons.login;
      case 'Credential Changes':
        return Icons.lock_reset;
      default:
        return Icons.edit_note;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 3)],
      ),
      child: Row(
        children: [
          // ── Action icon ────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(_actionIcon, size: 20, color: Colors.black54),
          ),
          const SizedBox(width: 12),

          // ── Text ──────────────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(actionType,
                    style: const TextStyle(
                        fontSize: 11, color: Colors.black45)),
                const SizedBox(height: 2),
                Text(description,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 2),
                Text(formattedDate,
                    style: const TextStyle(
                        fontSize: 11, color: Colors.black45)),
              ],
            ),
          ),

          // ── Status chip ────────────────────────────────────────────────
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _statusColor.withOpacity(0.4)),
            ),
            child: Text(
              _statusLabel,
              style: TextStyle(
                  color: _statusColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// HistoryListView
// ---------------------------------------------------------------------------
// Groups log items into "Recent Activity Logs" and "Past Activity Logs"
// sections, with a sort dialog trigger.
//
// FIREBASE INTEGRATION:
//   - Fetch `users/{uid}/activity_logs` ordered by `timestamp` desc.
//   - "Recent" = logs within the last 30 days.
//   - "Past"   = older logs.
//   - Sort dialog options: Newest / Oldest / In Progress / Log Type →
//     re-query Firestore with appropriate orderBy / where clauses.
// ---------------------------------------------------------------------------

class HistoryListView extends StatelessWidget {
  final List<HistoryLogListItem> recentItems;
  final List<HistoryLogListItem> pastItems;
  final VoidCallback? onSortTap;

  const HistoryListView({
    super.key,
    required this.recentItems,
    required this.pastItems,
    this.onSortTap,
  });

  factory HistoryListView.placeholder() {
    return HistoryListView(
      recentItems: const [
        HistoryLogListItem(
          id: 'r1',
          actionType: 'Post Handling',
          description: 'Remove Charity Event.',
          formattedDate: '03-08-2026 | 3:00 PM',
          status: LogStatus.rejected,
        ),
        HistoryLogListItem(
          id: 'r2',
          actionType: 'Post Handling',
          description: 'Edit Event Details.',
          formattedDate: '03-08-2026 | 11:30 AM',
          status: LogStatus.pending,
        ),
        HistoryLogListItem(
          id: 'r3',
          actionType: 'Post Handling',
          description: 'Create Charity Event.',
          formattedDate: '03-08-2026 | 9:00 AM',
          status: LogStatus.approved,
        ),
        HistoryLogListItem(
          id: 'r4',
          actionType: 'User Authentication',
          description: 'You Logged In.',
          formattedDate: '03-08-2026 | 5:00 AM',
          status: LogStatus.success,
        ),
        HistoryLogListItem(
          id: 'r5',
          actionType: 'Credential Changes',
          description: 'Set New Password.',
          formattedDate: '03-08-2026 | 5:05 AM',
          status: LogStatus.success,
        ),
      ],
      pastItems: const [
        HistoryLogListItem(
          id: 'p1',
          actionType: 'User Authentication',
          description: 'You Logged Out.',
          formattedDate: '01-01-2026 | 2:00 PM',
          status: LogStatus.success,
        ),
        HistoryLogListItem(
          id: 'p2',
          actionType: 'Post Handling',
          description: 'Remove Aid Request.',
          formattedDate: '01-01-2026 | 12:00 PM',
          status: LogStatus.approved,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.only(bottom: 80),
          children: [
            if (recentItems.isNotEmpty) ...[
              _SectionHeader(title: 'Recent Activity Logs'),
              ...recentItems,
            ],
            if (pastItems.isNotEmpty) ...[
              _SectionHeader(title: 'Past Activity Logs'),
              ...pastItems,
            ],
          ],
        ),

        // ── Floating sort button ───────────────────────────────────────────
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onTap: onSortTap,
            // TODO: Show sort bottom sheet with options:
            //   Newest / Oldest / In Progress / Log Type
            //   Then re-query Firestore accordingly.
            backgroundColor: Colors.green,
            child: const Icon(Icons.sort, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

// Tiny workaround: FloatingActionButton doesn't have onTap; use GestureDetector
class FloatingActionButton extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final VoidCallback? onTap;

  const FloatingActionButton(
      {super.key,
      required this.child,
      required this.backgroundColor,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
            color: backgroundColor, shape: BoxShape.circle),
        child: child,
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: Text(title,
          style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.black87)),
    );
  }
}