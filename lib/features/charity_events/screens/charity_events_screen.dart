// lib/features/charity_events/screens/charity_events_screen.dart
//
// Paginated list of approved charity events with real-time search and filtering.
//
// REACT.JS INTEGRATION NOTE:
// =========================
// Collection: charity_events
// Fields: title, description, category, location, startTime, endTime,
//         status, imageUrls, participantCount
// React query:
//   const q = query(
//     collection(db, 'charity_events'),
//     where('status', '==', 'approved'),
//     orderBy('startTime', 'desc'),
//     limit(10)
//   );
//   const snapshot = await getDocs(q);
// Pagination: use startAfter(lastDoc)

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feast/core/core.dart';
import 'package:feast/features/features.dart';
import 'package:feast/core/utils/date_parser.dart';
import 'package:feast/core/services/firestore_service.dart';

class CharityEventsScreen extends StatefulWidget {
  const CharityEventsScreen({super.key});

  @override
  State<CharityEventsScreen> createState() => _CharityEventsScreenState();
}

class _CharityEventsScreenState extends State<CharityEventsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategory;
  String _username = 'User';
  bool _isAdmin = false;

  final List<Map<String, dynamic>> _filterOptions = [
    {'label': 'All', 'category': null},
    {'label': 'Health', 'category': 'Health'},
    {'label': 'Education', 'category': 'Education'},
    {'label': 'Disaster Management', 'category': 'Disaster Management'},
    {'label': 'Basic Needs', 'category': 'Basic Needs'},
    {'label': 'Household', 'category': 'Household'},
  ];

  // Pagination
  final List<QueryDocumentSnapshot> _docs = [];
  DocumentSnapshot? _lastDoc;
  bool _isLoading = false;
  bool _hasMore = true;
  static const int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _fetchNextPage();
    _searchController.addListener(
      () => setState(() => _searchQuery = _searchController.text.toLowerCase()),
    );
  }

  Future<void> _loadUser() async {
    final data = await FirestoreService.instance.getCurrentUser();
    if (data == null || !mounted) return;
    setState(() {
      _username = data['displayName'] as String? ?? 'User';
      _isAdmin = (data['role'] as String?) == 'admin';
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchNextPage() async {
    if (_isLoading || !_hasMore) return;
    setState(() => _isLoading = true);

    try {
      Query<Map<String, dynamic>> query = FirebaseFirestore.instance
          .collection(FirestorePaths.charityEvents)
          .where('status', isEqualTo: 'approved')
          .orderBy('startTime', descending: false)
          .orderBy(FieldPath.documentId);
      
      if (_selectedCategory != null && _selectedCategory != 'All') {
        query = query.where('category', isEqualTo: _selectedCategory);
      }
      if (_lastDoc != null) {
        query = query.startAfterDocument(_lastDoc!);
      }
      
      final snap = await query.limit(_pageSize).get();
      
      if (!mounted) return;
      setState(() {
        if (snap.docs.isNotEmpty) {
          _docs.addAll(snap.docs);
          _lastDoc = snap.docs.last;
        }
        _hasMore = snap.docs.length == _pageSize;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Pagination error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _docs.clear();
      _lastDoc = null;
      _hasMore = true;
      _isLoading = false;
    });
    await _fetchNextPage();
  }

  List<QueryDocumentSnapshot> get _filtered {
    if (_searchQuery.isEmpty) return _docs;
    return _docs.where((d) {
      final title = ((d.data() as Map)['title'] as String? ?? '').toLowerCase();
      return title.contains(_searchQuery);
    }).toList();
  }

  String _statusLabel(Map<String, dynamic> data) {
    final start = (data['startTime'] as Timestamp?)?.toDate();
    final end = (data['endTime'] as Timestamp?)?.toDate();
    final now = DateTime.now();
    if (start == null) return 'Not Yet Started';
    if (now.isBefore(start)) return 'Not Yet Started';
    if (end != null && now.isAfter(end)) return 'Concluded';
    return 'Ongoing';
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Ongoing':
        return feastSuccess;
      case 'Concluded':
        return feastGray;
      default:
        return feastOrange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FeastAppBar(title: 'Charity Events',),
      drawer: FeastDrawer(username: _username),
      body: FeastBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const SizedBox(height: 12),
              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(15),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 12),
                      Icon(
                        Icons.search,
                        color: feastGray.withAlpha(150),
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          style: const TextStyle(
                            fontSize: 14,
                            fontFamily: 'Outfit',
                            color: feastBlack,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search...',
                            hintStyle: TextStyle(
                              fontSize: 14,
                              fontFamily: 'Outfit',
                              color: feastGray.withAlpha(150),
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 10,
                            ),
                          ),
                        ),
                      ),
                      // Filter button
                      IconButton(
                        icon: const Icon(
                          Icons.tune,
                          color: feastBlue,
                          size: 20,
                        ),
                        onPressed: _showFilterSheet,
                        splashRadius: 20,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refresh,
                  color: feastBlue,
                  child: _filtered.isEmpty && !_isLoading
                      ? const EmptyStateWidget(message: 'No events found.')
                      : NotificationListener<ScrollNotification>(
                          onNotification: (n) {
                            if (n.metrics.pixels >=
                                n.metrics.maxScrollExtent - 200) {
                              _fetchNextPage();
                            }
                            return false;
                          },
                          child: ListView.builder(
                            padding: const EdgeInsets.only(bottom: 100),
                            itemCount: _filtered.length + (_isLoading ? 1 : 0),
                            itemBuilder: (context, i) {
                              if (i == _filtered.length) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(16),
                                    child: CircularProgressIndicator(
                                      color: feastBlue,
                                    ),
                                  ),
                                );
                              }
                              final doc = _filtered[i];
                              final data = doc.data() as Map<String, dynamic>;
                              final status = _statusLabel(data);
                              return CharityEventListItem(
                                data: data,
                                docId: doc.id,
                                statusLabel: status,
                                statusColor: _statusColor(status),
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  AppRoutes.eventDetail,
                                  arguments: doc.id,
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const FeastBottomNav(currentIndex: 2),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (_isAdmin) ...[
            FeastFloatingButton(
              icon: Icons.admin_panel_settings,
              tooltip: 'Admin Dashboard',
              backgroundColor: feastOrange,
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.adminDashboard),
            ),
            const SizedBox(height: 16),
          ],
          FeastFloatingButton(
            icon: Icons.add,
            tooltip: 'Create Charity Event',
            backgroundColor: feastBlue,
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.createEvent),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter by Category',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _filterOptions
                  .map(
                    (opt) => _filterChip(
                      opt['label'] as String,
                      opt['category'] as String?,
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, String? category) {
    final selected = _selectedCategory == category;
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        setState(() {
          _selectedCategory = category;
          _docs.clear();
          _lastDoc = null;
          _hasMore = true;
          _isLoading = false;
        });
        _fetchNextPage();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? feastBlue : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: feastBlue),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Outfit',
            fontSize: 13,
            color: selected ? Colors.white : feastBlue,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
