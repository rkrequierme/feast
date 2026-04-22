import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class BottomFormBackground extends StatelessWidget {
  final Widget child;

  const BottomFormBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        // Border
        border: Border(top: BorderSide(color: Colors.white, width: 8)),
        // Border Radius
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(50),
          topRight: Radius.circular(50),
        ),
        // Background Image
        image: const DecorationImage(
          image: AssetImage("assets/images/Charity_Pattern.jpg"),
          fit: BoxFit.cover,
          opacity: 0.05,
        ),
        // Gradient Overlay
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [feastLightYellow, feastLighterYellow],
        ),
      ),
      child: child,
    );
  }
}
