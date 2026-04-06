import 'package:flutter/material.dart';
import '../core.dart';

class FeastTagline extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color textColor;
  final Color strokeColor;
  final double strokeWidth;
  final String fontFamily;

  const FeastTagline(
    this.text, {
    super.key,
    this.fontSize = 20,
    this.textColor = Colors.white,
    this.strokeColor = feastGreen,
    this.strokeWidth = 8,
    this.fontFamily = "TitanOne",
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Stroke Layer
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: fontSize,
            fontFamily: fontFamily,
            fontWeight: FontWeight.w400,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = strokeWidth
              ..color = strokeColor,
          ),
        ),
        // Fill Layer
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: fontSize,
            fontFamily: fontFamily,
            fontWeight: FontWeight.w400,
            color: textColor,
          ),
        ),
      ],
    );
  }
}
