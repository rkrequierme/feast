import 'package:flutter/material.dart';
import '../core.dart';

/// A labeled linear progress bar with percentage display.
/// Useful for donation progress, event goals, etc.
class ProgressBarWidget extends StatelessWidget {
  final String label;
  final double progress; // 0.0 to 1.0
  final Color? activeColor;
  final Color? backgroundColor;
  final bool showPercentage;

  const ProgressBarWidget({
    super.key,
    required this.label,
    required this.progress,
    this.activeColor,
    this.backgroundColor,
    this.showPercentage = true,
  });

  @override
  Widget build(BuildContext context) {
    final clampedProgress = progress.clamp(0.0, 1.0);
    final percentText = '${(clampedProgress * 100).toInt()}%';
    final barColor = activeColor ?? feastGreen;
    final bgColor = backgroundColor ?? Colors.grey.shade200;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Label + percentage ───────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
            if (showPercentage)
              Text(
                percentText,
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  color: barColor,
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),

        // ── Bar ─────────────────────────────────────────────────────
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: clampedProgress,
            minHeight: 8,
            backgroundColor: bgColor,
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
          ),
        ),
      ],
    );
  }
}
