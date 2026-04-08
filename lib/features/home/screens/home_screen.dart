import 'package:flutter/material.dart';
import 'package:feast/core/core.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;
  int _tabIndex = 0; // 0 = Requests, 1 = Events
  int _featuredPage = 0;
  final PageController _featuredPageController = PageController();

  // ─── Placeholder featured items ───
  final List<Map<String, String>> _featuredItems = [
    {
      'title': 'Almanza Dos Food Bank',
      'description':
          'Feed the community of The Almanza Dos Food Bank! '
          'Feed by donating, volunteering to prepare or deliver meals to our neighbors in need.',
      'cta': 'Tap to begin donating now.',
      'tags': 'food, donations',
    },
    {
      'title': 'Back-to-School Drive',
      'description':
          'Help children in Almanza Dos get ready for the school year. '
          'Donate school supplies, uniforms, or funds to support their education.',
      'cta': 'Tap to contribute today.',
      'tags': 'education, supplies',
    },
    {
      'title': 'Disaster Relief Fund',
      'description':
          'Support families affected by recent flooding in the community. '
          'Every contribution helps provide food, shelter, and essentials.',
      'cta': 'Tap to donate now.',
      'tags': 'disaster, relief',
    },
  ];

  // ─── Category Chip Data ───
  final List<Map<String, dynamic>> _categories = [
    {'icon': Icons.local_hospital_outlined, 'label': 'Health'},
    {'icon': Icons.school_outlined, 'label': 'Education'},
    {'icon': Icons.warning_amber_rounded, 'label': 'Disaster'},
    {'icon': Icons.shopping_basket_outlined, 'label': 'Basic Needs'},
    {'icon': Icons.home_outlined, 'label': 'Household'},
  ];

  // ─── Placeholder aid request data ───
  final List<Map<String, String>> _placeholderRequests = [
    {
      'title': 'Desperate Need For Medicine',
      'author': 'Juan De La Cruz',
      'description':
          'Help a neighbor out... Taking maintenance medicine but cannot afford to buy them anymore...',
      'tags': 'health, medicine',
    },
    {
      'title': 'Fees For Dengue Treatment',
      'author': 'Maria Santos',
      'description':
          'My child needs treatment for dengue. Hospital bills are piling up and we need help paying them...',
      'tags': 'health, medical',
    },
    {
      'title': 'Somehow Son... I\'m Scared.',
      'author': 'Pedro Garcia',
      'description':
          'I haven\'t eaten in 3 days and need food. Basic necessities to sustain my family...',
      'tags': 'basic needs, food',
    },
  ];

  // ─── Placeholder event data ───
  final List<Map<String, String>> _placeholderEvents = [
    {
      'title': 'Community Feeding Program',
      'author': 'F.E.A.S.T. Team',
      'description':
          'Monthly community feeding for families in need. Join us to help nourish our community...',
      'tags': 'food, community',
    },
    {
      'title': 'School Supply Drive',
      'author': 'Volunteer Group',
      'description':
          'Providing school supplies for underprivileged students preparing for the next school year...',
      'tags': 'education, supplies',
    },
  ];

  // ─── Placeholder announcement data ───
  final List<Map<String, dynamic>> _placeholderAnnouncements = [
    {
      'title': 'Updated Policies & Guidelines',
      'author': 'F.E.A.S.T. Admin',
      'description':
          'We have updated our community guidelines. Please take a moment to review the new policies...',
      'hasImage': true,
    },
    {
      'title': 'Welcome To F.E.A.S.T.!',
      'author': 'F.E.A.S.T. Team',
      'description':
          'Thank you for joining our community! Together we can make a difference in the lives of others...',
      'hasImage': true,
    },
    {
      'title': 'Welcoming Help & Active Support',
      'author': 'F.E.A.S.T. Admin',
      'description':
          'We are always open to volunteers and donors who wish to help in our mission...',
      'hasImage': false,
    },
  ];

  void _onNavTap(int index) {
    if (index == _navIndex) return;
    switch (index) {
      case 0:
        break; // Already on Home
      case 1:
        Navigator.pushNamed(context, AppRoutes.aidRequests);
        break;
      case 2:
        Navigator.pushNamed(context, AppRoutes.charityEvents);
        break;
      case 3:
        Navigator.pushNamed(context, AppRoutes.messages);
        break;
      case 4:
        Navigator.pushNamed(context, AppRoutes.settings);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: feastLightGreen,
        elevation: 0,
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: feastBlack),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Home',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Outfit',
                color: feastBlack,
              ),
            ),
            Text(
              'Welcome To F.E.A.S.T., Juan!',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                fontFamily: 'Outfit',
                color: feastBlack.withAlpha(179),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, color: feastBlack, size: 32),
            onPressed: () {},
          ),
        ],
      ),
      drawer: const FeastDrawer(userName: 'Juan De La Cruz'),
      body: FeastBackground(
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 16),

                // ─── Featured Charity Events & Aid Requests ───
                _buildFeaturedSection(),

                const SizedBox(height: 24),

                // ─── Connect & Contribute ───
                _buildConnectSection(),

                const SizedBox(height: 24),

                // ─── Official Announcements ───
                _buildAnnouncementsSection(),

                const SizedBox(height: 100), // Space for nav bar
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: FeastBottomNav(
        currentIndex: _navIndex,
        onTap: _onNavTap,
      ),
    );
  }

  @override
  void dispose() {
    _featuredPageController.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════
  // ─── FEATURED SECTION ───
  // ═══════════════════════════════════════════════════
  Widget _buildFeaturedSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Section Title
          const FeastTagline(
            'Featured Charity Events\n& Aid Requests',
            fontSize: 16,
            textColor: Colors.white,
            strokeColor: feastOrange,
            strokeWidth: 6,
          ),
          const SizedBox(height: 16),

          // Featured Carousel with Arrows
          Stack(
            alignment: Alignment.center,
            children: [
              // PageView Cards
              SizedBox(
                height: 340,
                child: PageView.builder(
                  controller: _featuredPageController,
                  itemCount: _featuredItems.length,
                  onPageChanged: (index) {
                    setState(() => _featuredPage = index);
                  },
                  itemBuilder: (context, index) {
                    return _buildFeaturedCard(_featuredItems[index]);
                  },
                ),
              ),

              // Left Arrow
              if (_featuredPage > 0)
                Positioned(
                  left: 0,
                  child: GestureDetector(
                    onTap: () {
                      _featuredPageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(200),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(25),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.chevron_left,
                        color: feastGreen,
                        size: 24,
                      ),
                    ),
                  ),
                ),

              // Right Arrow
              if (_featuredPage < _featuredItems.length - 1)
                Positioned(
                  right: 0,
                  child: GestureDetector(
                    onTap: () {
                      _featuredPageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(200),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(25),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.chevron_right,
                        color: feastGreen,
                        size: 24,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          // Page Indicator Dots
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _featuredItems.length,
              (index) => Container(
                width: _featuredPage == index ? 20 : 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: _featuredPage == index ? feastGreen : feastLightGreen,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedCard(Map<String, String> item) {
    final tags = (item['tags'] ?? '').split(', ');
    return Container(
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
          // Featured Image Placeholder
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    feastLightGreen.withAlpha(128),
                    feastLighterBlue.withAlpha(128),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      Icons.volunteer_activism,
                      size: 60,
                      color: feastGreen.withAlpha(102),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    right: 20,
                    child: Icon(
                      Icons.child_care,
                      size: 40,
                      color: feastOrange.withAlpha(128),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Card Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Title with leaf decorations
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.eco, color: feastGreen, size: 18),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        item['title'] ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Outfit',
                          color: feastBlue,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.eco, color: feastGreen, size: 18),
                  ],
                ),
                const SizedBox(height: 8),

                Text(
                  item['description'] ?? '',
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

                Text(
                  item['cta'] ?? '',
                  style: const TextStyle(
                    fontSize: 11,
                    fontFamily: 'Outfit',
                    fontWeight: FontWeight.w600,
                    color: feastGray,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  children: tags.map((t) => _buildTag(t.trim())).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  // ─── CONNECT & CONTRIBUTE SECTION ───
  // ═══════════════════════════════════════════════════
  Widget _buildConnectSection() {
    final items = _tabIndex == 0 ? _placeholderRequests : _placeholderEvents;

    return BottomFormBackground(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            // Section Title
            const FeastTagline(
              'Connect & Contribute',
              fontSize: 18,
              textColor: Colors.white,
              strokeColor: feastBlue,
              strokeWidth: 6,
            ),
            const Text(
              'See What\'s Happening Now',
              style: TextStyle(
                fontSize: 13,
                fontFamily: 'Outfit',
                fontWeight: FontWeight.w600,
                color: feastGreen,
              ),
            ),
            const SizedBox(height: 16),

            // ─── Category Chips ───
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: feastLightGreen, width: 1.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          cat['icon'] as IconData,
                          size: 16,
                          color: feastGreen,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          cat['label'] as String,
                          style: const TextStyle(
                            fontSize: 11,
                            fontFamily: 'Outfit',
                            fontWeight: FontWeight.w600,
                            color: feastGreen,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // ─── Tab Buttons (Requests / Events) ───
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
                children: [_buildTab('Requests', 0), _buildTab('Events', 1)],
              ),
            ),
            const SizedBox(height: 16),

            // ─── Cards List ───
            ...items.map((item) => _buildContentCard(item)),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  // ─── OFFICIAL ANNOUNCEMENTS SECTION ───
  // ═══════════════════════════════════════════════════
  Widget _buildAnnouncementsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Section Title
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

          // Announcement Cards
          ..._placeholderAnnouncements.map(
            (item) => _buildAnnouncementCard(item),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  // ─── HELPER WIDGETS ───
  // ═══════════════════════════════════════════════════

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: feastLightGreen.withAlpha(102),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          fontFamily: 'Outfit',
          fontWeight: FontWeight.w600,
          color: feastGreen,
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
            color: isActive ? feastGreen : Colors.transparent,
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

  Widget _buildContentCard(Map<String, String> item) {
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
          // Image Placeholder
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              bottomLeft: Radius.circular(16),
            ),
            child: Container(
              width: 100,
              height: 110,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    feastLightGreen.withAlpha(102),
                    feastLighterBlue.withAlpha(102),
                  ],
                ),
              ),
              child: Icon(
                Icons.image_outlined,
                size: 36,
                color: feastGreen.withAlpha(102),
              ),
            ),
          ),

          // Card Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title'] ?? '',
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
                  Row(
                    children: [
                      const Icon(
                        Icons.person_outline,
                        size: 12,
                        color: feastGray,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        item['author'] ?? '',
                        style: const TextStyle(
                          fontSize: 10,
                          fontFamily: 'Outfit',
                          color: feastGray,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['description'] ?? '',
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

  Widget _buildAnnouncementCard(Map<String, dynamic> item) {
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
          // Image placeholder
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              bottomLeft: Radius.circular(16),
            ),
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    feastLightYellow.withAlpha(128),
                    feastLightGreen.withAlpha(77),
                  ],
                ),
              ),
              child: Icon(
                Icons.campaign_outlined,
                size: 36,
                color: feastOrange.withAlpha(128),
              ),
            ),
          ),

          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title'] as String? ?? '',
                    style: const TextStyle(
                      fontSize: 13,
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.bold,
                      color: feastBlack,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(
                        Icons.person_outline,
                        size: 12,
                        color: feastGray,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        item['author'] as String? ?? '',
                        style: const TextStyle(
                          fontSize: 10,
                          fontFamily: 'Outfit',
                          color: feastGray,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['description'] as String? ?? '',
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
}
