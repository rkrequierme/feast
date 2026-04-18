import 'package:flutter/material.dart';
import 'package:feast/core/core.dart';

class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({super.key});

  @override
  State<AboutUsScreen> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FeastAppBar(title: 'About Us'),
      drawer: const FeastDrawer(username: 'Juan De La Cruz'),
      bottomNavigationBar: const FeastBottomNav(currentIndex: -1),
      body: FeastBackground(
        child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Hero Section ──────────────────────────────────────────
            const FeastYellowSection(
              title: 'F.E.A.S.T. Charity\nManagement System',
              titleFontSize: 22,
            ),
            const SizedBox(height: 12),
            const FeastWhiteSection(
              child: Text(
                'F.E.A.S.T. stands for "Food, Emergency Aid, Support & '
                'Transparency" and is designed for the generous, hardworking, '
                'or in-need community members of Almanza Dos. It aims to '
                'simplify and monitor charity-related activities.',
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 20),

            // ── Our Mission ───────────────────────────────────────────
            const FeastYellowSection(title: 'Our Mission'),
            const SizedBox(height: 12),
            const FeastWhiteSection(
              child: Text(
                'To improve the quality of life in Barangay Almanza Dos by '
                'providing a streamlined, efficient, and transparent platform '
                'for charity management. We aim to bridge the gap between '
                'those who can give and those in need, ensuring that every '
                'community member is recognized for their efforts.',
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 20),

            // ── Our Vision ────────────────────────────────────────────
            const FeastYellowSection(title: 'Our Vision'),
            const SizedBox(height: 12),
            const FeastWhiteSection(
              child: Text(
                'To become the cornerstone of community solidarity in Almanza '
                'Dos, fostering a future where no neighbor is left behind and '
                'where the spirit of generosity is powered by innovation, '
                'trust, and seamless digital integration.',
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 20),

            // ── Our History & Core Values ─────────────────────────────
            const FeastYellowSection(
              title: 'Our History &\nCore Values',
              titleFontSize: 20,
            ),
            const SizedBox(height: 12),
            FeastWhiteSection(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  Text(
                    'Recognizing the need for a more organized approach to '
                    'local charity, students of FEU Alabang developed the '
                    'F.E.A.S.T. system to simplify the logistics of aid.',
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Our Core Values:',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'TitanOne',
                      fontSize: 15,
                      color: feastGreen,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Support. Transparency & Recognition',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
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
    );
  }
}
