import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  bool _hasJoined = false;

  // ─── Placeholder data (replace with real data passed via Navigator args) ───
  final Map<String, dynamic> _event = {
    'id': 'event_001',
    'title': 'Flood Relief Project',
    'organizer': 'Jose De La Cruz',
    'collaborators': ['Ana De La Cruz', 'Juan Rodriguez & Family'],
    'category': 'Disaster Management\n(Support & Supply)',
    'location': 'BF Almanza, Almanza Dos',
    'duration': '5:00 PM | May 28, 2026',
    'isNotYetStarted': true,
    'description':
        'Help us help those flood-ravaged families. Providing food, '
        'medicine, and essential supplies to those in desperate need. '
        'Every volunteer and every donated item brings hope to a family '
        'that has lost almost everything. Join us and be part of something '
        'bigger than yourself — because together, we rise.',
    'participants': '11 / 20',
    'participantCount': 11,
    'participantMax': 20,
    'itemsDonated': 0,
    'goalPercent': 55,
    // Gradient colors used as hero placeholder (indices match CharityEventsScreen)
    'gradientStart': const Color(0xFF4FC3F7),
    'gradientEnd': const Color(0xFF0288D1),
    'heroIcon': Icons.flood_outlined,
    'shareLink': 'https://feast.app/events/event_001',
  };

  // ── Bookmark toggle ────────────────────────────────────────────────────────

  void _toggleBookmark() {
    setState(() => _isBookmarked = !_isBookmarked);

    if (_isBookmarked) {
      BookmarksRegistry.add(
        BookmarkListItem(
          id: _event['id'] as String,
          type: BookmarkType.event,
          title: _event['title'] as String,
          author: 'By: ${_event['organizer']}',
          category:
              'Category: ${(_event['category'] as String).replaceAll('\n', ' ')}',
          description: _event['description'] as String,
          shareLink: _event['shareLink'] as String?,
          onRemove: () {
            if (mounted) setState(() => _isBookmarked = false);
          },
        ),
      );
      _showSnackbar('Saved To Bookmarks.');
    } else {
      BookmarksRegistry.remove(_event['id'] as String);
      _showSnackbar('Removed from Bookmarks.');
    }
  }

  // ── Share ──────────────────────────────────────────────────────────────────

  Future<void> _handleShare() async {
    final link = _event['shareLink'] as String? ??
        'https://feast.app/events/${_event['id']}';
    await Clipboard.setData(ClipboardData(text: link));
    if (!mounted) return;
    _showSnackbar('Link Copied To Clipboard.');
  }

  // ── Report ─────────────────────────────────────────────────────────────────

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (_) => ReportContentDialog(
        title: _event['title'] as String,
        onConfirm: (reportTitle, reportDesc) {
          // TODO: submit report to Firestore
          _showSnackbar('Report submitted. Thank you.');
        },
      ),
    );
  }

  // ── Join Event flow ────────────────────────────────────────────────────────

  void _showJoinEventDialog() {
    showDialog(
      context: context,
      builder: (_) => JoinEventDialog(
        eventTitle: _event['title'] as String,
        onConfirm: () {
          setState(() => _hasJoined = true);
          // TODO: write to Firestore:
          // FirebaseFirestore.instance
          //   .doc('events/${_event['id']}/participants/$uid')
          //   .set({...});
          _showSnackbar("You've joined ${_event['title']}!");
        },
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Outfit',
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        backgroundColor: Colors.black87,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

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
                _buildHeroImage(),
                _buildContentCard(),
                const SizedBox(height: 20),
                _buildStatsRow(),
                const SizedBox(height: 24),
                _buildActionButtons(),
                const SizedBox(height: 16),
                if (_isBookmarked) _buildBookmarkBadge(),
                if (_hasJoined) ...[
                  const SizedBox(height: 8),
                  _buildJoinedBadge(),
                ],
                const SizedBox(height: 100),
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
          // ── Gradient background ──
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _event['gradientStart'] as Color,
                    _event['gradientEnd'] as Color,
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
                      _event['heroIcon'] as IconData,
                      size: 80,
                      color: Colors.white.withAlpha(60),
                    ),
                  ),
                  Positioned(
                    bottom: 50,
                    right: 40,
                    child: Icon(
                      Icons.volunteer_activism_outlined,
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

          // ── Top Action Bar ──
          Positioned(
            top: 8,
            left: 8,
            right: 8,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCircleButton(
                  icon: Icons.arrow_back,
                  onTap: () => Navigator.pop(context),
                ),
                Row(
                  children: [
                    _buildCircleButton(
                      icon: Icons.warning_amber_rounded,
                      iconColor: Colors.red,
                      onTap: _showReportDialog,
                    ),
                    const SizedBox(width: 8),
                    _buildCircleButton(
                      icon: Icons.share,
                      iconColor: feastGreen,
                      onTap: _handleShare,
                    ),
                    const SizedBox(width: 8),
                    _buildCircleButton(
                      icon: _isBookmarked
                          ? Icons.bookmark
                          : Icons.bookmark_border,
                      iconColor: feastGreen,
                      onTap: _toggleBookmark,
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
    final collaborators =
        _event['collaborators'] as List<String>;

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
            // ── Title + Organizer Row ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                      _buildMetaRow(
                        Icons.people_outline,
                        'Participants: ',
                        _event['participants'] as String,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Organizer avatar
                Column(
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      'Organizer:',
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
                      backgroundColor: feastLighterBlue,
                      child: const Icon(
                        Icons.person,
                        size: 28,
                        color: feastBlue,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _event['organizer'] as String,
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

            const SizedBox(height: 12),

            // ── Collaborators ──
            if (collaborators.isNotEmpty) ...[
              Text(
                'Collaborators:',
                style: TextStyle(
                  fontSize: 11,
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.w600,
                  color: feastGray.withAlpha(200),
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: collaborators.map((name) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 10,
                        backgroundColor: feastLightGreen,
                        child: const Icon(
                          Icons.person,
                          size: 12,
                          color: feastGreen,
                        ),
                      ),
                      const SizedBox(width: 4),
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
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
            ],

            // ── Divider ──
            Container(height: 1, color: feastLightGreen.withAlpha(100)),
            const SizedBox(height: 14),

            // ── Description ──
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
    final participantCount = _event['participantCount'] as int;
    final participantMax = _event['participantMax'] as int;
    final fillPercent =
        (participantCount / participantMax).clamp(0.0, 1.0);

    return Transform.translate(
      offset: const Offset(0, -20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatItem(
              icon: Icons.pie_chart_outline,
              value: '${(fillPercent * 100).round()}%',
              label: 'Filled\n($participantCount/$participantMax)',
              iconColor: feastGreen,
            ),
            _buildStatItem(
              icon: Icons.people_outline,
              value: '$participantCount',
              label: 'Joined',
              iconColor: feastGreen,
            ),
            _buildStatItem(
              icon: Icons.event_available_outlined,
              value: (_event['isNotYetStarted'] as bool)
                  ? 'Soon'
                  : 'Active',
              label: 'Status',
              iconColor: (_event['isNotYetStarted'] as bool)
                  ? feastOrange
                  : feastGreen,
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
          style: TextStyle(
            fontSize: 12,
            fontFamily: 'Outfit',
            fontWeight: FontWeight.bold,
            color: iconColor == feastOrange ? feastOrange : feastBlack,
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
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _hasJoined ? null : _showJoinEventDialog,
          icon: Icon(
            _hasJoined
                ? Icons.check_circle_outline
                : Icons.group_add_outlined,
            size: 18,
          ),
          label: Text(
            _hasJoined ? 'JOINED' : 'JOIN US',
            style: const TextStyle(
              fontSize: 14,
              fontFamily: 'Outfit',
              fontWeight: FontWeight.bold,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                _hasJoined ? Colors.grey.shade400 : feastGreen,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            elevation: _hasJoined ? 0 : 3,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25)),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  // ─── BADGES ───
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

  Widget _buildJoinedBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: BoxDecoration(
        color: feastLightGreen.withAlpha(80),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: feastGreen.withAlpha(80), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_outline, color: feastGreen, size: 16),
          const SizedBox(width: 6),
          const Text(
            'You\'re In! See You There.',
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
                color: Colors.black.withAlpha(20), blurRadius: 6),
          ],
        ),
        child: Icon(icon, size: 20, color: iconColor ?? feastBlack),
      ),
    );
  }

  Widget _buildMetaRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
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
                    style:
                        const TextStyle(fontWeight: FontWeight.w600),
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