// lib/features/home/screens/home_screen.dart
//
// Home screen with real Firestore data.
// No placeholder data.
//
// REACT.JS INTEGRATION NOTE:
// =========================
// Featured: query('aid_requests')
//   .where('status', '==', 'approved')
//   .orderBy('createdAt', 'desc')
//   .limit(3)
// Connect: same query with optional category filter
// Announcements: query('announcements')
//   .orderBy('createdAt', 'desc')
//   .limit(5)
// Admin role check: users/{uid}.role === 'admin'

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feast/core/core.dart';
import 'package:feast/features/features.dart';

class HomeScreen extends StatefulWidget {
  final bool isAdmin;
  const HomeScreen({super.key, this.isAdmin = false});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tabIndex = 0;
  int _featuredPage = 0;
  final PageController _featuredPageController = PageController();
  String _username = '';

  final List<Map<String, dynamic>> _categories = [
    {'icon': Icons.local_hospital_outlined, 'label': 'Health'},
    {'icon': Icons.school_outlined, 'label': 'Education'},
    {'icon': Icons.warning_amber_rounded, 'label': 'Disaster'},
    {'icon': Icons.shopping_basket_outlined, 'label': 'Basic Needs'},
    {'icon': Icons.home_outlined, 'label': 'Household'},
  ];

  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final data = await FirestoreService.instance.getCurrentUser();
    if (data == null || !mounted) return;
    setState(() {
      _username = data['displayName'] as String? ?? 'Friend';
    });
  }

  @override
  void dispose() {
    _featuredPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FeastAppBar(title: 'Home', username: _username),
      drawer: FeastDrawer(username: _username),
      body: FeastBackground(
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 16),
                _buildFeaturedSection(),
                const SizedBox(height: 24),
                _buildConnectSection(),
                const SizedBox(height: 24),
                _buildAnnouncementsSection(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: FeastBottomNav(currentIndex: 0),
      floatingActionButton: widget.isAdmin
          ? FeastFloatingButton(
              icon: Icons.admin_panel_settings,
              onPressed: () => Navigator.pushNamed(context, AppRoutes.adminDashboard),
              tooltip: 'Admin Dashboard',
            )
          : null,
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // FEATURED CAROUSEL
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildFeaturedSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const FeastTagline(
            'Featured Charity Events\n& Aid Requests',
            fontSize: 16,
            textColor: Colors.white,
            strokeColor: feastOrange,
            strokeWidth: 6,
          ),
          const SizedBox(height: 16),
          StreamBuilder<QuerySnapshot>(
            stream: FirestoreService.instance.featuredAidRequestsStream(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 200,
                  child: Center(
                    child: CircularProgressIndicator(color: feastGreen),
                  ),
                );
              }

              final docs = snap.data?.docs ?? [];
              if (docs.isEmpty) {
                return const EmptyStateWidget(
                  message: 'No featured items yet.',
                  description: 'Check back later for community updates.',
                );
              }

              return Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 300,
                    child: PageView.builder(
                      controller: _featuredPageController,
                      itemCount: docs.length,
                      onPageChanged: (i) => setState(() => _featuredPage = i),
                      itemBuilder: (context, i) {
                        final data = docs[i].data() as Map<String, dynamic>;
                        return _buildFeaturedCard(data, docs[i].id);
                      },
                    ),
                  ),
                  if (_featuredPage > 0)
                    Positioned(
                      left: 0,
                      child: _arrowButton(
                        icon: Icons.chevron_left,
                        onTap: () => _featuredPageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        ),
                      ),
                    ),
                  if (docs.isNotEmpty && _featuredPage < docs.length - 1)
                    Positioned(
                      right: 0,
                      child: _arrowButton(
                        icon: Icons.chevron_right,
                        onTap: () => _featuredPageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          // Dot indicators
          StreamBuilder<QuerySnapshot>(
            stream: FirestoreService.instance.featuredAidRequestsStream(),
            builder: (context, snap) {
              final count = snap.data?.docs.length ?? 0;
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  count,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: _featuredPage == i ? 20 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: _featuredPage == i ? feastGreen : feastLightGreen,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedCard(Map<String, dynamic> data, String id) {
    final images = (data['imageUrls'] as List?)?.cast<String>() ?? [];
    final title = data['title'] as String? ?? '';
    final description = data['description'] as String? ?? '';

    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.aidRequestDetail,
        arguments: id,
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: SizedBox(
                height: 160,
                width: double.infinity,
                child: images.isNotEmpty
                    ? Image.network(images.first, fit: BoxFit.cover)
                    : Container(
                        color: feastLightGreen.withAlpha(102),
                        child: const Icon(Icons.volunteer_activism, size: 60, color: feastGreen),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Outfit',
                      color: feastBlue,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'Outfit',
                      color: feastGray,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tap to begin. Swipe for more.',
                    style: TextStyle(fontSize: 11, fontFamily: 'Outfit', color: feastGray),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // CONNECT & CONTRIBUTE
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildConnectSection() {
    return BottomFormBackground(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            const FeastTagline(
              'Connect & Contribute',
              fontSize: 18,
              textColor: Colors.white,
              strokeColor: feastBlue,
              strokeWidth: 6,
            ),
            const Text(
              "See What's Happening Now",
              style: TextStyle(
                fontSize: 13,
                fontFamily: 'Outfit',
                fontWeight: FontWeight.w600,
                color: feastGreen,
              ),
            ),
            const SizedBox(height: 16),
            // Category chips
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final cat = _categories[i];
                  final selected = _selectedCategory == cat['label'];
                  return GestureDetector(
                    onTap: () => setState(() {
                      _selectedCategory = selected ? null : cat['label'] as String;
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: selected ? feastGreen : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: feastLightGreen, width: 1.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(cat['icon'] as IconData,
                              size: 16, color: selected ? Colors.white : feastGreen),
                          const SizedBox(width: 4),
                          Text(
                            cat['label'] as String,
                            style: TextStyle(
                              fontSize: 11,
                              fontFamily: 'Outfit',
                              fontWeight: FontWeight.w600,
                              color: selected ? Colors.white : feastGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            // Tab buttons
            Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(13),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _buildTab('Requests', 0),
                  _buildTab('Events', 1),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _tabIndex == 0 ? _buildAidRequestsList() : _buildEventsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isActive = _tabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tabIndex = index),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive ? (index == 0 ? feastGreen : feastBlue) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Outfit',
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.white : feastGray,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAidRequestsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirestoreService.instance
          .aidRequestsQuery(category: _selectedCategory, limit: 5)
          .snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: feastGreen));
        }
        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) {
          return const EmptyStateWidget(message: 'No aid requests yet.');
        }
        return Column(
          children: docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return _buildContentCard(
              data: data,
              id: doc.id,
              route: AppRoutes.aidRequestDetail,
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildEventsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirestoreService.instance
          .charityEventsQuery(category: _selectedCategory, limit: 5)
          .snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: feastGreen));
        }
        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) {
          return const EmptyStateWidget(message: 'No events yet.');
        }
        return Column(
          children: docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return _buildContentCard(
              data: data,
              id: doc.id,
              route: AppRoutes.eventDetail,
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildContentCard({
    required Map<String, dynamic> data,
    required String id,
    required String route,
  }) {
    final images = (data['imageUrls'] as List?)?.cast<String>() ?? [];
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route, arguments: id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(15),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: SizedBox(
                width: 100,
                height: 110,
                child: images.isNotEmpty
                    ? Image.network(images.first, fit: BoxFit.cover)
                    : Container(
                        color: feastLightGreen.withAlpha(77),
                        child: Icon(Icons.image_outlined,
                            size: 36, color: feastGreen.withAlpha(102)),
                      ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['title'] as String? ?? '',
                      style: const TextStyle(
                        fontSize: 13,
                        fontFamily: 'Outfit',
                        fontWeight: FontWeight.bold,
                        color: feastBlack,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      data['description'] as String? ?? '',
                      style: TextStyle(
                        fontSize: 11,
                        fontFamily: 'Outfit',
                        color: feastGray.withAlpha(204),
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // OFFICIAL ANNOUNCEMENTS
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildAnnouncementsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const FeastTagline(
            'Official Announcements',
            fontSize: 17,
            textColor: Colors.white,
            strokeColor: feastGreen,
            strokeWidth: 6,
          ),
          const Text(
            'Stay Active & Updated',
            style: TextStyle(
              fontSize: 13,
              fontFamily: 'Outfit',
              fontWeight: FontWeight.w600,
              color: feastOrange,
            ),
          ),
          const SizedBox(height: 16),
          StreamBuilder<QuerySnapshot>(
            stream: FirestoreService.instance.announcementsStream(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: feastGreen));
              }
              final docs = snap.data?.docs ?? [];
              if (docs.isEmpty) {
                return const EmptyStateWidget(message: 'No announcements yet.');
              }
              return Column(
                children: docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return GestureDetector(
                    onTap: () => showDialog(
                      context: context,
                      builder: (_) => AnnouncementModal(data: data),
                    ),
                    child: _buildAnnouncementCard(data),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementCard(Map<String, dynamic> data) {
    final images = (data['imageUrls'] as List?)?.cast<String>() ?? [];
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              bottomLeft: Radius.circular(16),
            ),
            child: SizedBox(
              width: 100,
              height: 100,
              child: images.isNotEmpty
                  ? Image.network(images.first, fit: BoxFit.cover)
                  : Container(
                      color: feastLightYellow.withAlpha(102),
                      child: Icon(Icons.campaign_outlined,
                          size: 36, color: feastOrange.withAlpha(128)),
                    ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['title'] as String? ?? '',
                    style: const TextStyle(
                      fontSize: 13,
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.bold,
                      color: feastBlack,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data['body'] as String? ?? '',
                    style: TextStyle(
                      fontSize: 11,
                      fontFamily: 'Outfit',
                      color: feastGray.withAlpha(204),
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _arrowButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(200),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black.withAlpha(25), blurRadius: 6),
          ],
        ),
        child: Icon(icon, color: feastGreen, size: 24),
      ),
    );
  }
}
