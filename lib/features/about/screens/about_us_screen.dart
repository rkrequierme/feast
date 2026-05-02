// lib/features/about/screens/about_us_screen.dart
//
// About Us screen displaying F.E.A.S.T. mission, vision, and history.
// Content is editable by admins via Firestore static_content collection.

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feast/core/core.dart';

class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({super.key});

  @override
  State<AboutUsScreen> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  String _username = 'User';

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
      appBar: FeastAppBar(title: 'About Us', username: _username),
      drawer: FeastDrawer(username: _username),
      bottomNavigationBar: const FeastBottomNav(currentIndex: -1),
      body: FeastBackground(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('static_content')
              .doc('about_us')
              .snapshots(),
          builder: (context, snap) {
            final raw = snap.data?.data() as Map<String, dynamic>? ?? {};
            
            final mission = raw['mission'] as String? ?? 
                'To improve the quality of life in Barangay Almanza Dos by providing a streamlined, efficient, and transparent platform for charity management. We aim to bridge the gap between those who can give and those in need, ensuring that every community member is recognized for their efforts.';
            
            final vision = raw['vision'] as String? ??
                'To become the cornerstone of community solidarity in Almanza Dos, fostering a future where no neighbor is left behind and where the spirit of generosity is powered by innovation, trust, and seamless digital integration.';
            
            final history = raw['history'] as String? ??
                'Recognizing the need for a more organized approach to local charity, students of FEU Alabang developed the F.E.A.S.T. system to simplify the logistics of aid. F.E.A.S.T. stands for "Food, Emergency Aid, Support & Transparency" and is designed for the generous, hardworking, or in-need community members of Almanza Dos.';

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const FeastYellowSection(
                          title: 'F.E.A.S.T. Charity\nManagement System',
                          titleFontSize: 24,
                        ),
                        const SizedBox(height: 20),
                        FeastWhiteSection(
                          child: const Text(
                            'F.E.A.S.T. stands for "Food, Emergency Aid, Support & Transparency" and is designed for the generous, hardworking, or in-need community members of Almanza Dos. It aims to simplify and monitor charity-related activities.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 16,
                              color: feastGray,
                              height: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const FeastYellowSection(title: 'Our Mission'),
                        const SizedBox(height: 20),
                        FeastWhiteSection(
                          child: Text(
                            mission,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 16,
                              color: feastGray,
                              height: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const FeastYellowSection(title: 'Our Vision'),
                        const SizedBox(height: 20),
                        FeastWhiteSection(
                          child: Text(
                            vision,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 16,
                              color: feastGray,
                              height: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const FeastYellowSection(
                          title: 'Our History &\nCore Values',
                          titleFontSize: 24,
                        ),
                        const SizedBox(height: 20),
                        FeastWhiteSection(
                          child: Column(
                            children: [
                              Text(
                                history,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 16,
                                  color: feastGray,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: feastLightGreen.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: feastLightGreen.withOpacity(0.3),
                                  ),
                                ),
                                child: Column(
                                  children: const [
                                    Text(
                                      'Our Core Values',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'TitanOne',
                                        fontSize: 20,
                                        color: feastGreen,
                                      ),
                                    ),
                                    SizedBox(height: 40),
                                    Wrap(
                                      alignment: WrapAlignment.center,
                                      spacing: 16,
                                      runSpacing: 8,
                                      children: [
                                        _CoreValueChip(
                                          icon: Icons.support_agent,
                                          label: 'Support',
                                          color: feastGreen,
                                        ),
                                        _CoreValueChip(
                                          icon: Icons.visibility,
                                          label: 'Transparency',
                                          color: feastBlue,
                                        ),
                                        _CoreValueChip(
                                          icon: Icons.emoji_events,
                                          label: 'Recognition',
                                          color: feastOrange,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 80),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CoreValueChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _CoreValueChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
