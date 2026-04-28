// lib/features/legal/screens/terms_conditions_screen.dart
//
// Terms & Conditions screen with expandable sections.
// Content is editable by admins via Firestore static_content collection.
//
// REACT.JS INTEGRATION NOTE:
// =========================
// Collection: static_content
// Document: terms_conditions
// Fields: sections (Array of {title, body})
// React query:
//   const docRef = doc(db, 'static_content', 'terms_conditions');
//   const docSnap = await getDoc(docRef);
//   const sections = docSnap.data()?.sections || defaultSections;

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feast/core/core.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  static const _defaultSections = [
    {
      'title': 'User Eligibility & Conduct',
      'body':
          'Community First: Users must be residents or verified stakeholders of Almanza Dos.\n\nRespectful Interaction: Harassment, hate speech, or any form of discrimination is strictly prohibited.\n\nAuthenticity: You agree to provide accurate information when creating your profile and making community aid requests.',
    },
    {
      'title': 'Data Privacy & Security',
      'body':
          'Your personal data is collected solely to facilitate community aid activities. We do not sell or share your information with third parties without your consent.',
    },
    {
      'title': 'Termination of Service',
      'body':
          'Accounts found violating community guidelines may be suspended or permanently removed without prior notice.',
    },
    {
      'title': 'Prohibited Activities',
      'body':
          'Users must not use the platform for commercial solicitation, spreading misinformation, or any activity that undermines community trust and safety.',
    },
    {
      'title': 'Reporting & Dispute Resolution',
      'body':
          'Users are encouraged to report suspicious activity via the Help & FAQ screen. All disputes will be reviewed by the barangay moderation team.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FeastAppBar(title: 'Terms & Conditions'),
      drawer: const FeastDrawer(username: ''),
      bottomNavigationBar: const FeastBottomNav(currentIndex: -1),
      body: FeastBackground(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('static_content')
              .doc('terms_conditions')
              .snapshots(),
          builder: (context, snap) {
            List<Map<String, String>> sections = List.from(_defaultSections);

            if (snap.hasData && snap.data!.exists) {
              final raw = snap.data!.data() as Map<String, dynamic>?;
              final adminSections = (raw?['sections'] as List?)?.cast<Map<String, dynamic>>();
              if (adminSections != null && adminSections.isNotEmpty) {
                sections = adminSections
                    .map((s) => {
                          'title': s['title'] as String? ?? '',
                          'body': s['body'] as String? ?? '',
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
                          'Terms & Conditions',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Effective Date: February 11, 2026',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 12,
                            color: feastGray,
                          ),
                        ),
                        Divider(height: 24),
                        Text(
                          'Welcome to the F.E.A.S.T. Charity Management System. By using this platform, you agree to abide by the following terms and conditions designed to keep the Almanza Dos community safe and supportive while promoting equity.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 13,
                            color: feastGray,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const FeastYellowSection(title: 'Full Description'),
                  const SizedBox(height: 12),
                  ...sections.asMap().entries.map((entry) {
                    final sec = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: FeastExpandableItem(
                        title: sec['title'] ?? '',
                        initiallyExpanded: entry.key == 0,
                        content: Text(
                          sec['body'] ?? '',
                          style: const TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 13,
                            color: feastGray,
                            height: 1.5,
                          ),
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
