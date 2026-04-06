import 'package:flutter/material.dart';
import '../core.dart';

class FieldLabel extends StatelessWidget {
  final String text;

  const FieldLabel({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: feastGray,
        fontSize: 12,
        fontFamily: "Outfit",
        fontWeight: FontWeight.w900,
      ),
    );
  }
}
