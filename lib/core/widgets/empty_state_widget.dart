import 'package:flutter/material.dart';
import '../core.dart';

/// A reusable widget displayed when a list or content area has no data.
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String message; // Changed from title to message
  final String? description;
  final String? buttonLabel;
  final VoidCallback? onButtonPressed;

  const EmptyStateWidget({
    super.key,
    this.icon = Icons.inbox_outlined,
    this.message = 'Nothing here yet', // Default value updated
    this.description,
    this.buttonLabel,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Icon ────────────────────────────────────────────────────
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: feastGreen.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: feastGreen),
            ),
            const SizedBox(height: 20),

            // ── Primary Message (Title) ─────────────────────────────────
            Text(
              message, // Now using the message property
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Outfit',
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: Colors.black87,
              ),
            ),

            // ── Description ─────────────────────────────────────────────
            if (description != null) ...[
              const SizedBox(height: 8),
              Text(
                description!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 14,
                  color: Colors.black45,
                  height: 1.5,
                ),
              ),
            ],

            // ── Action button ───────────────────────────────────────────
            if (buttonLabel != null && onButtonPressed != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onButtonPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: feastGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 2,
                ),
                child: Text(
                  buttonLabel!,
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
