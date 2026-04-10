import 'package:flutter/material.dart';
import '../core.dart';

class FeastLink extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Alignment alignment; // New parameter
  final Color color;

  const FeastLink({
    super.key,
    required this.text,
    required this.onPressed,
    this.alignment = Alignment.center, // Default is still center
    this.color = feastLink,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment, // This "pushes" the link left, right, or center
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: const Size(0, 0),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: color,
            fontFamily: "Outfit",
            fontWeight: FontWeight.w900,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }
}