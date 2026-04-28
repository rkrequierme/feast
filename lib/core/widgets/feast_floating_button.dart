import 'package:flutter/material.dart';
import '../core.dart' hide FloatingActionButton;

/// A reusable circular floating action button with a customizable background.
/// Defaults to [feastGreen] if no color is provided.
///
/// When [enabled] is false the button is rendered at reduced opacity and
/// tapping it shows [disabledTooltip] as a SnackBar instead of calling
/// [onPressed].
class FeastFloatingButton extends StatelessWidget {
  final IconData icon;

  /// The action to perform when the button is tapped.
  /// May be null — if null and [enabled] is true the button is still shown
  /// but does nothing on tap.
  final VoidCallback? onPressed;

  final String? tooltip;
  final Color? backgroundColor;

  /// When false the button is visually dimmed and [onPressed] is ignored.
  final bool enabled;

  /// Message shown in a SnackBar when the button is tapped while [enabled]
  /// is false. Has no effect when [enabled] is true.
  final String? disabledTooltip;

  const FeastFloatingButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.backgroundColor,
    this.enabled = true,
    this.disabledTooltip,
  });

  void _handleTap(BuildContext context) {
    if (!enabled) {
      if (disabledTooltip != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(disabledTooltip!),
            duration: const Duration(seconds: 2),
          ),
        );
      }
      return;
    }
    onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.45,
      child: FloatingActionButton(
        onPressed: () => _handleTap(context),
        backgroundColor: backgroundColor ?? feastGreen,
        elevation: 4,
        shape: const CircleBorder(),
        tooltip: enabled ? tooltip : disabledTooltip,
        child: Icon(
          icon,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }
}
