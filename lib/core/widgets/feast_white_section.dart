import 'package:flutter/material.dart';
import '../core.dart';

/// A reusable white rounded card used to display body content in the About Us screen.
/// Accepts a [child] widget for flexible content composition.
class FeastWhiteSection extends StatelessWidget {
  final Widget child;

  const FeastWhiteSection({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: DefaultTextStyle(
        style: const TextStyle(
          fontFamily: 'Nunito',
          fontSize: 14,
          color: Colors.black87,
          height: 1.5,
        ),
        child: child,
      ),
    );
  }
}