import 'package:flutter/material.dart';
import 'package:feast/core/core.dart';

class SelectedCharityEventScreen extends StatefulWidget {
  const SelectedCharityEventScreen({super.key});

  @override
  State<SelectedCharityEventScreen> createState() =>
      _SelectedCharityEventScreenState();
}

class _SelectedCharityEventScreenState
    extends State<SelectedCharityEventScreen> {
  bool _isBookmarked = false;

  // ─── Placeholder data (replace with real data from Firebase) ───
  final Map<String, dynamic> _event = {
    'title': 'Flood Relief Project',
    'collaborators': [
      'Juan De La Cruz',
      'Jorge De Guzman',
      'Jake Sy',
    ],
    'category': 'Disaster Management\n(Support & Supply)',
    'location': 'BF Almanza, Almanza Dos',
    'duration': 'Not Yet Started',
    'durationDetail': '9:00 AM – 5:00 PM (Feb 28, 2026)',
    'isNotYetStarted': true,
    'description':
        'Helping Filipino families get back on their feet by '
        'delivering food and essential supplies to flooded areas. '
        'By delivering consistent access to nutritious food, clean '
        'drinking water, and essential hygiene kits, we aim to '
        'alleviate the immediate burdens of displacement and '
        'hunger while restoring a sense of dignity and hope.',
    'progressPercent': 0,
    'participants': '13 / 20',
    'fundsDonated': '₱0',
    'itemsDonated': 0,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FeastAppBar(title: 'Charity Events'),
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

                const SizedBox(height: 100), // Space for nav bar
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const FeastBottomNav(currentIndex: 2),
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
                    feastLighterBlue.withAlpha(180),
                    feastLightGreen.withAlpha(150),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // Decorative background icons
                  Positioned(
                    top: 30,
                    left: 20,
                    child: Icon(
                      Icons.flood_outlined,
                      size: 80,
                      color: Colors.white.withAlpha(60),
                    ),
                  ),
                  Positioned(
                    bottom: 50,
                    right: 30,
                    child: Icon(
                      Icons.volunteer_activism,
                      size: 60,
                      color: Colors.white.withAlpha(50),
                    ),
                  ),
                  // Central placeholder
                  Center(
                    child: Container(
                      width: 160,
                      height: 140,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(40),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.groups_outlined,
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
    final collaborators = _event['collaborators'] as List<String>;

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
            // ─── Title + Collaborators Row ───
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title & Meta
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _event['title'] as String,
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
                        'Event Category: ',
                        _event['category'] as String,
                      ),
                      _buildMetaRow(
                        Icons.location_on_outlined,
                        'Location: ',
                        _event['location'] as String,
                      ),
                      _buildMetaRow(
                        Icons.schedule,
                        'Duration: ',
                        _event['duration'] as String,
                        valueColor: (_event['isNotYetStarted'] as bool)
                            ? feastOrange
                            : null,
                      ),
                      if (_event['durationDetail'] != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: Text(
                            _event['durationDetail'] as String,
                            style: TextStyle(
                              fontSize: 10,
                              fontFamily: 'Outfit',
                              color: feastGray.withAlpha(180),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                // Collaborators section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      'Main Collaborators:',
                      style: TextStyle(
                        fontSize: 10,
                        fontFamily: 'Outfit',
                        fontWeight: FontWeight.w500,
                        color: feastGray.withAlpha(180),
                      ),
                    ),
                    const SizedBox(height: 6),
                    ...collaborators.map(
                      (name) => Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 9,
                              backgroundColor: feastLightGreen,
                              child: const Icon(
                                Icons.person,
                                size: 10,
                                color: feastGreen,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              name,
                              style: const TextStyle(
                                fontSize: 10,
                                fontFamily: 'Outfit',
                                fontWeight: FontWeight.w600,
                                color: feastBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
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
              _event['description'] as String,
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
    final isNotYetStarted = _event['isNotYetStarted'] as bool;

    return Transform.translate(
      offset: const Offset(0, -20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatItem(
              icon: Icons.pie_chart_outline,
              value: '${_event['progressPercent']}%',
              label: isNotYetStarted ? 'Not Yet\nStarted!' : 'Progress',
              iconColor: feastGreen,
              labelColor: isNotYetStarted ? feastOrange : null,
            ),
            _buildStatItem(
              icon: Icons.people_outline,
              value: _event['participants'] as String,
              label: 'Participants',
              iconColor: feastGreen,
            ),
            _buildStatItem(
              icon: Icons.attach_money,
              value: _event['fundsDonated'] as String,
              label: 'Donated',
              iconColor: feastGreen,
            ),
            _buildStatItem(
              icon: Icons.inventory_2_outlined,
              value: '${_event['itemsDonated']} Items',
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
    Color? labelColor,
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
            color: labelColor ?? feastGray.withAlpha(180),
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
          // JOIN US button
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                // Join event action
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
                'JOIN US',
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

  Widget _buildMetaRow(IconData icon, String label, String value,
      {Color? valueColor}) {
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
                      color: valueColor ?? feastGray.withAlpha(220),
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
