import 'package:flutter/material.dart';
import '../core.dart' hide FloatingActionButton; // Assuming feastDarkGreen is here

class FeastFloatingButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;

  const FeastFloatingButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: feastGreen, // Your specific green from the images
      elevation: 4, // Provides the shadow seen in your screenshots
      shape: const CircleBorder(), // Ensures it stays perfectly circular
      tooltip: tooltip,
      child: Icon(
        icon,
        color: Colors.white,
        size: 30, // Adjusted to match the visual weight in the images
      ),
    );
  }
}


// HOW TO USE
/*
FeastFloatingButton(
  icon: Icons.format_indent_increase_rounded, // or Icons.sort
  onPressed: () => print("List pressed"),
)
*/

/*
FeastFloatingButton(
  icon: Icons.quiz_outlined,
  onPressed: () => print("Support pressed"),
)
*/

/*
FeastFloatingButton(
  icon: Icons.add_moderator_outlined, // or Icons.health_and_safety
  onPressed: () => print("Health pressed"),
)
*/

/*
FeastFloatingButton(
  icon: Icons.add_comment_rounded,
  onPressed: () => print("Add message pressed"),
)
*/
