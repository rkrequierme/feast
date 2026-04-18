import 'package:flutter/material.dart';
import 'package:feast/core/core.dart';
import 'package:feast/features/settings/widgets/disable_notification_dialog.dart';
import 'package:feast/features/settings/widgets/profile_popup.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final bottomNavHeight = MediaQuery.of(context).padding.bottom + 56;

    return Scaffold(
      extendBody: true,
      appBar: const FeastAppBar(title: 'Settings'),
      drawer: const FeastDrawer(username: 'Lee Fernandez'),
      body: FeastBackground(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: bottomNavHeight + 16,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - bottomNavHeight - 16,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // ─── Profile Card ───
                    _buildProfileCard(),
                    const SizedBox(height: 25),

                    // ─── Menu Items ───
                    _buildMenuItem(
                      icon: Icons.edit_outlined,
                      label: 'Edit Profile',
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => const ProfilePopup(),
                        );
                      },
                    ),
                    const SizedBox(height: 25),

                    _buildMenuItem(
                      icon: Icons.notifications_outlined,
                      label: _notificationsEnabled
                          ? 'Turn On App Notifications'
                          : 'Turn Off App Notifications',
                      onTap: () {
                        if (_notificationsEnabled) {
                          showDialog(
                            context: context,
                            builder: (_) => DisableNotificationDialog(
                              onYes: () {
                                setState(() => _notificationsEnabled = false);
                                Navigator.of(context).pop();
                              },
                              onNo: () => Navigator.of(context).pop(),
                            ),
                          );
                        } else {
                          setState(() => _notificationsEnabled = true);
                        }
                      },
                    ),
                    const SizedBox(height: 25),

                    _buildMenuItem(
                      icon: Icons.star_outline,
                      label: 'Rate Our App',
                      onTap: () {
                        // Rate app placeholder
                      },
                    ),
                    const SizedBox(height: 25),

                    _buildMenuItem(
                      icon: Icons.info_outline,
                      label: 'About The App',
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.about),
                    ),
                    const SizedBox(height: 25),

                    _buildMenuItem(
                      icon: Icons.help_outline,
                      label: 'Help & FAQ',
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.support),
                    ),
                    const SizedBox(height: 25),

                    _buildMenuItem(
                      icon: Icons.description_outlined,
                      label: 'Terms & Conditions',
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.legal),
                    ),
                    const SizedBox(height: 25),

                    // ─── Logout ───
                    _buildLogoutItem(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: FeastBottomNav(currentIndex: 4),
    );
  }

  // ═══════════════════════════════════════════════════
  // ─── PROFILE CARD ───
  // ═══════════════════════════════════════════════════
  Widget _buildProfileCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 28,
            backgroundColor: feastLightGreen.withAlpha(128),
            child: const Icon(Icons.person, size: 32, color: feastGreen),
          ),
          const SizedBox(width: 14),

          // Name & Verified
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Lee Fernandez',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Outfit',
                  color: feastBlack,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Text(
                    'Verified Account',
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.w500,
                      color: feastGray.withAlpha(179),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.check_circle, size: 16, color: feastGreen),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  // ─── MENU ITEM ───
  // ═══════════════════════════════════════════════════
  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: feastBlack),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.w600,
                  color: feastBlack,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, size: 22, color: feastGray),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  // ─── LOGOUT ITEM ───
  // ═══════════════════════════════════════════════════
  Widget _buildLogoutItem() {
    return GestureDetector(
      onTap: () {
        // Logout and go back to login
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.login,
          (route) => false,
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.logout, size: 20, color: feastWarning),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Logout',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.w600,
                  color: feastWarning,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 22,
              color: feastOrange.withAlpha(179),
            ),
          ],
        ),
      ),
    );
  }
}
