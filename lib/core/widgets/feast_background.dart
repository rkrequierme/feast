import 'package:flutter/material.dart';
import '../core.dart';

class FeastBackground extends StatelessWidget {
  final Widget child;

  const FeastBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background Image
        Positioned.fill(
          child: Image.asset(
            "assets/images/Background_Image.png",
            fit: BoxFit.cover,
          ),
        ),
        // Gradient Overlay
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  feastLighterBlue.withAlpha(230),
                  feastLighterYellow.withAlpha(230),
                ],
              ),
            ),
          ),
        ),
        // Foreground Content
        child, 
      ],
    );
  }
}
