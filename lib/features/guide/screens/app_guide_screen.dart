// Updated app_guide_screen.dart with icons

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feast/core/core.dart';

class AppGuideScreen extends StatefulWidget {
  const AppGuideScreen({super.key});

  @override
  State<AppGuideScreen> createState() => _AppGuideScreenState();
}

class _AppGuideScreenState extends State<AppGuideScreen> {
  String _username = 'User';

  static const _defaultGuides = [
    {
      'title': 'Home: Your Community Dashboard',
      'icon': Icons.home_outlined,
      'body':
          "The Home screen is your central command center for all things related to F.E.A.S.T. Here, you'll find a live feed of featured community aid requests and events, a community contributions tracker, and all important announcements.",
    },
    {
      'title': 'Requests: Bridging the Gap',
      'icon': Icons.volunteer_activism_outlined,
      'body':
          'Learn how to submit, browse, and respond to community aid requests. This section helps connect donors with those in need. Only Barangay residents may post aid requests.',
    },
    {
      'title': 'Events: Action & Engagement',
      'icon': Icons.event_outlined,
      'body':
          'Discover upcoming community events, register as a volunteer, or post your own charity event. Both residents and non-residents can create charity events.',
    },
    {
      'title': 'Messages: Direct Communication',
      'icon': Icons.message_outlined,
      'body':
          'Use the Messages tab to communicate directly with donors, beneficiaries, or event organisers within the platform. All messages are private and admin-inaccessible.',
    },
    {
      'title': 'Settings: Identity & Customisation',
      'icon': Icons.settings_outlined,
      'body':
          'Manage your profile, notification preferences, and other account customisations from the Settings screen.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final name = await FirestoreService.instance.getCurrentUserName();
    if (mounted) setState(() => _username = name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FeastAppBar(title: 'App Guide', username: _username),
      drawer: FeastDrawer(username: _username),
      bottomNavigationBar: const FeastBottomNav(currentIndex: -1),
      body: FeastBackground(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('static_content')
              .doc('app_guide')
              .snapshots(),
          builder: (context, snap) {
            List<Map<String, dynamic>> guides = List.from(_defaultGuides);

            if (snap.hasData && snap.data!.exists) {
              final raw = snap.data!.data() as Map<String, dynamic>?;
              final adminGuides = (raw?['guides'] as List?)?.cast<Map<String, dynamic>>();
              if (adminGuides != null && adminGuides.isNotEmpty) {
                guides = adminGuides
                    .map((g) => {
                          'title': g['title'] as String? ?? '',
                          'icon': Icons.help_outline,
                          'body': g['body'] as String? ?? '',
                        })
                    .toList();
              }
            }

            return CustomScrollView(
              physics: const ClampingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        FeastWhiteSection(
                          child: Column(
                            children: const [
                              Icon(Icons.menu_book_outlined, size: 48, color: feastGreen),
                              SizedBox(height: 12),
                              Text(
                                'Welcome to the F.E.A.S.T. Guide',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Outfit',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: feastBlack,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Empowering the Almanza Dos Community',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 16,
                                  color: feastGray,
                                ),
                              ),
                              Divider(height: 24),
                              Text(
                                'Explore the sections below to learn how to make the most of our features.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 16,
                                  color: feastGray,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        const FeastYellowSection(title: 'Guides & Tutorials'),
                      ],
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final guide = guides[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        child: FeastExpandableItem(
                          title: guide['title'] ?? '',
                          icon: guide['icon'] as IconData?,
                          initiallyExpanded: index == 0,
                          content: Text(
                            guide['body'] ?? '',
                            style: const TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 16,
                              color: feastGray,
                              height: 1.6,
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: guides.length,
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 100),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
