import 'package:flutter/material.dart';
import '../core.dart'; // To access feastGreen

class FeastButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed; // Allows passing screen-specific functions
  final Color? backgroundColor;
  final double borderRadius;

  const FeastButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor, // If null, defaults to feastGreen in build
    this.borderRadius = 25.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? feastGreen,
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          // styleFrom handles the "disabled" color automatically 
          // if onPressed is null
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontFamily: "Outfit",
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}