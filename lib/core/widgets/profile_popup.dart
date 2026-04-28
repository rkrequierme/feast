import 'package:flutter/material.dart';
import '../core.dart';

class ProfilePopup extends StatelessWidget {
  final String username;
  final String? profilePictureUrl;

  const ProfilePopup({
    super.key, 
    required this.username,
    this.profilePictureUrl,
  });

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
                fontFamily: 'Outfit'
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  // Add your actual logout logic here via AuthService
                  Navigator.pop(context);
                },
                child: const Text(
                  'Logout', 
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}