import 'package:flutter/material.dart';
import '../core.dart';

/// A reusable yellow rounded card used for section headers in the About Us screen.
/// Displays a [FeastTagline] as its title, with an optional decorative paw watermark.
class FeastYellowSection extends StatelessWidget {
  final String title;
  final double titleFontSize;

  const FeastYellowSection({
    super.key,
    required this.title,
    this.titleFontSize = 22,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: feastLightYellow,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: FeastTagline(
        title,
        fontSize: titleFontSize,
        textColor: Colors.white,
        strokeColor: feastGreen,
        strokeWidth: 10,
      ),
    );
  }
}