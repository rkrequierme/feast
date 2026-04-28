// lib/features/contact/screens/contact_us_screen.dart
//
// Contact Us screen displaying phone, email, Facebook, and location.
// Uses url_launcher to open external apps.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:feast/core/core.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
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

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  void _copyToClipboard(BuildContext context, String number) {
    Clipboard.setData(ClipboardData(text: number));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Phone number copied to clipboard!',
          style: TextStyle(fontFamily: 'Outfit'),
        ),
        backgroundColor: feastGreen,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FeastAppBar(title: 'Contact Us', username: _username),
      drawer: FeastDrawer(username: _username),
      bottomNavigationBar: const FeastBottomNav(currentIndex: -1),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [feastLighterBlue, feastLighterYellow],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header with FeastTagline
                const FeastTagline(
                  'Contact Us',
                  fontSize: 32,
                  textColor: Colors.white,
                  strokeColor: feastGreen,
                  strokeWidth: 10,
                ),
                const SizedBox(height: 20),
                
                // Description
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "Don't hesitate to contact us whether you have a suggestion on our improvement, a complaint to discuss, or an issue to solve.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 14,
                      color: feastGray,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Call Us - Copies to clipboard
                _buildContactCard(
                  icon: Icons.phone,
                  color: feastGreen,
                  title: 'Call Us',
                  detail: '(02) 8268-8338',
                  hours: 'Mon–Fri · 9AM–5PM',
                  onTap: () => _copyToClipboard(context, '(02) 8268-8338'),
                ),
                const SizedBox(height: 16),

                // Email Us - Opens Gmail
                _buildContactCard(
                  icon: Icons.email,
                  color: feastBlue,
                  title: 'Email Us',
                  detail: 'pbl.gpc@gmail.com',
                  hours: 'Mon–Fri · 9AM–5PM',
                  onTap: () => _launchUrl('https://mail.google.com/'),
                ),
                const SizedBox(height: 16),

                // Facebook - Opens Facebook Page
                _buildSocialCard(
                  icon: Icons.facebook,
                  color: const Color(0xFF1877F2),
                  title: 'Facebook',
                  detail: "Barangay's Official Page",
                  onTap: () => _launchUrl('https://www.facebook.com/BarangayAlmanzaDos/'),
                ),
                const SizedBox(height: 16),

                // Location - Opens Google Maps
                _buildSocialCard(
                  icon: Icons.location_on,
                  color: const Color(0xFF4285F4),
                  title: 'Location',
                  detail: 'Almanza Dos, Las Piñas City',
                  onTap: () => _launchUrl('https://www.google.com/maps/place/Almanza+Dos,+Las+Pi%C3%B1as,+Metro+Manila/data=!4m2!3m1!1s0x3397d198266f40bd:0x18e8a0012abb85d8?sa=X&ved=1t:242&ictx=111'),
                ),
                
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required Color color,
    required String title,
    required String detail,
    required String hours,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                color: color.withAlpha(26),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: feastBlack,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    detail,
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: feastBlack,
                    ),
                  ),
                  Text(
                    hours,
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 12,
                      color: feastGray,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialCard({
    required IconData icon,
    required Color color,
    required String title,
    required String detail,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                color: color.withAlpha(26),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: feastBlack,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    detail,
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 14,
                      color: feastGray,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}
