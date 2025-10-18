import 'package:flutter/material.dart';

class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final List<Color> gradientColors;
  final double height;
  final double borderRadius;
  final double fontSize;

  const GradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.gradientColors = const [Color(0xFF884ED9), Color(0xFF3FA9F5)],
    this.height = 50,
    this.borderRadius = 24,
    this.fontSize = 18,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradientColors),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(color: Colors.white, fontSize: fontSize),
        ),
      ),
    );
  }
}
