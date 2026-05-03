// lib/features/history/screens/history_screen.dart
//
// Real-time activity log from Firestore.
// Split into Recent (today) and Past (older) sections.
// Sort options: Newest | Oldest | In Progress | Log Type.
// Logs are read-only — no delete action exposed to users.
//
// REACT.JS INTEGRATION NOTE:
// =========================
// Collection: users/{uid}/activity_logs
// Fields: type, description, status, timestamp
// React query:
//   const q = query(
//     collection(db, 'users', uid, 'activity_logs'),
//     orderBy('timestamp', 'desc')
//   );
//   const snapshot = await getDocs(q);
// Filtering: where('status', '==', 'pending') for In Progress tab
// Sorting: orderBy('type') for Log Type sort
// Logs are READ-ONLY — no delete exposed to users in Flutter or React.

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:feast/core/core.dart';

enum _SortOption { newest, oldest, inProgress, logType }

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  _SortOption _sortOption = _SortOption.newest;
  String _username = 'User';

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final name = await FirestoreService.instance.getCurrentUserName();
    if (mounted) setState(() => _username = name);
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'success':
        return feastSuccess;
      case 'pending':
        return feastOrange;
      case 'rejected':
      case 'denied':
        return feastError;
      case 'warning':
        return feastWarning;
      default:
        return feastBlue;
    }
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'User Authentication':
        return Icons.person_outline;
      case 'Credential Changes':
        return Icons.lock_reset_outlined;
      case 'Post Handling':
        return Icons.edit_note_outlined;
      case 'Donation':
        return Icons.volunteer_activism_outlined;
      case 'Event Participation':
        return Icons.event_outlined;
      case 'Report':
        return Icons.flag_outlined;
      case 'Profile Update':
        return Icons.manage_accounts_outlined;
      default:
        return Icons.history_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FeastAppBar(title: 'Your History',),
      drawer: FeastDrawer(username: _username),
      body: FeastBackground(
        child: SafeArea(
          bottom: false,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirestoreService.instance.activityLogsStream(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: feastGreen));
              }

              var docs = snap.data?.docs ?? [];

              // Apply sort
              switch (_sortOption) {
                case _SortOption.newest:
                  docs.sort((a, b) {
                    final aTs = (a.data() as Map)['timestamp'] as Timestamp?;
                    final bTs = (b.data() as Map)['timestamp'] as Timestamp?;
                    return (bTs?.seconds ?? 0).compareTo(aTs?.seconds ?? 0);
                  });
                  break;
                case _SortOption.oldest:
                  docs.sort((a, b) {
                    final aTs = (a.data() as Map)['timestamp'] as Timestamp?;
                    final bTs = (b.data() as Map)['timestamp'] as Timestamp?;
                    return (aTs?.seconds ?? 0).compareTo(bTs?.seconds ?? 0);
                  });
                  break;
                case _SortOption.inProgress:
                  docs = docs
                      .where((d) =>
                          ((d.data() as Map)['status'] as String? ?? '').toLowerCase() == 'pending')
                      .toList();
                  break;
                case _SortOption.logType:
                  docs.sort((a, b) {
                    final aType = (a.data() as Map)['type'] as String? ?? '';
                    final bType = (b.data() as Map)['type'] as String? ?? '';
                    return aType.compareTo(bType);
                  });
                  break;
              }

              if (docs.isEmpty) {
                return const EmptyStateWidget(message: 'No activity recorded yet.');
              }

              // Split into today vs past
              final todayStart = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

              final recent = docs.where((d) {
                final ts = ((d.data() as Map)['timestamp'] as Timestamp?)?.toDate();
                return ts != null && ts.isAfter(todayStart);
              }).toList();

              final past = docs.where((d) {
                final ts = ((d.data() as Map)['timestamp'] as Timestamp?)?.toDate();
                return ts == null || !ts.isAfter(todayStart);
              }).toList();

              return ListView(
                padding: const EdgeInsets.only(bottom: 100),
                children: [
                  if (recent.isNotEmpty) ...[
                    _sectionHeader('Recent Activity Logs'),
                    ...recent.map((d) => _logTile(d)).toList(),
                  ],
                  if (past.isNotEmpty) ...[
                    _sectionHeader('Past Activity Logs'),
                    ...past.map((d) => _logTile(d)).toList(),
                  ],
                ],
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: const FeastBottomNav(currentIndex: -1),
      floatingActionButton: FloatingActionButton(
        backgroundColor: feastGreen,
        mini: true,
        tooltip: 'Sort Logs',
        onPressed: _showSortModal,
        child: const Icon(Icons.sort, color: Colors.white),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
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

  Widget _logTile(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final type = data['type'] as String? ?? 'Activity';
    final description = data['description'] as String? ?? '';
    final status = data['status'] as String? ?? '';
    final timestamp = (data['timestamp'] as Timestamp?)?.toDate();
    final timeStr = timestamp != null
        ? DateFormat('MM-dd-yyyy | h:mm a').format(timestamp)
        : 'N/A';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _statusColor(status).withAlpha(25),
            shape: BoxShape.circle,
          ),
          child: Icon(_typeIcon(type), color: _statusColor(status), size: 20),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              type,
              style: const TextStyle(
                fontFamily: 'Outfit',
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: feastGray,
              ),
            ),
            Text(
              description,
              style: const TextStyle(
                fontFamily: 'Outfit',
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: feastBlack,
              ),
            ),
            Text(
              timeStr,
              style: const TextStyle(
                fontFamily: 'Outfit',
                fontSize: 10,
                color: feastGray,
              ),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _statusColor(status).withAlpha(20),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            status,
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: _statusColor(status),
            ),
          ),
        ),
      ),
    );
  }

  void _showSortModal() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Sort Logs By:',
                    style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...[
                ('Newest', _SortOption.newest),
                ('Oldest', _SortOption.oldest),
                ('In Progress', _SortOption.inProgress),
                ('Log Type', _SortOption.logType),
              ].map((pair) {
                final isSelected = _sortOption == pair.$2;
                return RadioListTile<_SortOption>(
                  value: pair.$2,
                  groupValue: _sortOption,
                  activeColor: feastGreen,
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    pair.$1,
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? feastGreen : feastBlack,
                    ),
                  ),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _sortOption = val);
                      Navigator.pop(context);
                    }
                  },
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}
