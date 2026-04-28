import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feast/core/core.dart';

class AppGuideScreen extends StatelessWidget {
  const AppGuideScreen({super.key});

  static const _defaultGuides = [
    {
      'title': 'Home: Your Community Dashboard',
      'body':
          "The Home screen is your central command center for all things related to F.E.A.S.T. Here, you'll find a live feed of featured community aid requests and events, a community contributions tracker, and all important announcements.",
    },
    {
      'title': 'Requests: Bridging the Gap',
      'body':
          'Learn how to submit, browse, and respond to community aid requests. This section helps connect donors with those in need. Only Barangay residents may post aid requests.',
    },
    {
      'title': 'Events: Action & Engagement',
      'body':
          'Discover upcoming community events, register as a volunteer, or post your own charity event. Both residents and non-residents can create charity events.',
    },
    {
      'title': 'Messages: Direct Communication',
      'body':
          'Use the Messages tab to communicate directly with donors, beneficiaries, or event organisers within the platform. All messages are private and admin-inaccessible.',
    },
    {
      'title': 'Settings: Identity & Customisation',
      'body':
          'Manage your profile, notification preferences, and other account customisations from the Settings screen.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FeastAppBar(title: 'App Guide'),
      drawer: const FeastDrawer(username: ''),
      bottomNavigationBar: const FeastBottomNav(currentIndex: -1),
      body: FeastBackground(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('static_content')
              .doc('app_guide')
              .snapshots(),
          builder: (context, snap) {
            List<Map<String, String>> guides = List.from(_defaultGuides);

            if (snap.hasData && snap.data!.exists) {
              final raw = snap.data!.data() as Map<String, dynamic>?;
              final adminGuides =
                  (raw?['guides'] as List?)?.cast<Map<String, dynamic>>();
              if (adminGuides != null && adminGuides.isNotEmpty) {
                guides = adminGuides
                    .map((g) => {
                          'title': g['title'] as String? ?? '',
                          'body': g['body'] as String? ?? '',
                        })
                    .toList();
              }
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FeastWhiteSection(
                    child: Column(
                      children: const [
                        Text(
                          'Welcome to the F.E.A.S.T. Guide',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontFamily: 'Outfit',
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: feastBlack),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Empowering the Almanza Dos Community',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 13,
                              color: feastGray),
                        ),
                        Divider(height: 24),
                        Text(
                          'Explore the sections below to learn how to make the most of our features.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 13,
                              color: feastGray,
                              height: 1.5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const FeastYellowSection(title: 'Guides & Tutorials'),
                  const SizedBox(height: 12),
                  ...guides.asMap().entries.map((entry) {
                    final guide = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: FeastExpandableItem(
                        title: guide['title'] ?? '',
                        initiallyExpanded: entry.key == 0,
                        content: Text(
                          guide['body'] ?? '',
                          style: const TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 13,
                              color: feastGray,
                              height: 1.5),
                        ),
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
