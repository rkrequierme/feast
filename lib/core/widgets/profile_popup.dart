// lib/core/widgets/profile_popup.dart
//
// User profile popup shown when tapping the avatar in the app bar.
// Displays user name, Edit Profile button, and Logout button.

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/app_colors.dart';
import '../services/auth_service.dart';
import 'edit_profile_modal.dart';
import 'feast_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/firestore_paths.dart';
import '../constants/app_routes.dart';

class ProfilePopup extends StatefulWidget {
  final String username;
  final String? profilePictureUrl;
  final VoidCallback? onProfileUpdated;

  const ProfilePopup({
    super.key,
    required this.username,
    this.profilePictureUrl,
    this.onProfileUpdated,
  });

  @override
  State<ProfilePopup> createState() => _ProfilePopupState();
}

class _ProfilePopupState extends State<ProfilePopup> {
  bool _isLoggingOut = false;
  String? _currentProfilePictureUrl;
  String? _currentUsername;

  @override
  void initState() {
    super.initState();
    _currentProfilePictureUrl = widget.profilePictureUrl;
    _currentUsername = widget.username;
  }

  void _updateProfileData() {
    // Refresh user data after profile update
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      FirebaseFirestore.instance
          .collection(FirestorePaths.users)
          .doc(uid)
          .get()
          .then((doc) {
        if (doc.exists && mounted) {
          final data = doc.data()!;
          setState(() {
            _currentUsername = data['displayName'] as String? ?? 
                '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'.trim();
            _currentProfilePictureUrl = data['profilePictureUrl'] as String?;
          });
          widget.onProfileUpdated?.call();
        }
      });
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    if (_isLoggingOut) return;
    
    setState(() => _isLoggingOut = true);
    
    // Close popup first
    if (mounted) Navigator.pop(context);
    
    try {
      await AuthService.instance.signOut();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
      }
    } catch (e) {
      if (mounted) {
        FeastToast.showError(context, 'Failed to log out. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _isLoggingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine if we have a profile picture to show
    final hasProfilePicture = _currentProfilePictureUrl != null && _currentProfilePictureUrl!.isNotEmpty;
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 12, offset: Offset(0, 4)),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Close button
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: feastLightGreen,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, size: 16, color: feastGray),
                  ),
                ),
              ),
              
              // Profile Picture - now shows actual user image
              Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: feastLightGreen.withAlpha(50),
                    backgroundImage: hasProfilePicture
                        ? NetworkImage(_currentProfilePictureUrl!)
                        : null,
                    child: !hasProfilePicture
                        ? const Icon(Icons.person, color: feastGreen, size: 50)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: feastGreen,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Username
              Text(
                _currentUsername ?? 'User',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Outfit',
                  color: feastBlack,
                ),
              ),
              
              // Email (optional - show user's email)
              FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection(FirestorePaths.users)
                    .doc(FirebaseAuth.instance.currentUser?.uid)
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data!.exists) {
                    final email = snapshot.data!.get('email') as String?;
                    if (email != null) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          email,
                          style: const TextStyle(
                            fontSize: 13,
                            fontFamily: 'Outfit',
                            color: feastGray,
                          ),
                        ),
                      );
                    }
                  }
                  return const SizedBox.shrink();
                },
              ),
              
              const SizedBox(height: 20),
              const Divider(color: feastLightGreen),
              const SizedBox(height: 16),

              // Edit Profile Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text(
                    'Edit Profile',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Outfit',
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: feastBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context); // Close Popup
                    showDialog(
                      context: context,
                      builder: (context) => EditProfileModal(
                        onSaved: () {
                          _updateProfileData();
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),

              // Logout Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.logout, size: 18),
                  label: _isLoggingOut
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: feastError,
                          ),
                        )
                      : const Text(
                          'Logout',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Outfit',
                          ),
                        ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: feastError,
                    side: const BorderSide(color: feastError),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isLoggingOut ? null : () => _handleLogout(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
