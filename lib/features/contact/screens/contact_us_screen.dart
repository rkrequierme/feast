import 'package:flutter/material.dart';
import 'package:feast/core/core.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FeastAppBar(title: 'Contact Us'),
      drawer: const FeastDrawer(username: 'Juan De La Cruz'),
      bottomNavigationBar: const FeastBottomNav(currentIndex: -1),
      body: FeastBackground(
        child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Hero Tagline ──────────────────────────────────────────
            FeastTagline(
              'Feel Free To\nReach Out',
              fontSize: 28,
              textColor: Colors.white,
              strokeColor: feastGreen,
              strokeWidth: 12,
            ),

            const SizedBox(height: 16),

            // ── Subtitle ──────────────────────────────────────────────
            const Text(
              "Don't hesitate to contact us whether you have a suggestion "
              "on our improvement, a complain to discuss or an issue to solve.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 14,
                color: Colors.black87,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 20),

            // ── Call Us / Email Us row ────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: FeastWhiteSection(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ContactIconBox(
                          icon: Icons.phone,
                          backgroundColor: Colors.black,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Call Us',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '(02) 8268.8338',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 12,
                            color: Colors.black87,
                          ),
                        ),
                        const Text(
                          'Mon-Fri · 9AM-5 PM',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FeastWhiteSection(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ContactIconBox(
                          icon: Icons.mail,
                          backgroundColor: Colors.black,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Email Us',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'pbl.gpc@gmail.com',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 12,
                            color: Colors.black87,
                          ),
                        ),
                        const Text(
                          'Mon-Fri · 9AM-5 PM',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ── Facebook ──────────────────────────────────────────────
            FeastWhiteSection(
              child: Row(
                children: [
                  _ContactIconBox(
                    icon: Icons.facebook,
                    backgroundColor: const Color(0xFF1877F2),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Facebook',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          "Barangay's Official Page",
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _ActionIconButton(
                    icon: Icons.share,
                    color: feastGreen,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Location ──────────────────────────────────────────────
            FeastWhiteSection(
              child: Row(
                children: [
                  _ContactIconBox(
                    icon: Icons.location_city,
                    backgroundColor: Colors.black87,
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Location',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          'Almanza Dos, Las Piñas City',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _ActionIconButton(
                    icon: Icons.location_on,
                    color: const Color(0xFF4285F4),
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

// ── Private helper widgets ─────────────────────────────────────────────────────

/// Square icon box used for Call Us, Email Us, Facebook, Location.
class _ContactIconBox extends StatelessWidget {
  final IconData icon;
  final Color backgroundColor;

  const _ContactIconBox({
    required this.icon,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 24,
      ),
    );
  }
}

/// Circular action button used for Facebook (share) and Location (pin).
class _ActionIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _ActionIconButton({
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 20,
      ),
    );
  }
}