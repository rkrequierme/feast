// lib/features/contact/screens/contact_us_screen.dart
//
// Contact Us screen displaying phone, email, Facebook, and location.
// Uses url_launcher to open external apps.
//
// REACT.JS INTEGRATION NOTE:
// =========================
// In React, use anchor tags or window.open():
//   <a href="tel:+63282688338">Call Us</a>
//   <a href="mailto:pbl.gpc@gmail.com">Email Us</a>
//   <a href="https://www.facebook.com/BarangayAlmanzaDos" target="_blank">Facebook</a>
//   <a href="https://maps.google.com/?q=Almanza+Dos,+Las+Pinas+City" target="_blank">Location</a>

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:feast/core/core.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FeastAppBar(title: 'Contact Us'),
      drawer: const FeastDrawer(username: ''),
      bottomNavigationBar: const FeastBottomNav(currentIndex: -1),
      body: FeastBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const FeastTagline(
                'Feel Free To\nReach Out',
                fontSize: 28,
                textColor: Colors.white,
                strokeColor: feastGreen,
                strokeWidth: 12,
              ),
              const SizedBox(height: 16),
              const Text(
                "Don't hesitate to contact us whether you have a suggestion on our improvement, a complaint to discuss, or an issue to solve.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 13,
                  color: feastGray,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _contactCard(
                      icon: Icons.phone,
                      title: 'Call Us',
                      subtitle: '(02) 8268-8338',
                      hours: 'Mon–Fri · 9AM–5PM',
                      onTap: () => _launchUrl('tel:+63282688338'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _contactCard(
                      icon: Icons.mail,
                      title: 'Email Us',
                      subtitle: 'pbl.gpc@gmail.com',
                      hours: 'Mon–Fri · 9AM–5PM',
                      onTap: () => _launchUrl('mailto:pbl.gpc@gmail.com'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _rowCard(
                iconData: Icons.facebook,
                iconBg: const Color(0xFF1877F2),
                title: 'Facebook',
                subtitle: "Barangay's Official Page",
                actionIcon: Icons.share,
                actionColor: feastGreen,
                onActionTap: () => _launchUrl('https://www.facebook.com/BarangayAlmanzaDos'),
              ),
              const SizedBox(height: 12),
              _rowCard(
                iconData: Icons.location_city,
                iconBg: Colors.black87,
                title: 'Location',
                subtitle: 'Almanza Dos, Las Piñas City',
                actionIcon: Icons.location_on,
                actionColor: const Color(0xFF4285F4),
                onActionTap: () => _launchUrl('https://maps.google.com/?q=Almanza+Dos,+Las+Pinas+City'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _contactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String hours,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Outfit',
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontFamily: 'Outfit',
                fontSize: 12,
                color: feastBlack,
              ),
            ),
            Text(
              hours,
              style: const TextStyle(
                fontFamily: 'Outfit',
                fontSize: 11,
                color: feastGray,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _rowCard({
    required IconData iconData,
    required Color iconBg,
    required String title,
    required String subtitle,
    required IconData actionIcon,
    required Color actionColor,
    required VoidCallback onActionTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(iconData, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 12,
                    color: feastGray,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onActionTap,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: actionColor,
                shape: BoxShape.circle,
              ),
              child: Icon(actionIcon, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
