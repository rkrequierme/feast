import 'package:flutter/material.dart';

/// A banner displayed at the top of the screen when the device is offline.
/// Typically used inside a Column or Stack above the main content.
class OfflineBanner extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const OfflineBanner({
    super.key,
    this.message = 'You are currently offline',
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Colors.red.shade700,
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: Colors.white,
                ),
              ),
            ),
            if (onRetry != null)
              GestureDetector(
                onTap: onRetry,
                child: const Text(
                  'Retry',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: Colors.white,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
