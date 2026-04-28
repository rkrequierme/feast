// lib/features/settings/screens/settings_screen.dart
//
// User settings screen with profile display, notification toggle, and logout.
// Edit Profile opens EditProfileModal.
//
// REACT.JS INTEGRATION NOTE:
// =========================
// User data: users/{uid}
// Fields: displayName, profilePictureUrl, notificationsEnabled, etc.
// React: Use onSnapshot to listen to user document changes.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:feast/core/core.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _displayName = '';
  String _profilePictureUrl = '';
  bool _notificationsEnabled = true;
  bool _isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection(FirestorePaths.users)
          .doc(uid)
          .get();
      if (!mounted) return;
      final data = doc.data() ?? {};
      setState(() {
        _displayName = data['displayName'] as String? ?? 'User';
        _profilePictureUrl = data['profilePictureUrl'] as String? ?? '';
        _notificationsEnabled = data['notificationsEnabled'] as bool? ?? true;
        _isLoadingUser = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoadingUser = false);
    }
  }

  void _handleNotificationsToggle() {
    if (_notificationsEnabled) {
      showDialog(
        context: context,
        builder: (_) => DisableNotificationDialog(
          isDisabling: true,
          onConfirm: () async {
            await _setNotifications(false);
          },
        ),
      );
    } else {
      _setNotifications(true);
    }
  }

  Future<void> _setNotifications(bool enabled) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await NotificationService.instance.setNotificationsEnabled(uid, enabled);
    if (mounted) setState(() => _notificationsEnabled = enabled);
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Logout',
          style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to log out?',
          style: TextStyle(fontFamily: 'Outfit'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: feastGray, fontFamily: 'Outfit')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: feastError),
            onPressed: () async {
              Navigator.pop(context);
              await AuthService.instance.signOut();
              if (!mounted) return;
              Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
            },
            child: const Text('Logout', style: TextStyle(color: Colors.white, fontFamily: 'Outfit')),
          ),
        ],
      ),
    );
  }

  void _showEditProfile() {
    showDialog(
      context: context,
      builder: (_) => EditProfileModal(onSaved: _loadUser),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FeastAppBar(title: 'Settings', username: _displayName),
      drawer: FeastDrawer(username: _displayName),
      body: FeastBackground(
        child: _isLoadingUser
            ? const Center(child: CircularProgressIndicator(color: feastGreen))
            : LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildProfileCard(),
                              const SizedBox(height: 24),
                              _menuItem(
                                icon: Icons.edit_outlined,
                                label: 'Edit Profile',
                                onTap: _showEditProfile,
                              ),
                              const SizedBox(height: 12),
                              _menuItem(
                                icon: _notificationsEnabled
                                    ? Icons.notifications_active_outlined
                                    : Icons.notifications_off_outlined,
                                label: _notificationsEnabled
                                    ? 'Turn Off App Notifications'
                                    : 'Turn On App Notifications',
                                onTap: _handleNotificationsToggle,
                              ),
                              const SizedBox(height: 12),
                              _menuItem(
                                icon: Icons.star_outline,
                                label: 'Rate Our App',
                                onTap: () {
                                  FeastToast.showInfo(context, 'Rate app feature coming soon.');
                                },
                              ),
                              const SizedBox(height: 12),
                              _menuItem(
                                icon: Icons.info_outline,
                                label: 'About The App',
                                onTap: () => Navigator.pushNamed(context, AppRoutes.about),
                              ),
                              const SizedBox(height: 12),
                              _menuItem(
                                icon: Icons.help_outline,
                                label: 'Help & FAQ',
                                onTap: () => Navigator.pushNamed(context, AppRoutes.support),
                              ),
                              const SizedBox(height: 12),
                              _menuItem(
                                icon: Icons.description_outlined,
                                label: 'Terms & Conditions',
                                onTap: () => Navigator.pushNamed(context, AppRoutes.legal),
                              ),
                              const SizedBox(height: 12),
                              _logoutItem(),
                              // Spacer pushes content to top, leaving bottom space only if needed
                              const Spacer(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
      bottomNavigationBar: const FeastBottomNav(currentIndex: 4),
    );
  }

  Widget _buildProfileCard() {
    return Container(
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
          CircleAvatar(
            radius: 28,
            backgroundColor: feastLightGreen.withAlpha(128),
            backgroundImage: _profilePictureUrl.isNotEmpty ? NetworkImage(_profilePictureUrl) : null,
            child: _profilePictureUrl.isEmpty
                ? const Icon(Icons.person, size: 32, color: feastGreen)
                : null,
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _displayName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Outfit',
                  color: feastBlack,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    'Verified Account',
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'Outfit',
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

  Widget _menuItem({
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
            Icon(icon, size: 22, color: feastBlack),
            const SizedBox(width: 14),
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

  Widget _logoutItem() {
    return GestureDetector(
      onTap: _handleLogout,
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
            const Icon(Icons.logout, size: 22, color: feastError),
            const SizedBox(width: 14),
            const Expanded(
              child: Text(
                'Logout',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.w600,
                  color: feastError,
                ),
              ),
            ),
            Icon(Icons.chevron_right, size: 22, color: feastError.withAlpha(120)),
          ],
        ),
      ),
    );
  }
}
