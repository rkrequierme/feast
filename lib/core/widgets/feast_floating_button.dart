import 'package:flutter/material.dart';
import '../core.dart' hide FloatingActionButton;

/// A reusable circular floating action button styled with [feastGreen].
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
      backgroundColor: feastGreen,
      elevation: 4,
      shape: const CircleBorder(),
      tooltip: tooltip,
      child: Icon(
        icon,
        color: Colors.white,
        size: 30,
      ),
    );
  }
}