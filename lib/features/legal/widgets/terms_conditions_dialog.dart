// lib/features/legal/widgets/terms_conditions_dialog.dart
//
// A popup version of the Terms & Conditions screen to be used
// during registration or password reset flows before login.

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feast/core/core.dart';

class TermsConditionsDialog extends StatelessWidget {
  const TermsConditionsDialog({super.key});

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
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      backgroundColor: feastLighterYellow,
      child: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('static_content')
            .doc('terms_conditions')
            .snapshots(),
        builder: (context, snap) {
          List<Map<String, String>> sections = List.from(_defaultSections);

          if (snap.hasData && snap.data!.exists) {
            final raw = snap.data!.data() as Map<String, dynamic>?;
            final adminSections =
                (raw?['sections'] as List?)?.cast<Map<String, dynamic>>();
            if (adminSections != null && adminSections.isNotEmpty) {
              sections = adminSections
                  .map((s) => {
                        'title': s['title'] as String? ?? '',
                        'body': s['body'] as String? ?? '',
                      })
                  .toList();
            }
          }

          return Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Terms & Conditions',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: feastBlack,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.black54),
                      onPressed: () => Navigator.of(context).pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Effective Date: February 11, 2026',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 12,
                          color: feastGray,
                        ),
                      ),
                      const Divider(height: 24),
                      const Text(
                        'Welcome to the F.E.A.S.T. Charity Management System. By using this platform, you agree to abide by the following terms and conditions designed to keep the Almanza Dos community safe and supportive while promoting equity.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 13,
                          color: feastGray,
                          height: 1.5,
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
                    ],
                  ),
                ),
              ),
              
              // Footer Action
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: feastGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      'I Understand',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Outfit',
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
