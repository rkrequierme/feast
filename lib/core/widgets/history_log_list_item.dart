// lib/core/widgets/history_log_list_item.dart
//
// Activity log list item and sortable list view.
// Real data comes from FirestoreService.instance.activityLogsStream()
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

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

enum LogStatus { approved, pending, rejected, success, inProgress }

class HistoryLogListItem extends StatelessWidget {
  final String id;
  final String actionType;
  final String description;
  final String formattedDate;
  final LogStatus status;
  final DateTime? sortableDate;

  const HistoryLogListItem({
    super.key,
    required this.id,
    required this.actionType,
    required this.description,
    required this.formattedDate,
    required this.status,
    this.sortableDate,
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
        return Icons.person_outline;
      case 'Credential Changes':
        return Icons.sync;
      default:
        return Icons.edit_note;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 3)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(_actionIcon, size: 20, color: Colors.black54),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  actionType,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 11,
                    color: Colors.black45,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  formattedDate,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 11,
                    color: Colors.black45,
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _statusLabel,
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: _statusColor,
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 16,
                color: _statusColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sort Options
// ─────────────────────────────────────────────────────────────────────────────

enum _SortOption { newest, oldest, inProgress, logType }

// ─────────────────────────────────────────────────────────────────────────────
// HistoryListView - No placeholder data, uses Firestore streams
// ─────────────────────────────────────────────────────────────────────────────

class HistoryListView extends StatefulWidget {
  final List<HistoryLogListItem> recentItems;
  final List<HistoryLogListItem> pastItems;

  const HistoryListView({
    super.key,
    required this.recentItems,
    required this.pastItems,
  });

  /// Creates an empty view with no hardcoded data.
  /// Real data comes from FirestoreService.instance.activityLogsStream()
  factory HistoryListView.empty() {
    return const HistoryListView(
      recentItems: [],
      pastItems: [],
    );
  }

  @override
  State<HistoryListView> createState() => _HistoryListViewState();
}

class _HistoryListViewState extends State<HistoryListView> {
  _SortOption _currentSort = _SortOption.newest;

  List<HistoryLogListItem> _sorted(List<HistoryLogListItem> items, _SortOption option) {
    final copy = List<HistoryLogListItem>.from(items);
    switch (option) {
      case _SortOption.newest:
        copy.sort((a, b) => (b.sortableDate ?? DateTime(0)).compareTo(a.sortableDate ?? DateTime(0)));
        break;
      case _SortOption.oldest:
        copy.sort((a, b) => (a.sortableDate ?? DateTime(0)).compareTo(b.sortableDate ?? DateTime(0)));
        break;
      case _SortOption.inProgress:
        return copy.where((e) => e.status == LogStatus.inProgress).toList();
      case _SortOption.logType:
        copy.sort((a, b) {
          final typeCompare = a.actionType.compareTo(b.actionType);
          if (typeCompare != 0) return typeCompare;
          return (b.sortableDate ?? DateTime(0)).compareTo(a.sortableDate ?? DateTime(0));
        });
        break;
    }
    return copy;
  }

  void _showSortDialog() {
    _SortOption dialogSelection = _currentSort;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              backgroundColor: Colors.white,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Sort Logs By:',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.of(ctx).pop(),
                          child: const Icon(Icons.close, size: 20, color: Colors.black45),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...[
                      (_SortOption.newest, 'Newest'),
                      (_SortOption.oldest, 'Oldest'),
                      (_SortOption.inProgress, 'In Progress'),
                      (_SortOption.logType, 'Log Type'),
                    ].map((entry) {
                      final (option, label) = entry;
                      final selected = dialogSelection == option;
                      return InkWell(
                        onTap: () {
                          setDialogState(() => dialogSelection = option);
                          setState(() => _currentSort = option);
                          Navigator.of(ctx).pop();
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                          child: Row(
                            children: [
                              Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: selected ? Colors.green : Colors.transparent,
                                  border: Border.all(
                                    color: selected ? Colors.green : Colors.grey.shade400,
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: selected
                                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                                    : null,
                              ),
                              const SizedBox(width: 14),
                              Text(
                                label,
                                style: TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 15,
                                  fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Nunito',
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Colors.black87,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recent = _sorted(widget.recentItems, _currentSort);
    final past = _sorted(widget.pastItems, _currentSort);
    final showPastFirst = _currentSort == _SortOption.oldest;

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.only(bottom: 90),
          children: [
            if (!showPastFirst) ...[
              if (recent.isNotEmpty) ...[
                _sectionHeader('Recent Activity Logs'),
                ...recent,
              ],
              if (past.isNotEmpty) ...[
                _sectionHeader('Past Activity Logs'),
                ...past,
              ],
            ] else ...[
              if (past.isNotEmpty) ...[
                _sectionHeader('Past Activity Logs'),
                ...past,
              ],
              if (recent.isNotEmpty) ...[
                _sectionHeader('Recent Activity Logs'),
                ...recent,
              ],
            ],
            if (recent.isEmpty && past.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Text(
                    'No activity logs found.',
                    style: TextStyle(fontFamily: 'Nunito', color: Colors.black45),
                  ),
                ),
              ),
          ],
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: GestureDetector(
            onTap: _showSortDialog,
            child: Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                color: Color(0xFF4CAF50),
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3))],
              ),
              child: const Icon(Icons.sort, color: Colors.white, size: 26),
            ),
          ),
        ),
      ],
    );
  }
}
