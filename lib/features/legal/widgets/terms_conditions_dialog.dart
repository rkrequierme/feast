// lib/features/legal/widgets/terms_conditions_dialog.dart
//
// A popup version of the Terms & Conditions screen to be used
// during registration or password reset flows before login.

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feast/core/core.dart';

class TermsConditionsDialog extends StatelessWidget {
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;

  const TermsConditionsDialog({
    super.key, 
    this.onAccept,
    this.onDecline,
  });

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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: feastLighterYellow,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header with gradient background
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 20, 16, 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          feastGreen,
                          feastDarkGreen,
                        ],
                      ),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.gavel,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Terms & Conditions',
                                  style: TextStyle(
                                    fontFamily: 'Outfit',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'Please read carefully',
                                  style: TextStyle(
                                    fontFamily: 'Outfit',
                                    fontSize: 11,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(), // Just close, no callback
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Content
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.6,
                      minHeight: 300,
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Effective date badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: feastLightYellow,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: feastOrange.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.calendar_today_outlined,
                                  size: 14,
                                  color: feastOrange,
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  'Effective Date: February 11, 2026',
                                  style: TextStyle(
                                    fontFamily: 'Outfit',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: feastOrange,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Welcome message
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: feastLightBlue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: feastLightBlue.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: 20,
                                  color: feastBlue,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Welcome to the F.E.A.S.T. Charity Management System. By using this platform, you agree to abide by the following terms and conditions.',
                                    style: TextStyle(
                                      fontFamily: 'Outfit',
                                      fontSize: 12,
                                      color: feastBlack.withOpacity(0.8),
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Section header
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: feastGreen.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.assignment_outlined,
                                  size: 16,
                                  color: feastGreen,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Full Terms & Conditions',
                                style: TextStyle(
                                  fontFamily: 'Outfit',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: feastBlack,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Expandable sections
                          ...sections.asMap().entries.map((entry) {
                            final sec = entry.value;
                            final isFirst = entry.key == 0;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: FeastExpandableItem(
                                title: sec['title'] ?? '',
                                initiallyExpanded: isFirst,
                                content: Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    sec['body'] ?? '',
                                    style: const TextStyle(
                                      fontFamily: 'Outfit',
                                      fontSize: 13,
                                      color: feastGray,
                                      height: 1.6,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),

                          const SizedBox(height: 8),

                          // Agreement note
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: feastLightGreen.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.favorite_outline,
                                  size: 16,
                                  color: feastGreen,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'By accepting, you confirm that you have read and agree to all the terms above.',
                                    style: TextStyle(
                                      fontFamily: 'Outfit',
                                      fontSize: 11,
                                      color: feastGreen.withOpacity(0.8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Footer Action
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(24),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              onDecline?.call(); // Only Decline button unchecks
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: feastGray,
                              side: BorderSide(color: feastGray.withOpacity(0.3)),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Decline',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Outfit',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              onAccept?.call(); // Accept checks the checkbox
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: feastGreen,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'I Understand',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Outfit',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
