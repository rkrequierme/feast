import 'package:flutter/material.dart';
import '../core.dart';

class FeastAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? username;
  final VoidCallback? onProfileTap;

  const FeastAppBar({
    super.key,
    required this.title,
    this.username,
    this.onProfileTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

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
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Outfit',
              color: feastBlack,
            ),
          ),
          if (username != null)
            Text(
              'Welcome To F.E.A.S.T., $username!',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                fontFamily: 'Outfit',
                color: feastBlack.withAlpha(179),
              ),
            ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.account_circle, color: feastBlack, size: 32),
          onPressed: onProfileTap ?? () {},
        ),
      ],
    );
  }
}
