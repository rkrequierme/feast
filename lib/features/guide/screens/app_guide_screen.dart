import 'package:flutter/material.dart';
import 'package:feast/core/core.dart';

class AppGuideScreen extends StatefulWidget {
  const AppGuideScreen({super.key});

  @override
  State<AppGuideScreen> createState() => _AppGuideScreenState();
}

class _AppGuideScreenState extends State<AppGuideScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FeastAppBar(title: 'App Guide'),
      drawer: const FeastDrawer(username: 'Juan De La Cruz'),
      bottomNavigationBar: FeastBottomNav(currentIndex: -1),
      backgroundColor: feastLightYellow,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Hero Card ─────────────────────────────────────────────
            FeastWhiteSection(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  Text(
                    'Welcome to the F.E.A.S.T. Guide',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Empowering the Almanza Dos Community',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                  Divider(height: 24),
                  Text(
                    'Explore the sections below to learn how to make the most '
                    'of our features. Take your time navigating through our '
                    'detailed app instructions as if it were a tutorial.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 13,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Section Header ────────────────────────────────────────
            const FeastYellowSection(title: 'Guides & Tutorials'),

            const SizedBox(height: 12),

            // ── Expandable Items ──────────────────────────────────────
            FeastExpandableItem(
              title: 'Home: Your Community Dashboard',
              initiallyExpanded: true,
              content: const Text(
                'The Home screen is your central command center for all '
                'things related to F.E.A.S.T. Here, you\'ll find a live '
                'feed of featured community aid requests and events, a '
                'community contributions tracker for our users, and all '
                'important announcements regarding the platform or the '
                'Almanza Dos community. This part of the app will serve '
                'as your main hub.',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 13,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 8),

            const FeastExpandableItem(
              title: 'Requests: Bridging the Gap',
              content: Text(
                'Learn how to submit, browse, and respond to community aid '
                'requests. This section helps connect donors with those in need.',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 13,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 8),

            const FeastExpandableItem(
              title: 'Events: Action & Engagement',
              content: Text(
                'Discover upcoming community events, register as a volunteer, '
                'or post your own charity event for the Almanza Dos community.',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 13,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 8),

            const FeastExpandableItem(
              title: 'Messages: Direct Communication',
              content: Text(
                'Use the Messages tab to communicate directly with donors, '
                'beneficiaries, or event organizers within the platform.',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 13,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 8),

            const FeastExpandableItem(
              title: 'Settings: Identity & Customization',
              content: Text(
                'Manage your profile, notification preferences, privacy settings, '
                'and other account customizations from the Settings screen.',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 13,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}