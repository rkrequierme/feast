// lib/core/widgets/profile_popup.dart
//
// User profile popup shown when tapping the avatar in the app bar.
// Displays user name, Edit Profile button, and Logout button.
//
// REACT.JS INTEGRATION NOTE:
// =========================
// In React, implement as a dropdown menu:
//   <Menu>
//     <MenuItem onClick={() => setEditProfileOpen(true)}>Edit Profile</MenuItem>
//     <MenuItem onClick={() => signOut(auth)}>Logout</MenuItem>
//   </Menu>

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/app_colors.dart';
import '../services/auth_service.dart';
import 'edit_profile_modal.dart';
import 'feast_toast.dart';

class ProfilePopup extends StatelessWidget {
  final String username;
  final String? profilePictureUrl;

  const ProfilePopup({
    super.key,
    required this.username,
    this.profilePictureUrl,
  });

  Future<void> _handleLogout(BuildContext context) async {
    Navigator.pop(context); // Close popup first
    await AuthService.instance.signOut();
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            CircleAvatar(
              radius: 40,
              backgroundColor: feastLightGreen.withAlpha(50),
              backgroundImage: (profilePictureUrl != null && profilePictureUrl!.isNotEmpty)
                  ? NetworkImage(profilePictureUrl!)
                  : null,
              child: (profilePictureUrl == null || profilePictureUrl!.isEmpty)
                  ? const Icon(Icons.person, color: feastGreen, size: 40)
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              username,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'Outfit',
              ),
            ),
            const SizedBox(height: 24),

            // Edit Profile Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: feastBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context); // Close Popup
                  showDialog(
                    context: context,
                    builder: (context) => const EditProfileModal(),
                  );
                },
                child: const Text(
                  'Edit Profile',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Outfit',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: feastError,
                  side: const BorderSide(color: feastError),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => _handleLogout(context),
                child: const Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Outfit',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}