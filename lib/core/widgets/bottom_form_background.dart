import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class BottomFormBackground extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;  // Add optional padding parameter

  const BottomFormBackground({
    super.key, 
    required this.child,
    this.padding,  // Add this
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.white, width: 8)),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(50),
          topRight: Radius.circular(50),
        ),
        image: const DecorationImage(
          image: AssetImage("assets/images/Charity_Pattern.jpg"),
          fit: BoxFit.cover,
          opacity: 0.05,
        ),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [feastLightYellow, feastLighterYellow],
        ),
      ),
      child: padding != null 
          ? Padding(padding: padding!, child: child)  // Apply custom padding
          : child,  // No extra padding if not specified
    );
  }
}
