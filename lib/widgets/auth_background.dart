import 'package:ezbuy/core/theme/colors.dart';
import 'package:flutter/material.dart';


class AuthBackground extends StatelessWidget {
  final Widget child;

  const AuthBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      children: [
        _buildGradientBackground(isDark),
        _buildBackgroundCircles(isDark),
        child,
      ],
    );
  }

  Widget _buildGradientBackground(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : AppColors.lightBackground, // سوداء/بيضاء
      ),
    );
  }

  Widget _buildBackgroundCircles(bool isDark) {
    final orangeOpacity = isDark ? 0x66 : 0x4D; // opacity أعلى في dark
    final gradient = LinearGradient(
      colors: [
        Color(orangeOpacity | 0xFFFF7043), // برتقالي شفاف
        Color(orangeOpacity | 0xFFFFA500), // برتقالي أفتح
      ],
    );
    return Stack(
      children: [
        Positioned(
          top: -100,
          right: -80,
          child: _buildCircle(250, gradient),
        ),
        Positioned(
          top: 80,
          right: 30,
          child: _buildCircle(100, gradient),
        ),
        Positioned(
          top: 120,
          left: -50,
          child: _buildCircle(160, gradient),
        ),
        Positioned(
          bottom: -60,
          left: -60,
          child: _buildCircle(200, gradient),
        ),
        Positioned(
          bottom: 100,
          right: -40,
          child: _buildCircle(140, gradient),
        ),
      ],
    );
  }

  Widget _buildCircle(double size, Gradient gradient) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, gradient: gradient),
    );
  }
}