import 'package:flutter/material.dart';
import '../core.dart';

class FeastBackground extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const FeastBackground({
    super.key, 
    required this.child,
    this.padding,
  });

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
        // Foreground Content with optional padding
        if (padding != null)
          Padding(
            padding: padding!,
            child: child,
          )
        else
          child,
      ],
    );
  }
}
