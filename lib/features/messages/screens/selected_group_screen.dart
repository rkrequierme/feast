import 'package:flutter/material.dart';
import 'package:feast/core/core.dart';

class SelectedGroupScreen extends StatefulWidget {
  const SelectedGroupScreen({super.key});

  @override
  State<SelectedGroupScreen> createState() => _SelectedGroupScreenState();
}

class _SelectedGroupScreenState extends State<SelectedGroupScreen> {
  bool _notificationsEnabled = true;
  int _mediaTab = 0; // 0=Pinned, 1=Images, 2=Videos, 3=Documents

  final List<String> _mediaTabs = ['Pinned', 'Images', 'Videos', 'Documents'];

  // ─── Placeholder group data ───
  final Map<String, dynamic> _group = {
    'name': 'T.S. Cruz Food Bank',
    'description':
        'We are a group dedicated to helping out the T.S. Cruz community by giving food.',
  };

  final List<Map<String, String>> _pinnedMessages = [
    {
      'text':
          'The next thing we will consider is how to approach the citizens of T.S. Cruz as we...',
    },
    {
      'text':
          'Pls keep a note that we will proceed with the event as scheduled. Make sure you join the...',
    },
    {
      'text':
          'The event will be held in front of the T.S. Cruz Elementary School this coming Monday...',
    },
  ];

  final List<Map<String, dynamic>> _members = [
    {
      'name': 'Adina Santos',
      'role': 'member',
      'isCurrentUser': true,
      'isOnline': true,
    },
    {
      'name': 'Jose De La Cruz',
      'role': 'leader',
      'isCurrentUser': false,
      'isOnline': true,
    },
    {
      'name': 'Marvin Reyes',
      'role': 'co_leader',
      'isCurrentUser': false,
      'isOnline': true,
    },
    {
      'name': 'Gregory Bautista',
      'role': 'member',
      'isCurrentUser': false,
      'isOnline': false,
    },
    {
      'name': 'Samuel Del Rosario',
      'role': 'member',
      'isCurrentUser': false,
      'isOnline': true,
    },
    {
      'name': 'Bambang Gonzales',
      'role': 'member',
      'isCurrentUser': false,
      'isOnline': false,
    },
    {
      'name': 'Sururi Aquino',
      'role': 'member',
      'isCurrentUser': false,
      'isOnline': true,
    },
    {
      'name': 'Michael Ramos',
      'role': 'member',
      'isCurrentUser': false,
      'isOnline': false,
    },
    {
      'name': 'Jackobs Garcia',
      'role': 'member',
      'isCurrentUser': false,
      'isOnline': false,
    },
    {
      'name': 'Anastasia Lopez',
      'role': 'member',
      'isCurrentUser': false,
      'isOnline': true,
    },
    {
      'name': 'Fuelta Fernandez',
      'role': 'member',
      'isCurrentUser': false,
      'isOnline': false,
    },
    {
      'name': 'Kimini Mendoza',
      'role': 'member',
      'isCurrentUser': false,
      'isOnline': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FeastBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // ─── Custom App Bar ───
              _buildGroupAppBar(),

              // ─── Scrollable Content ───
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 80),
                  child: Column(
                    children: [
                      // ─── Group Header Image ───
                      _buildGroupHeaderImage(),

                      // ─── Group Name ───
                      _buildGroupName(),

                      const SizedBox(height: 12),

                      // ─── Group Description ───
                      _buildGroupDescription(),

                      const SizedBox(height: 12),

                      // ─── Notifications Toggle ───
                      _buildNotificationsToggle(),

                      const SizedBox(height: 20),

                      // ─── Media Tabs ───
                      _buildMediaTabs(),

                      const SizedBox(height: 12),

                      // ─── Pinned Messages / Media Content ───
                      _buildMediaContent(),

                      const SizedBox(height: 24),

                      // ─── Divider ───
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        height: 1,
                        color: feastGray.withAlpha(40),
                      ),

                      const SizedBox(height: 16),

                      // ─── Participants Header ───
                      _buildParticipantsHeader(),

                      const SizedBox(height: 8),

                      // ─── Members List ───
                      ..._members.map((m) => _buildMemberItem(m)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: FeastBottomNav(currentIndex: 3),
    );
  }

  // ═══════════════════════════════════════════════════
  // ─── CUSTOM APP BAR ───
  // ═══════════════════════════════════════════════════
  Widget _buildGroupAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: feastLightGreen,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: feastBlack),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Center(
              child: Text(
                _group['name'] as String,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Outfit',
                  color: feastBlack,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: feastBlack),
            onPressed: () {
              // Group options menu
            },
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  // ─── GROUP HEADER IMAGE ───
  // ═══════════════════════════════════════════════════
  Widget _buildGroupHeaderImage() {
    return Container(
      width: double.infinity,
      height: 160,
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
          // Decorative icons
          Positioned(
            top: 20,
            left: 30,
            child: Icon(
              Icons.restaurant_outlined,
              size: 60,
              color: Colors.white.withAlpha(60),
            ),
          ),
          Positioned(
            bottom: 30,
            right: 40,
            child: Icon(
              Icons.volunteer_activism,
              size: 50,
              color: Colors.white.withAlpha(50),
            ),
          ),
          // Center icon
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(40),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.group,
                size: 44,
                color: Colors.white.withAlpha(180),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  // ─── GROUP NAME ───
  // ═══════════════════════════════════════════════════
  Widget _buildGroupName() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Text(
        _group['name'] as String,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Outfit',
          color: feastBlack,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  // ─── GROUP DESCRIPTION ───
  // ═══════════════════════════════════════════════════
  Widget _buildGroupDescription() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline, size: 18, color: feastGray.withAlpha(150)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _group['description'] as String,
                style: TextStyle(
                  fontSize: 13,
                  fontFamily: 'Outfit',
                  color: feastGray.withAlpha(200),
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  // ─── NOTIFICATIONS TOGGLE ───
  // ═══════════════════════════════════════════════════
  Widget _buildNotificationsToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.notifications_outlined,
                size: 20, color: feastBlack),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Notifications',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.w600,
                  color: feastBlack,
                ),
              ),
            ),
            Switch(
              value: _notificationsEnabled,
              activeTrackColor: feastGreen,
              onChanged: (val) {
                setState(() => _notificationsEnabled = val);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  // ─── MEDIA TABS ───
  // ═══════════════════════════════════════════════════
  Widget _buildMediaTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: List.generate(_mediaTabs.length, (i) {
          final selected = i == _mediaTab;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _mediaTab = i),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 4, vertical: 8),
                    child: Text(
                      _mediaTabs[i],
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'Outfit',
                        fontWeight:
                            selected ? FontWeight.bold : FontWeight.w500,
                        color: selected ? feastGreen : feastGray.withAlpha(150),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Container(
                    height: 2,
                    color: selected ? feastGreen : Colors.transparent,
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  // ─── MEDIA CONTENT (Pinned Messages) ───
  // ═══════════════════════════════════════════════════
  Widget _buildMediaContent() {
    if (_mediaTab == 0) {
      // Pinned Messages
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            ..._pinnedMessages.map((msg) => _buildPinnedMessageItem(msg)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                // See more pinned messages
              },
              child: const Text(
                'See More',
                style: TextStyle(
                  fontSize: 13,
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.w600,
                  color: feastGreen,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Placeholder for other tabs
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Center(
        child: Column(
          children: [
            Icon(
              _mediaTab == 1
                  ? Icons.image_outlined
                  : _mediaTab == 2
                      ? Icons.videocam_outlined
                      : Icons.description_outlined,
              size: 48,
              color: feastGray.withAlpha(100),
            ),
            const SizedBox(height: 8),
            Text(
              'No ${_mediaTabs[_mediaTab].toLowerCase()} yet',
              style: TextStyle(
                fontSize: 13,
                fontFamily: 'Outfit',
                color: feastGray.withAlpha(150),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPinnedMessageItem(Map<String, String> msg) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              msg['text'] ?? '',
              style: TextStyle(
                fontSize: 12,
                fontFamily: 'Outfit',
                color: feastGray.withAlpha(200),
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.chevron_right,
            size: 20,
            color: feastGray.withAlpha(100),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  // ─── PARTICIPANTS HEADER ───
  // ═══════════════════════════════════════════════════
  Widget _buildParticipantsHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          const Icon(Icons.people, size: 20, color: feastBlack),
          const SizedBox(width: 8),
          Text(
            '${_members.length} Participants',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              fontFamily: 'Outfit',
              color: feastBlack,
            ),
          ),
          const Spacer(),
          // Remove member
          IconButton(
            onPressed: () {
              // Remove member action
            },
            icon: const Icon(Icons.person_remove_outlined, size: 20),
            color: feastGray,
            splashRadius: 20,
          ),
          // Add member
          IconButton(
            onPressed: () {
              // Add member action
            },
            icon: const Icon(Icons.person_add_outlined, size: 20),
            color: feastGray,
            splashRadius: 20,
          ),
          // Search member
          IconButton(
            onPressed: () {
              // Search member action
            },
            icon: const Icon(Icons.search, size: 20),
            color: feastGray,
            splashRadius: 20,
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  // ─── MEMBER ITEM ───
  // ═══════════════════════════════════════════════════
  Widget _buildMemberItem(Map<String, dynamic> member) {
    final String role = member['role'] as String;
    final bool isCurrentUser = member['isCurrentUser'] as bool;
    final bool isOnline = member['isOnline'] as bool;

    String? roleLabel;
    Color? roleBadgeColor;
    if (role == 'leader') {
      roleLabel = 'Leader';
      roleBadgeColor = feastGreen;
    } else if (role == 'co_leader') {
      roleLabel = 'Co-Leader';
      roleBadgeColor = const Color(0xFF009688);
    }

    return InkWell(
      onTap: () {
        // View member profile
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Row(
          children: [
            // Avatar + online
            Stack(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: feastLightGreen.withAlpha(128),
                  child: const Icon(
                    Icons.person,
                    size: 24,
                    color: feastGreen,
                  ),
                ),
                if (isOnline)
                  Positioned(
                    bottom: 1,
                    right: 1,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: feastGreen,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),

            // Name + You tag
            Expanded(
              child: Row(
                children: [
                  Text(
                    member['name'] as String,
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.w500,
                      color: feastBlack,
                    ),
                  ),
                  if (isCurrentUser) ...[
                    const SizedBox(width: 6),
                    Text(
                      'You',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'Outfit',
                        color: feastGray.withAlpha(130),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Role badge
            if (roleLabel != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: roleBadgeColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  roleLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Outfit',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
