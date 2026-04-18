import 'package:flutter/material.dart';
import 'package:feast/core/core.dart';

// ---------------------------------------------------------------------------
// HistoryScreen
// ---------------------------------------------------------------------------
// Displays the user's full activity log, split into "Recent" and "Past"
// sections. Sort order is controlled by the FAB inside HistoryListView.
//
// FIREBASE INTEGRATION:
//   1. Replace the placeholder lists in initState with real Firestore streams:
//        StreamBuilder on `users/{uid}/activity_logs`
//          .orderBy('timestamp', descending: true)
//   2. Map each DocumentSnapshot to a HistoryLogListItem, providing:
//        - sortableDate: (snapshot['timestamp'] as Timestamp).toDate()
//   3. Split into recentItems / pastItems by comparing timestamp to:
//        DateTime.now().subtract(const Duration(days: 30))
//   4. When sort mode is Firestore-backed, pass the selected _SortOption
//      back up from HistoryListView via a callback and re-query accordingly:
//        Newest      → orderBy('timestamp', descending: true)
//        Oldest      → orderBy('timestamp', descending: false)
//        In Progress → where('status', isEqualTo: 'In Progress')
//        Log Type    → orderBy('actionType').orderBy('timestamp', desc: true)
// ---------------------------------------------------------------------------

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // ── Placeholder data ──────────────────────────────────────────────────────
  // Replace with data mapped from Firestore DocumentSnapshots.

  late final List<HistoryLogListItem> _recentItems;
  late final List<HistoryLogListItem> _pastItems;

  @override
  void initState() {
    super.initState();

    // TODO: replace with Firestore stream subscription.
    _recentItems = [
      HistoryLogListItem(
        id: 'r1',
        actionType: 'Post Handling',
        description: 'Remove Charity Event.',
        formattedDate: '02-08-2026 | 3:00 PM',
        status: LogStatus.rejected,
        sortableDate: DateTime(2026, 8, 2, 15, 0),
      ),
      HistoryLogListItem(
        id: 'r2',
        actionType: 'Post Handling',
        description: 'Edit Event Details.',
        formattedDate: '02-08-2026 | 11:30 AM',
        status: LogStatus.pending,
        sortableDate: DateTime(2026, 8, 2, 11, 30),
      ),
      HistoryLogListItem(
        id: 'r3',
        actionType: 'Post Handling',
        description: 'Create Charity Event.',
        formattedDate: '02-08-2026 | 11:00 AM',
        status: LogStatus.approved,
        sortableDate: DateTime(2026, 8, 2, 11, 0),
      ),
      HistoryLogListItem(
        id: 'r4',
        actionType: 'User Authentication',
        description: 'You Logged In.',
        formattedDate: '02-08-2026 | 11:05 AM',
        status: LogStatus.success,
        sortableDate: DateTime(2026, 8, 2, 11, 5),
      ),
      HistoryLogListItem(
        id: 'r5',
        actionType: 'Credential Changes',
        description: 'Set New Password.',
        formattedDate: '02-08-2026 | 11:00 AM',
        status: LogStatus.success,
        sortableDate: DateTime(2026, 8, 2, 11, 0),
      ),
    ];

    _pastItems = [
      HistoryLogListItem(
        id: 'p1',
        actionType: 'User Authentication',
        description: 'You Logged Out.',
        formattedDate: '02-01-2026 | 1:00 PM',
        status: LogStatus.success,
        sortableDate: DateTime(2026, 1, 2, 13, 0),
      ),
      HistoryLogListItem(
        id: 'p2',
        actionType: 'Post Handling',
        description: 'Remove Aid Request.',
        formattedDate: '02-01-2026 | 12:00 PM',
        status: LogStatus.approved,
        sortableDate: DateTime(2026, 1, 2, 12, 0),
      ),
    ];
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FeastAppBar(title: 'Your History'),
      drawer: const FeastDrawer(username: 'Juan De La Cruz'),
      bottomNavigationBar: const FeastBottomNav(currentIndex: -1),
      body: FeastBackground(
        child: SafeArea(
          child: HistoryListView(
            recentItems: _recentItems,
            pastItems: _pastItems,
          ),
        ),
      ),
    );
  }
}