import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core.dart';

class FeastAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final bool showWelcomeMessage;
  final VoidCallback? onProfileTap;

  const FeastAppBar({
    super.key,
    required this.title,
    this.showWelcomeMessage = false,
    this.onProfileTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<FeastAppBar> createState() => _FeastAppBarState();
}

class _FeastAppBarState extends State<FeastAppBar> {
  String? _username;
  String? _profilePictureUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    FirebaseFirestore.instance
        .collection(FirestorePaths.users)
        .doc(uid)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists && mounted) {
        final data = snapshot.data()!;
        final displayName = data['displayName'] as String?;
        final firstName = data['firstName'] as String? ?? '';
        final lastName = data['lastName'] as String? ?? '';
        final profilePic = data['profilePictureUrl'] as String?;
        
        setState(() {
          _username = displayName ?? 
              (firstName.isNotEmpty || lastName.isNotEmpty 
                  ? '$firstName $lastName'.trim() 
                  : 'User');
          _profilePictureUrl = profilePic;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: feastLightGreen,
      elevation: 0,
      centerTitle: true,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu, color: feastBlack),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Outfit',
              color: feastBlack,
            ),
          ),
          if (widget.showWelcomeMessage && _username != null && _username!.isNotEmpty)
            Text(
              'Welcome To F.E.A.S.T., $_username!',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                fontFamily: 'Outfit',
                color: feastBlack.withAlpha(179),
              ),
            ),
        ],
      ),
      actions: [
        IconButton(
          icon: CircleAvatar(
            radius: 16,
            backgroundColor: feastLightGreen,
            backgroundImage: _profilePictureUrl != null && _profilePictureUrl!.isNotEmpty
                ? NetworkImage(_profilePictureUrl!)
                : null,
            child: (_profilePictureUrl == null || _profilePictureUrl!.isEmpty)
                ? const Icon(Icons.person, color: feastGreen, size: 20)
                : null,
          ),
          onPressed: widget.onProfileTap ?? () {
            showDialog(
              context: context,
              builder: (context) => ProfilePopup(
                username: _username ?? 'User',
                profilePictureUrl: _profilePictureUrl,
                onProfileUpdated: () {
                  // Refresh user data
                  _loadUserData();
                  widget.onProfileTap?.call();
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
