// lib/features/charity_events/screens/charity_events_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feast/core/core.dart';
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

  final List<QueryDocumentSnapshot> _docs = [];
  DocumentSnapshot? _lastDoc;
  bool _isLoading = false;
  bool _hasMore = true;
  static const int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _fetchNextPage();
    _searchController.addListener(
        () => setState(() => _searchQuery = _searchController.text.toLowerCase()));
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
      final snap = await FirestoreService.instance
          .charityEventsQuery(
            category: _selectedCategory,
            startAfter: _lastDoc,
            limit: _pageSize,
          )
          .get();
      if (!mounted) return;
      setState(() {
        if (snap.docs.isNotEmpty) {
          _docs.addAll(snap.docs);
          _lastDoc = snap.docs.last;
        }
        _hasMore = snap.docs.length == _pageSize;
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
      appBar: const FeastAppBar(title: 'Charity Events'),
      drawer: const FeastDrawer(username: ''),
      body: FeastBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const SizedBox(height: 12),
              // Search bar
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
                          offset: const Offset(0, 2))
                    ],
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 12),
                      Icon(Icons.search,
                          color: feastGray.withAlpha(150), size: 22),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          style: const TextStyle(
                              fontSize: 14,
                              fontFamily: 'Outfit',
                              color: feastBlack),
                          decoration: InputDecoration(
                            hintText: 'Search...',
                            hintStyle: TextStyle(
                                fontSize: 14,
                                fontFamily: 'Outfit',
                                color: feastGray.withAlpha(150)),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.tune,
                            color: feastBlue, size: 20),
                        onPressed: () {},
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
                            itemCount:
                                _filtered.length + (_isLoading ? 1 : 0),
                            itemBuilder: (context, i) {
                              if (i == _filtered.length) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(16),
                                    child: CircularProgressIndicator(
                                        color: feastBlue),
                                  ),
                                );
                              }
                              final doc = _filtered[i];
                              final data =
                                  doc.data() as Map<String, dynamic>;
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
      floatingActionButton: FeastFloatingButton(
        icon: Icons.add,
        tooltip: 'Create Charity Event',
        backgroundColor: feastBlue,
        onPressed: () =>
            Navigator.pushNamed(context, AppRoutes.createEvent),
      ),
    );
  }
}
