// lib/features/legal/screens/terms_conditions_screen.dart
//
// Terms & Conditions screen with expandable sections.
// Content is editable by admins via Firestore static_content collection.

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feast/core/core.dart';

class TermsConditionsScreen extends StatefulWidget {
  const TermsConditionsScreen({super.key});

  @override
  State<TermsConditionsScreen> createState() => _TermsConditionsScreenState();
}

class _TermsConditionsScreenState extends State<TermsConditionsScreen> {
  String _username = 'User';

  static const _defaultSections = [
    {
      'title': 'User Eligibility & Conduct',
      'icon': Icons.verified_user_outlined,
      'body':
          'Community First: Users must be residents or verified stakeholders of Almanza Dos.\n\nRespectful Interaction: Harassment, hate speech, or any form of discrimination is strictly prohibited.\n\nAuthenticity: You agree to provide accurate information when creating your profile and making community aid requests.',
    },
    {
      'title': 'Data Privacy & Security',
      'icon': Icons.privacy_tip_outlined,
      'body':
          'Your personal data is collected solely to facilitate community aid activities. We do not sell or share your information with third parties without your consent.',
    },
    {
      'title': 'Termination of Service',
      'icon': Icons.warning_amber_outlined,
      'body':
          'Accounts found violating community guidelines may be suspended or permanently removed without prior notice.',
    },
    {
      'title': 'Prohibited Activities',
      'icon': Icons.block_outlined,
      'body':
          'Users must not use the platform for commercial solicitation, spreading misinformation, or any activity that undermines community trust and safety.',
    },
    {
      'title': 'Reporting & Dispute Resolution',
      'icon': Icons.flag_outlined,
      'body':
          'Users are encouraged to report suspicious activity via the Help & FAQ screen. All disputes will be reviewed by the barangay moderation team.',
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
      appBar: FeastAppBar(title: 'Terms & Conditions', username: _username),
      drawer: FeastDrawer(username: _username),
      bottomNavigationBar: const FeastBottomNav(currentIndex: -1),
      body: FeastBackground(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('static_content')
              .doc('terms_conditions')
              .snapshots(),
          builder: (context, snap) {
            List<Map<String, dynamic>> sections = List.from(_defaultSections);

            if (snap.hasData && snap.data!.exists) {
              final raw = snap.data!.data() as Map<String, dynamic>?;
              final adminSections = (raw?['sections'] as List?)?.cast<Map<String, dynamic>>();
              if (adminSections != null && adminSections.isNotEmpty) {
                sections = adminSections
                    .map((s) => {
                          'title': s['title'] as String? ?? '',
                          'icon': Icons.description_outlined,
                          'body': s['body'] as String? ?? '',
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
                              Icon(Icons.gavel, size: 48, color: feastGreen),
                              SizedBox(height: 12),
                              Text(
                                'Terms & Conditions',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Outfit',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: feastBlack,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Effective Date: February 11, 2026',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 16,
                                  color: feastGray,
                                ),
                              ),
                              Divider(height: 24),
                              Text(
                                'Welcome to the F.E.A.S.T. Charity Management System. By using this platform, you agree to abide by the following terms and conditions designed to keep the Almanza Dos community safe and supportive while promoting equity.',
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
                        const FeastYellowSection(title: 'Terms & Conditions'),
                      ],
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final section = sections[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        child: FeastExpandableItem(
                          title: section['title'] ?? '',
                          icon: section['icon'] as IconData?,
                          initiallyExpanded: index == 0,
                          content: Text(
                            section['body'] ?? '',
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
                    childCount: sections.length,
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
