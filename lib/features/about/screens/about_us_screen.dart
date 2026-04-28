// lib/features/about/screens/about_us_screen.dart
//
// About Us screen displaying F.E.A.S.T. mission, vision, and history.
// Content is editable by admins via Firestore static_content collection.
//
// REACT.JS INTEGRATION NOTE:
// =========================
// Collection: static_content
// Document: about_us
// Fields: mission (String), vision (String), history (String)
// React query:
//   const docRef = doc(db, 'static_content', 'about_us');
//   const docSnap = await getDoc(docRef);
//   const { mission, vision, history } = docSnap.data();

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feast/core/core.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FeastAppBar(title: 'About Us'),
      drawer: const FeastDrawer(username: ''),
      bottomNavigationBar: const FeastBottomNav(currentIndex: -1),
      body: FeastBackground(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('static_content')
              .doc('about_us')
              .snapshots(),
          builder: (context, snap) {
            final raw = snap.data?.data() as Map<String, dynamic>? ?? {};
            
            // Default content if admin hasn't edited yet
            final mission = raw['mission'] as String? ?? 
                'To improve the quality of life in Barangay Almanza Dos by providing a streamlined, efficient, and transparent platform for charity management. We aim to bridge the gap between those who can give and those in need, ensuring that every community member is recognized for their efforts.';
            
            final vision = raw['vision'] as String? ??
                'To become the cornerstone of community solidarity in Almanza Dos, fostering a future where no neighbor is left behind and where the spirit of generosity is powered by innovation, trust, and seamless digital integration.';
            
            final history = raw['history'] as String? ??
                'Recognizing the need for a more organized approach to local charity, students of FEU Alabang developed the F.E.A.S.T. system to simplify the logistics of aid. F.E.A.S.T. stands for "Food, Emergency Aid, Support & Transparency" and is designed for the generous, hardworking, or in-need community members of Almanza Dos.';

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const FeastYellowSection(
                    title: 'F.E.A.S.T. Charity\nManagement System',
                    titleFontSize: 22,
                  ),
                  const SizedBox(height: 12),
                  FeastWhiteSection(
                    child: const Text(
                      'F.E.A.S.T. stands for "Food, Emergency Aid, Support & Transparency" and is designed for the generous, hardworking, or in-need community members of Almanza Dos. It aims to simplify and monitor charity-related activities.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 13,
                        color: feastGray,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const FeastYellowSection(title: 'Our Mission'),
                  const SizedBox(height: 12),
                  FeastWhiteSection(
                    child: Text(
                      mission,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 13,
                        color: feastGray,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const FeastYellowSection(title: 'Our Vision'),
                  const SizedBox(height: 12),
                  FeastWhiteSection(
                    child: Text(
                      vision,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 13,
                        color: feastGray,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const FeastYellowSection(
                    title: 'Our History &\nCore Values',
                    titleFontSize: 20,
                  ),
                  const SizedBox(height: 12),
                  FeastWhiteSection(
                    child: Column(
                      children: [
                        Text(
                          history,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 13,
                            color: feastGray,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Our Core Values:',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'TitanOne',
                            fontSize: 15,
                            color: feastGreen,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Support · Transparency · Recognition',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
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
