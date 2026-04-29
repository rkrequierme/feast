// lib/features/aid_requests/screens/aid_requests_screen.dart
//
// Paginated list of approved aid requests with real-time search and filtering.
// FAB enabled only for Barangay residents.
//
// REACT.JS INTEGRATION NOTE:
// =========================
// Collection: aid_requests
// Filters: status == 'approved', optional category filter
// Sort: createdAt descending (default)
// Pagination: startAfter(lastDoc).limit(10)
// Resident check: users/{uid}.isResident === true

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feast/core/core.dart';
import 'package:feast/features/features.dart';
import 'package:feast/core/utils/date_parser.dart';

class AidRequestsScreen extends StatefulWidget {
  const AidRequestsScreen({super.key});

  @override
  State<AidRequestsScreen> createState() => _AidRequestsScreenState();
}

class _AidRequestsScreenState extends State<AidRequestsScreen> {
  final _searchController = TextEditingController();
  String? _selectedCategory;
  String _searchQuery = '';
  bool _isResident = false;
  bool _isAdmin = false;
  String _username = 'User';

  // Pagination
  final List<QueryDocumentSnapshot> _docs = [];
  DocumentSnapshot? _lastDoc;
  bool _isLoading = false;
  bool _hasMore = true;
  static const int _pageSize = 10;

  final List<Map<String, dynamic>> _filterOptions = [
    {'label': 'All', 'category': null},
    {'label': 'Most Recent', 'sort': true},
    {'label': 'Oldest', 'sort': false},
    {'label': 'Health', 'category': 'Health'},
    {'label': 'Education', 'category': 'Education'},
    {'label': 'Disaster Management', 'category': 'Disaster Management'},
    {'label': 'Basic Needs', 'category': 'Basic Needs'},
    {'label': 'Household', 'category': 'Household'},
  ];

  @override
  void initState() {
    super.initState();
    _loadUsername();
    _loadUser();
    _fetchNextPage();
    _searchController.addListener(
      () => setState(() => _searchQuery = _searchController.text.toLowerCase()),
    );
  }

  Future<void> _loadUsername() async {
    final name = await FirestoreService.instance.getCurrentUserName();
    if (mounted) setState(() => _username = name);
  }

  Future<void> _loadUser() async {
    if (AuthService.instance.currentUser == null) return;
    final data = await FirestoreService.instance.getCurrentUser();
    if (data != null && mounted) {
      setState(() {
        _isResident = data['isResident'] as bool? ?? false;
        _isAdmin = (data['role'] as String?) == 'admin';
      });
    }
  }

  Future<void> _fetchNextPage() async {
    if (_isLoading || !_hasMore) return;
    setState(() => _isLoading = true);

    try {
      final query = FirestoreService.instance.aidRequestsQuery(
        category: _selectedCategory,
        // ignoring startAfter since we removed orderBy
      );
      final snap = await query.get();
      if (!mounted) return;

      setState(() {
        if (snap.docs.isNotEmpty) {
          var fetchedDocs = snap.docs.toList();
          fetchedDocs.sort((a, b) {
            final aTime = DateParser.parse((a.data())['createdAt']);
            final bTime = DateParser.parse((b.data())['createdAt']);
            if (aTime == null || bTime == null) return 0;
            return bTime.compareTo(aTime); // newest first
          });
          _docs.clear();
          _docs.addAll(fetchedDocs);
        }
        _hasMore = false; // We loaded everything, no pagination needed
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _docs.clear();
      _lastDoc = null;
      _hasMore = true;
    });
    await _fetchNextPage();
  }

  void _applyFilter(String? category) {
    setState(() {
      _selectedCategory = category;
      _docs.clear();
      _lastDoc = null;
      _hasMore = true;
    });
    _fetchNextPage();
  }

  List<QueryDocumentSnapshot> get _filteredDocs {
    if (_searchQuery.isEmpty) return _docs;
    return _docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final title = (data['title'] as String? ?? '').toLowerCase();
      return title.contains(_searchQuery);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FeastAppBar(title: 'Aid Requests', username: _username),
      drawer: FeastDrawer(username: _username),
      body: FeastBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const SizedBox(height: 12),
              _buildSearchBar(),
              const SizedBox(height: 12),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refresh,
                  color: feastGreen,
                  child: _filteredDocs.isEmpty && !_isLoading
                      ? const EmptyStateWidget(
                          message: 'No aid requests found.',
                        )
                      : NotificationListener<ScrollNotification>(
                          onNotification: (notif) {
                            if (notif.metrics.pixels >=
                                notif.metrics.maxScrollExtent - 200) {
                              _fetchNextPage();
                            }
                            return false;
                          },
                          child: ListView.builder(
                            padding: const EdgeInsets.only(bottom: 100),
                            itemCount:
                                _filteredDocs.length + (_isLoading ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == _filteredDocs.length) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(16),
                                    child: CircularProgressIndicator(
                                      color: feastGreen,
                                    ),
                                  ),
                                );
                              }
                              final doc = _filteredDocs[index];
                              return AidRequestListItem.fromMap(
                                doc.data() as Map<String, dynamic>,
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  AppRoutes.aidRequestDetail,
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
      bottomNavigationBar: const FeastBottomNav(currentIndex: 1),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (_isAdmin) ...[
            FeastFloatingButton(
              icon: Icons.admin_panel_settings,
              tooltip: 'Admin Dashboard',
              backgroundColor: feastOrange,
              onPressed: () => Navigator.pushNamed(context, AppRoutes.adminDashboard),
            ),
            const SizedBox(height: 16),
          ],
          FeastFloatingButton(
            icon: Icons.add,
            tooltip: 'Create Aid Request',
            enabled: _isResident,
            disabledTooltip: 'Only Barangay residents may post aid requests.',
            onPressed: _isResident
                ? () => Navigator.pushNamed(context, AppRoutes.createAidRequest)
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
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
                  Icon(Icons.search, color: feastGray.withAlpha(150), size: 22),
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
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _showFilterSheet,
            child: Container(
              width: 44,
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
              child: const Icon(Icons.tune, color: feastGreen, size: 20),
            ),
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
              'Filter / Sort',
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
        _applyFilter(category);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? feastGreen : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: feastGreen),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Outfit',
            fontSize: 13,
            color: selected ? Colors.white : feastGreen,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
