import 'package:flutter/material.dart';
import 'package:feast/core/core.dart';

class AidRequestsScreen extends StatefulWidget {
  const AidRequestsScreen({super.key});

  @override
  State<AidRequestsScreen> createState() => _AidRequestsScreenState();
}

class _AidRequestsScreenState extends State<AidRequestsScreen> {
  final TextEditingController _searchController = TextEditingController();

  // ─── Placeholder aid request data matching the screenshot ───
  final List<Map<String, dynamic>> _aidRequests = [
    {
      'title': 'Surgery Meds &\nTreatment',
      'beneficiary': 'Jacob Vasquez',
      'description':
          'Your generous contribution can provide life-saving surgery meds and essential care for someone in urgent need.',
      'category': 'Health (Support & Supply)',
      'location': 'DBP Village, Almanza Dos',
      'timeRemaining': '7 Days Left',
      'aidFunds': '₱5,000',
      'itemsDonated': 3,
      'donors': 5,
    },
    {
      'title': 'Help My Kid Buy\nSchool Supplies',
      'beneficiary': 'Ria Santos',
      'description':
          'Your gentle act can help Filipino children buy school supplies and underprivileged Filipino children of this loving family.',
      'category': 'Education (Fundraise)',
      'location': 'N/A',
      'timeRemaining': '5 Days Left',
      'aidFunds': '₱500',
      'itemsDonated': 0,
      'donors': 2,
    },
    {
      'title': 'My Family Needs\nFood This Month',
      'beneficiary': 'Ben GalAtiko',
      'description':
          'Your generous contribution can provide groceries for a Filipino family. Please help us reach our goal!',
      'category': 'Basic Needs (& Aid)',
      'location': 'T.S. Cruz, Almanza Dos',
      'timeRemaining': 'N/A',
      'aidFunds': '₱0',
      'itemsDonated': 0,
      'donors': 0,
    },
    {
      'title': 'Feed My Wife &\nDaughters',
      'beneficiary': 'Michael Thomas',
      'description':
          'My family is struggling. Please help provide for my wife and daughters by contributing meals.',
      'category': 'Basic Needs (& Aid)',
      'location': 'BF Almanza, Almanza Dos',
      'timeRemaining': '14 Days Left',
      'aidFunds': '₱1,200',
      'itemsDonated': 2,
      'donors': 4,
    },
    {
      'title': 'Help Me Buy Toys\nFor My Kids',
      'beneficiary': 'Maria Lopez',
      'description':
          'Hoping to give my children a happy childhood. Any help with toys and essentials is appreciated.',
      'category': 'Household (Support)',
      'location': 'Almanza Dos',
      'timeRemaining': '10 Days Left',
      'aidFunds': '₱800',
      'itemsDonated': 1,
      'donors': 3,
    },
  ];

  // Gradient pairs for each card's hero image placeholder
  final List<List<Color>> _cardGradients = [
    [const Color(0xFFA5D6A7), const Color(0xFF81C784)],
    [const Color(0xFF90CAF9), const Color(0xFF64B5F6)],
    [const Color(0xFFFFCC80), const Color(0xFFFFB74D)],
    [const Color(0xFFEF9A9A), const Color(0xFFE57373)],
    [const Color(0xFFCE93D8), const Color(0xFFBA68C8)],
  ];

  // Icons for hero image placeholders
  final List<IconData> _cardIcons = [
    Icons.medical_services_outlined,
    Icons.school_outlined,
    Icons.restaurant_outlined,
    Icons.family_restroom_outlined,
    Icons.toys_outlined,
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FeastAppBar(title: 'Aid Requests'),
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
                      _aidRequests.length,
                      (index) => _buildAidRequestCard(index),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const FeastBottomNav(currentIndex: 1),
      floatingActionButton: FeastFloatingButton(
        icon: Icons.add,
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.createAidRequest);
        },
        tooltip: 'Create Aid Request',
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
              icon: Icon(
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
  // ─── AID REQUEST CARD ───
  // ═══════════════════════════════════════════════════
  Widget _buildAidRequestCard(int index) {
    final request = _aidRequests[index];
    final gradientColors = _cardGradients[index % _cardGradients.length];
    final icon = _cardIcons[index % _cardIcons.length];

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
                            request['title'] as String,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              fontFamily: 'Outfit',
                              color: feastBlack,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 5),
                          // Beneficiary row with avatar
                          Row(
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
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  request['beneficiary'] as String,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontFamily: 'Outfit',
                                    fontWeight: FontWeight.w600,
                                    color: feastOrange,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            request['description'] as String,
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
                  'Request Category: ',
                  request['category'] as String,
                ),
                _buildMetaRow(
                  Icons.location_on_outlined,
                  'Location: ',
                  request['location'] as String,
                ),
                _buildMetaRow(
                  Icons.access_time,
                  'Time Remaining: ',
                  request['timeRemaining'] as String,
                ),
                _buildMetaRow(
                  Icons.attach_money,
                  'Aid Funds Donated: ',
                  request['aidFunds'] as String,
                ),
                _buildMetaRow(
                  Icons.inventory_2_outlined,
                  'Items Donated: ',
                  '${request['itemsDonated']}',
                ),
                _buildMetaRow(
                  Icons.people_outline,
                  'Donors: ',
                  '${request['donors']}',
                ),
              ],
            ),
          ),

          // ── "Tap To View Request" Link ──
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 14, bottom: 10, top: 2),
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.aidRequestDetail);
                },
                child: const Text(
                  'Tap To View Request →',
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
  // ─── META ROW HELPER ───
  // ═══════════════════════════════════════════════════
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
