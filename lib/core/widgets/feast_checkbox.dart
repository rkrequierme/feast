import 'package:flutter/material.dart';
import '../core.dart'; // Ensure feastGreen is defined here

enum CheckboxType { requirement, rememberMe }

class FeastCheckbox extends StatelessWidget {
  final String text;
  final bool value;
  final ValueChanged<bool?> onChanged;
  final CheckboxType type;

  const FeastCheckbox({
    super.key,
    required this.text,
    required this.value,
    required this.onChanged,
    this.type = CheckboxType.rememberMe, // Default to remember me
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 24,
            width: 24,
            child: Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: feastGreen,
              // Visual feedback: Requirement boxes often look "sharper"
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(type == CheckboxType.requirement ? 2 : 4),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: type == CheckboxType.requirement ? Colors.red.shade800 : Colors.black87,
              fontFamily: "Outfit",
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}