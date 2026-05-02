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

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      FeastToast.showSuccess(context, 'Phone number copied to clipboard!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FeastAppBar(title: 'Contact Us', username: _username),
      drawer: FeastDrawer(username: _username),
      bottomNavigationBar: const FeastBottomNav(currentIndex: -1),
      body: FeastBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(), // Prevents overscroll glow on Android
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const FeastTagline(
                        'Contact Us',
                        fontSize: 32,
                        textColor: Colors.white,
                        strokeColor: feastGreen,
                        strokeWidth: 10,
                        fontFamily: 'TitanOne',
                      ),
                      const SizedBox(height: 20),
                      
                      FeastWhiteSection(
                        child: const Text(
                          "Don't hesitate to contact us whether you have a suggestion on our improvement, a complaint to discuss, or an issue to solve.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 16,
                            color: feastGray,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Call Us
                      _ContactCard(
                        icon: Icons.phone_in_talk_outlined,
                        color: feastGreen,
                        title: 'Call Us',
                        detail: '(02) 8268-8338',
                        subtitle: 'Mon–Fri · 9AM–5PM',
                        onTap: () => _copyToClipboard('(02) 8268-8338'),
                      ),
                      const SizedBox(height: 16),

                      // Email Us
                      _ContactCard(
                        icon: Icons.email_outlined,
                        color: feastOrange,
                        title: 'Email Us',
                        detail: 'pbl.gpc@gmail.com',
                        subtitle: 'Mon–Fri · 9AM–5PM',
                        onTap: () => _launchUrl('https://mail.google.com/'),
                      ),
                      const SizedBox(height: 16),

                      // Facebook
                      _ContactCard(
                        icon: Icons.facebook,
                        color: feastBlue,
                        title: 'Facebook',
                        detail: "Barangay's Official Page",
                        subtitle: 'Follow us for updates',
                        onTap: () => _launchUrl('https://www.facebook.com/BarangayAlmanzaDos/'),
                      ),
                      const SizedBox(height: 16),

                      // Location
                      _ContactCard(
                        icon: Icons.location_on_outlined,
                        color: feastLogTitle,
                        title: 'Location',
                        detail: 'Almanza Dos, Las Piñas City',
                        subtitle: 'View on Google Maps',
                        onTap: () => _launchUrl('https://www.google.com/maps/place/Almanza+Dos,+Las+Pi%C3%B1as,+Metro+Manila/data=!4m2!3m1!1s0x3397d198266f40bd:0x18e8a0012abb85d8?sa=X&ved=1t:242&ictx=111'),
                      ),
                      
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String detail;
  final String subtitle;
  final VoidCallback onTap;

  const _ContactCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.detail,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: feastBlack,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
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
}
