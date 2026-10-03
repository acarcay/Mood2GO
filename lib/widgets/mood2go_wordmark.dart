import 'package:flutter/material.dart';

class Mood2GoWordmark extends StatelessWidget {
  const Mood2GoWordmark({
    super.key,
    this.fontSize = 19,
    this.darkColor = const Color(0xFF244638),
    this.goColor = const Color(0xFF92C9A3),
  });

  final double fontSize;
  final Color darkColor;
  final Color goColor;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
        ),
        children: [
          TextSpan(
            text: 'Mood2',
            style: TextStyle(color: darkColor),
          ),
          TextSpan(
            text: 'GO',
            style: TextStyle(color: goColor),
          ),
        ],
      ),
    );
  }
}
