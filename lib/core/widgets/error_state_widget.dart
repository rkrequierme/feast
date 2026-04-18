import 'package:flutter/material.dart';
import '../core.dart';

/// A reusable widget displayed when an error occurs while loading content.
/// Shows an icon, a title, an optional description, and a retry button.
class ErrorStateWidget extends StatelessWidget {
  final String title;
  final String? description;
  final VoidCallback? onRetry;

  const ErrorStateWidget({
    super.key,
    this.title = 'Something went wrong',
    this.description,
    this.onRetry,
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
                color: Colors.red.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                size: 40,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 20),

            // ── Title ───────────────────────────────────────────────────
            Text(
              title,
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

            // ── Retry button ────────────────────────────────────────────
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text(
                  'Try Again',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: feastGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 2,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
