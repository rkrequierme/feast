import 'package:flutter/material.dart';
import 'package:feast/core/core.dart';

class TermsConditionsScreen extends StatefulWidget {
  const TermsConditionsScreen({super.key});

  @override
  State<TermsConditionsScreen> createState() => _TermsConditionsScreenState();
}

class _TermsConditionsScreenState extends State<TermsConditionsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FeastAppBar(title: 'Terms & Conditions'),
      drawer: const FeastDrawer(username: 'Juan De La Cruz'),
      bottomNavigationBar: FeastBottomNav(currentIndex: -1),
      backgroundColor: feastLightYellow,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Hero Card ─────────────────────────────────────────────
            FeastWhiteSection(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  Text(
                    'Terms & Conditions',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Effective Date: February 11, 2026',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                  Divider(height: 24),
                  Text(
                    'Welcome to the F.E.A.S.T. Charity Management System. '
                    'By using this platform, you agree to abide by the '
                    'following terms and conditions designed to keep the '
                    'Almanza Dos community safe and supportive while '
                    'promoting equity.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 13,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Section Header ────────────────────────────────────────
            const FeastYellowSection(title: 'Full Description'),

            const SizedBox(height: 12),

            // ── Expandable Items ──────────────────────────────────────
            FeastExpandableItem(
              title: 'User Eligibility & Conduct',
              initiallyExpanded: true,
              content: const _RichParagraph(
                entries: [
                  _BoldEntry(
                    label: 'Community First:',
                    body: ' Users must be residents or verified stakeholders '
                        'of Almanza Dos.',
                  ),
                  _BoldEntry(
                    label: 'Respectful Interaction:',
                    body: ' Harassment, hate speech, or any form of '
                        'discrimination is strictly prohibited in requests, '
                        'events, and messages.',
                  ),
                  _BoldEntry(
                    label: 'Authenticity:',
                    body: ' You agree to provide accurate information when '
                        'creating your profile and making community aid '
                        'requests.',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            const FeastExpandableItem(
              title: 'Data Privacy & Security',
              content: Text(
                'Your personal data is collected solely to facilitate '
                'community aid activities. We do not sell or share your '
                'information with third parties without your consent.',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 13,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 8),

            const FeastExpandableItem(
              title: 'Termination of Service',
              content: Text(
                'Accounts found violating community guidelines may be '
                'suspended or permanently removed without prior notice.',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 13,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 8),

            const FeastExpandableItem(
              title: 'Prohibited Activities',
              content: Text(
                'Users must not use the platform for commercial solicitation, '
                'spreading misinformation, or any activity that undermines '
                'community trust and safety.',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 13,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 8),

            const FeastExpandableItem(
              title: 'Reporting & Dispute Resolution',
              content: Text(
                'Users are encouraged to report suspicious activity via the '
                'Help & FAQ screen. All disputes will be reviewed by the '
                'barangay moderation team.',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 13,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ── Private helper for bold-label + body inline text ──────────────────────────

class _BoldEntry {
  final String label;
  final String body;
  const _BoldEntry({required this.label, required this.body});
}

class _RichParagraph extends StatelessWidget {
  final List<_BoldEntry> entries;
  const _RichParagraph({required this.entries});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: entries.map((e) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 13,
                color: Colors.black87,
                height: 1.5,
              ),
              children: [
                TextSpan(
                  text: e.label,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                TextSpan(text: e.body),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}