// lib/core/widgets/feast_checkbox.dart

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../core.dart'; 

enum CheckboxType { requirement, rememberMe }

class FeastCheckbox extends StatelessWidget {
  final String text;
  final bool value;
  final ValueChanged<bool?> onChanged;
  final CheckboxType type;
  final String? linkText;
  final VoidCallback? onLinkTap;
  final Color? linkColor;

  const FeastCheckbox({
    super.key,
    required this.text,
    required this.value,
    required this.onChanged,
    this.type = CheckboxType.rememberMe,
    this.linkText,
    this.onLinkTap,
    this.linkColor,
  });

  @override
  Widget build(BuildContext context) {
    final baseStyle = TextStyle(
      color: type == CheckboxType.requirement ? Colors.red.shade800 : Colors.black54,
      fontFamily: "Outfit",
      fontWeight: FontWeight.bold,
      fontSize: 13,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: 24,
          width: 24,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            fillColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return feastGreen; 
              }
              return Colors.white; 
            }),
            checkColor: Colors.white,
            side: const BorderSide(
              color: Colors.black26, 
              width: 1.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(type == CheckboxType.requirement ? 2 : 4),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildTextContent(baseStyle),
        ),
      ],
    );
  }

  Widget _buildTextContent(TextStyle baseStyle) {
    if (linkText == null || !text.contains(linkText!)) {
      // REMOVED: GestureDetector wrapper - now just plain Text
      // Users must tap the checkbox directly, not the text
      return Text(text, style: baseStyle);
    }

    final parts = text.split(linkText!);
    
    return RichText(
      text: TextSpan(
        style: baseStyle,
        children: [
          TextSpan(
            text: parts[0],
            // REMOVED: recognizer - now just plain text
          ),
          TextSpan(
            text: linkText,
            style: baseStyle.copyWith(
              color: linkColor ?? feastGreen, 
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()..onTap = onLinkTap,
          ),
          if (parts.length > 1)
            TextSpan(
              text: parts[1],
              // REMOVED: recognizer - now just plain text
            ),
        ],
      ),
    );
  }
}
