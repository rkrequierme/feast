import 'package:flutter/material.dart';
import 'package:feast/core/core.dart';

class SelectedAidRequestScreen extends StatefulWidget {
  const SelectedAidRequestScreen({super.key});

  @override
  State<SelectedAidRequestScreen> createState() =>
      _SelectedAidRequestScreenState();
}

class _SelectedAidRequestScreenState extends State<SelectedAidRequestScreen> {
  bool _isBookmarked = true;

  // ─── Placeholder data (replace with real data from Firebase) ───
  final Map<String, dynamic> _request = {
    'title': 'Surgery Meds & Treatment',
    'beneficiary': 'Jacob Vasquez',
    'category': 'Health\n(Support & Supply)',
    'location': 'DBP Village, Almanza Dos',
    'timeRemaining': '7 Days Left',
    'description':
        'Your generous contribution can provide life-saving '
        'surgery and essential post-operative care for a Filipino '
        'patient in urgent need. Your kindness provides more '
        'than just medical treatment. It offers a path toward '
        'health and stability, allowing my son to live a healthy '
        'and fulfilling life. He has so much left to live for...',
    'goalPercent': 20,
    'goalAmount': '₱5,000',
    'donors': 5,
    'fundsDonated': '₱1,000',
    'itemsDonated': 3,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FeastAppBar(title: 'Aid Requests'),
      drawer: const FeastDrawer(username: 'Juan De La Cruz'),
      body: FeastBackground(
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // ─── Hero Image Section ───
                _buildHeroImage(),

                // ─── Content Card ───
                _buildContentCard(),

                const SizedBox(height: 20),

                // ─── Stats Row ───
                _buildStatsRow(),

                const SizedBox(height: 24),

                // ─── Action Buttons ───
                _buildActionButtons(),

                const SizedBox(height: 16),

                // ─── Bookmark Badge ───
                if (_isBookmarked) _buildBookmarkBadge(),

                const SizedBox(height: 100), // Space for nav bar
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const FeastBottomNav(currentIndex: 1),
    );
  }

  // ═══════════════════════════════════════════════════
  // ─── HERO IMAGE ───
  // ═══════════════════════════════════════════════════
  Widget _buildHeroImage() {
    return SizedBox(
      height: 220,
      width: double.infinity,
      child: Stack(
        children: [
          // Hero image placeholder
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    feastLightGreen.withAlpha(180),
                    feastLighterBlue.withAlpha(150),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // Decorative background icons
                  Positioned(
                    top: 30,
                    left: 30,
                    child: Icon(
                      Icons.medical_services_outlined,
                      size: 80,
                      color: Colors.white.withAlpha(60),
                    ),
                  ),
                  Positioned(
                    bottom: 50,
                    right: 40,
                    child: Icon(
                      Icons.favorite_outline,
                      size: 60,
                      color: Colors.white.withAlpha(50),
                    ),
                  ),
                  // Central placeholder
                  Center(
                    child: Container(
                      width: 120,
                      height: 140,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(40),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.person_outline,
                        size: 64,
                        color: Colors.white.withAlpha(150),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ─── Top Action Bar ───
          Positioned(
            top: 8,
            left: 8,
            right: 8,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back button
                _buildCircleButton(
                  icon: Icons.arrow_back,
                  onTap: () => Navigator.pop(context),
                ),
                Row(
                  children: [
                    // Report button
                    _buildCircleButton(
                      icon: Icons.warning_amber_rounded,
                      iconColor: Colors.red,
                      onTap: () {
                        // Report action
                      },
                    ),
                    const SizedBox(width: 8),
                    // Bookmark button
                    _buildCircleButton(
                      icon: _isBookmarked
                          ? Icons.bookmark
                          : Icons.bookmark_border,
                      iconColor: feastGreen,
                      onTap: () {
                        setState(() => _isBookmarked = !_isBookmarked);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  // ─── CONTENT CARD ───
  // ═══════════════════════════════════════════════════
  Widget _buildContentCard() {
    return Transform.translate(
      offset: const Offset(0, -30),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Title + Beneficiary Row ───
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title & Meta
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _request['title'] as String,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Outfit',
                          color: feastBlack,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildMetaRow(
                        Icons.category_outlined,
                        'Request Category: ',
                        _request['category'] as String,
                      ),
                      _buildMetaRow(
                        Icons.location_on_outlined,
                        'Location: ',
                        _request['location'] as String,
                      ),
                      _buildMetaRow(
                        Icons.access_time,
                        'Time Remaining: ',
                        _request['timeRemaining'] as String,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Beneficiary avatar section
                Column(
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      'Beneficiary:',
                      style: TextStyle(
                        fontSize: 10,
                        fontFamily: 'Outfit',
                        fontWeight: FontWeight.w500,
                        color: feastGray.withAlpha(180),
                      ),
                    ),
                    const SizedBox(height: 6),
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: feastLightGreen,
                      child: const Icon(
                        Icons.person,
                        size: 28,
                        color: feastGreen,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _request['beneficiary'] as String,
                      style: const TextStyle(
                        fontSize: 10,
                        fontFamily: 'Outfit',
                        fontWeight: FontWeight.w600,
                        color: feastBlack,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ─── Divider ───
            Container(
              height: 1,
              color: feastLightGreen.withAlpha(100),
            ),

            const SizedBox(height: 14),

            // ─── Description ───
            Text(
              _request['description'] as String,
              style: TextStyle(
                fontSize: 12,
                fontFamily: 'Outfit',
                color: feastGray.withAlpha(220),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  // ─── STATS ROW ───
  // ═══════════════════════════════════════════════════
  Widget _buildStatsRow() {
    return Transform.translate(
      offset: const Offset(0, -20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatItem(
              icon: Icons.pie_chart_outline,
              value: '${_request['goalPercent']}%',
              label: 'Goal:\n${_request['goalAmount']}',
              iconColor: feastGreen,
            ),
            _buildStatItem(
              icon: Icons.people_outline,
              value: '${_request['donors']}',
              label: 'Donors',
              iconColor: feastGreen,
            ),
            _buildStatItem(
              icon: Icons.attach_money,
              value: _request['fundsDonated'] as String,
              label: 'Donated',
              iconColor: feastGreen,
            ),
            _buildStatItem(
              icon: Icons.inventory_2_outlined,
              value: '${_request['itemsDonated']} Items',
              label: 'Donated',
              iconColor: feastGreen,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color iconColor,
  }) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: feastLightGreen.withAlpha(80),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 24, color: iconColor),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontFamily: 'Outfit',
            fontWeight: FontWeight.bold,
            color: feastBlack,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontFamily: 'Outfit',
            fontWeight: FontWeight.w500,
            color: feastGray.withAlpha(180),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════
  // ─── ACTION BUTTONS ───
  // ═══════════════════════════════════════════════════
  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          // GIVE ITEMS button
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                // Give items action
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: feastGreen,
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                'GIVE ITEMS',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // DONATE FUNDS button
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                // Donate funds action
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: feastGreen, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                'DONATE FUNDS',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.bold,
                  color: feastGreen,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  // ─── BOOKMARK BADGE ───
  // ═══════════════════════════════════════════════════
  Widget _buildBookmarkBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: BoxDecoration(
        color: feastLightYellow,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: feastOrange.withAlpha(80), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bookmark, color: feastOrange, size: 16),
          const SizedBox(width: 6),
          const Text(
            'Saved To Bookmarks.',
            style: TextStyle(
              fontSize: 13,
              fontFamily: 'Outfit',
              fontWeight: FontWeight.w600,
              color: feastGreen,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  // ─── HELPER WIDGETS ───
  // ═══════════════════════════════════════════════════
  Widget _buildCircleButton({
    required IconData icon,
    Color? iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(220),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 6,
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 20,
          color: iconColor ?? feastBlack,
        ),
      ),
    );
  }

  Widget _buildMetaRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: feastGreen),
          const SizedBox(width: 6),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 11,
                  fontFamily: 'Outfit',
                  color: feastBlack,
                ),
                children: [
                  TextSpan(
                    text: label,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(
                    text: value,
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      color: feastGray.withAlpha(220),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
