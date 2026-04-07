import 'package:flutter/material.dart';
import 'package:feast/core/core.dart';

class FeastAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBurgerMenu;
  final List<Widget>? actions;
  
  const FeastAppBar({
    super.key,
    required this.title,
    this.showBurgerMenu = false,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: feastLightGreen,
      centerTitle: true,
      leading: showBurgerMenu
      ? IconButton(
        icon: const Icon(Icons.arrow_back, color: feastBlack),
        onPressed: () => Navigator.of(context).pop(),
      ) : IconButton(
        icon: const Icon(Icons.menu, color: feastBlack),
        onPressed: () => Scaffold.of(context).openDrawer(),
      ),
      title: Text(
        title,
        style: AppTextStyles.appBarTitle,
      ),
      actions: actions ?? [],
    );
  }
}

/*
class FeastAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle; // Added subtitle support
  final bool showBackButton; // Renamed for clarity
  final List<Widget>? actions;

  const FeastAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.showBackButton = false,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(80); // Increased height for subtitle

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: feastLightGreen,
      elevation: 0, // Appears flat in the image
      centerTitle: true,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: feastBlack),
              onPressed: () => Navigator.of(context).pop(),
            )
          : IconButton(
              icon: const Icon(Icons.menu, color: feastBlack),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: AppTextStyles.appBarTitle, // Ensure this is bold/heavy
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              style: AppTextStyles.bodySmall.copyWith(color: feastBlack), // Adjust style
            ),
        ],
      ),
      actions: actions ?? [
        IconButton(
          icon: const Icon(Icons.account_circle, color: feastBlack, size: 32),
          onPressed: () {},
        ),
      ],
    );
  }
}
*/