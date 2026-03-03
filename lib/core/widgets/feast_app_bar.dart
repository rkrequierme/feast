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
