import 'package:flutter/material.dart';
import 'package:feast/core/core.dart';

class CharityEventsScreen extends StatefulWidget {
  const CharityEventsScreen({super.key});

  @override
  State<CharityEventsScreen> createState() => _CharityEventsScreenState();
}

class _CharityEventsScreenState extends State<CharityEventsScreen> {
  final TextEditingController _searchController = TextEditingController();

  // ─── Placeholder charity event data matching the screenshot ───
  final List<Map<String, dynamic>> _charityEvents = [
    {
      'title': 'Flood Relief\nProject',
      'collaborators': ['Ana De La Cruz', 'Juan Rodriguez & Family'],
      'description':
          'Help us help those flood-ravaged families. Providing food, medicine, supplies to those in desperate need.',
      'category': 'Disaster Management (Support & Supply)',
      'location': 'BF Almanza, Almanza Dos',
      'duration': '5:00 PM | May 28, 2026',
      'isNotYetStarted': true,
      'itemsDonated': 0,
      'participants': '11 / 20',
    },
    {
      'title': 'Give Children\nBooks',
      'collaborators': ['Jasmine Garcia', 'Isabelle Cruz'],
      'description':
          'Sharing the joy of reading with Filipino children! Books, notebooks, messenger bags for a brighter future.',
      'category': 'Education (& Aid)',
      'location': 'T.S. Cruz, Almanza Dos',
      'duration': 'N/A',
      'isNotYetStarted': false,
      'itemsDonated': 0,
      'participants': '8 / 15',
    },
    {
      'title': 'Help Typhoon\nVictims',
      'collaborators': ['Ria Andolin'],
      'description':
          'Providing essential relief to families affected by the recent typhoon including emergency food & shelter.',
      'category': 'Disaster Management (S/Aid)',
      'location': 'BF Almanza, Almanza Dos',
      'duration': '1:30 PM - 5:00 PM | Jun 5, 2026',
      'isNotYetStarted': false,
      'itemsDonated': 5,
      'participants': '15 / 30',
    },
    {
      'title': 'Support Filipino\nVeterans',
      'collaborators': ['Leo Fernando'],
      'description':
          'Helpful supplies and care packages to honor our Filipino veterans and their sacrifices.',
      'category': 'Community (Support & Aid)',
      'location': 'Almanza Dos',
      'duration': 'Not Yet Started',
      'isNotYetStarted': true,
      'itemsDonated': 0,
      'participants': '4 / 20',
    },
    {
      'title': 'Support Elder\nCare',
      'collaborators': ['Rosa Magbanua'],
      'description':
          'Help provide health supplies and daily needs for elderly citizens in our community.',
      'category': 'Health (Support & Aid)',
      'location': 'DBP Village, Almanza Dos',
      'duration': '8:00 AM - 12:00 PM | Jul 1, 2026',
      'isNotYetStarted': false,
      'itemsDonated': 2,
      'participants': '6 / 12',
    },
  ];

  // Gradient pairs for each card's hero image placeholder
  final List<List<Color>> _cardGradients = [
    [const Color(0xFF4FC3F7), const Color(0xFF0288D1)],
    [const Color(0xFFA5D6A7), const Color(0xFF66BB6A)],
    [const Color(0xFFFFCC80), const Color(0xFFF57C00)],
    [const Color(0xFFCE93D8), const Color(0xFF9C27B0)],
    [const Color(0xFFEF9A9A), const Color(0xFFE53935)],
  ];

  // Icons for hero image placeholders
  final List<IconData> _cardIcons = [
    Icons.flood_outlined,
    Icons.auto_stories_outlined,
    Icons.thunderstorm_outlined,
    Icons.military_tech_outlined,
    Icons.elderly_outlined,
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FeastAppBar(title: 'Charity Events'),
      drawer: const FeastDrawer(username: 'Juan De La Cruz'),
      body: FeastBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const SizedBox(height: 12),

              // ─── Search Bar ───
              _buildSearchBar(),

              const SizedBox(height: 12),

              // ─── Scrollable Cards ───
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    children: List.generate(
                      _charityEvents.length,
                      (index) => _buildCharityEventCard(index),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const FeastBottomNav(currentIndex: 2),
      floatingActionButton: FeastFloatingButton(
        icon: Icons.add,
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.createEvent);
        },
        tooltip: 'Create Charity Event',
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  // ─── SEARCH BAR ───
  // ═══════════════════════════════════════════════════
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(15),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            Icon(Icons.search, color: feastGray.withAlpha(150), size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _searchController,
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'Outfit',
                  color: feastBlack,
                ),
                decoration: InputDecoration(
                  hintText: 'Search ...',
                  hintStyle: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Outfit',
                    color: feastGray.withAlpha(150),
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
            Container(
              width: 1,
              height: 24,
              color: feastGray.withAlpha(50),
            ),
            IconButton(
              icon: const Icon(
                Icons.tune,
                color: feastGreen,
                size: 20,
              ),
              onPressed: () {},
              splashRadius: 20,
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  // ─── CHARITY EVENT CARD ───
  // ═══════════════════════════════════════════════════
  Widget _buildCharityEventCard(int index) {
    final event = _charityEvents[index];
    final gradientColors = _cardGradients[index % _cardGradients.length];
    final icon = _cardIcons[index % _cardIcons.length];
    final collaborators = event['collaborators'] as List<String>;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Hero Image + Title Overlay ──
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(16)),
            child: SizedBox(
              height: 150,
              width: double.infinity,
              child: Stack(
                children: [
                  // Hero image placeholder
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: gradientColors,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        icon,
                        size: 56,
                        color: Colors.white.withAlpha(180),
                      ),
                    ),
                  ),
                  // Title overlay card
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 180,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(30),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event['title'] as String,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              fontFamily: 'Outfit',
                              color: feastBlack,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 5),
                          // Collaborator avatars row
                          _buildCollaboratorsRow(collaborators),
                          const SizedBox(height: 5),
                          Text(
                            event['description'] as String,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 9,
                              fontFamily: 'Outfit',
                              color: feastGray.withAlpha(200),
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Meta Info ──
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMetaRow(
                  Icons.category_outlined,
                  'Event Category: ',
                  event['category'] as String,
                ),
                _buildMetaRow(
                  Icons.location_on_outlined,
                  'Location: ',
                  event['location'] as String,
                ),
                _buildMetaRow(
                  Icons.schedule,
                  'Duration: ',
                  event['duration'] as String,
                  valueColor: (event['isNotYetStarted'] as bool)
                      ? feastOrange
                      : null,
                ),
                _buildMetaRow(
                  Icons.inventory_2_outlined,
                  'Items Donated: ',
                  '${event['itemsDonated']}',
                ),
                _buildMetaRow(
                  Icons.people_outline,
                  'Participants: ',
                  event['participants'] as String,
                ),
              ],
            ),
          ),

          // ── "Tap To View Event" Link ──
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 14, bottom: 10, top: 2),
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.eventDetail);
                },
                child: const Text(
                  'Tap To View Event →',
                  style: TextStyle(
                    color: feastGreen,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    fontFamily: 'Outfit',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  // ─── COLLABORATORS ROW ───
  // ═══════════════════════════════════════════════════
  Widget _buildCollaboratorsRow(List<String> collaborators) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: collaborators.map((name) {
        return Row(
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
            const SizedBox(width: 3),
            Flexible(
              child: Text(
                name,
                style: const TextStyle(
                  fontSize: 9,
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.w600,
                  color: feastBlue,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  // ═══════════════════════════════════════════════════
  // ─── META ROW HELPER ───
  // ═══════════════════════════════════════════════════
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
