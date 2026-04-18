import 'package:flutter/material.dart';
import '../core.dart';

/// A semi-transparent overlay with a centered loading spinner.
/// Useful for blocking user interaction during async operations.
///
/// Usage:
/// ```dart
/// Stack(
///   children: [
///     YourMainContent(),
///     if (isLoading) const LoadingOverlay(),
///   ],
/// )
/// ```
class LoadingOverlay extends StatelessWidget {
  final String? message;
  final Color barrierColor;

  const LoadingOverlay({
    super.key,
    this.message,
    this.barrierColor = Colors.black54,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: barrierColor,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 36,
                height: 36,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(feastGreen),
                ),
              ),
              if (message != null) ...[
                const SizedBox(height: 16),
                Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
