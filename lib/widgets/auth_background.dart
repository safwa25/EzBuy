import 'package:flutter/material.dart';

class AuthBackground extends StatelessWidget {
  final Widget child;

  const AuthBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _buildGradientBackground(),
        _buildBackgroundCircles(),
        child,
      ],
    );
  }

  Widget _buildGradientBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF2A2E7A),
            Color(0xFF4A3C8C),
            Color(0xFF3E8EDE),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }

  Widget _buildBackgroundCircles() {
    return Stack(
      children: [
        Positioned(
          top: -100,
          right: -80,
          child: _buildCircle(250, const Color(0x33A3A3FF)),
        ),
        Positioned(
          top: 80,
          right: 30,
          child: _buildCircle(100, const Color(0x1AFFFFFF)),
        ),
        Positioned(
          top: 120,
          left: -50,
          child: _buildCircle(160, const Color(0x33A3A3FF)),
        ),
        Positioned(
          bottom: -60,
          left: -60,
          child: _buildCircle(200, const Color(0x1AFFFFFF)),
        ),
        Positioned(
          bottom: 100,
          right: -40,
          child: _buildCircle(140, const Color(0x33A3A3FF)),
        ),
      ],
    );
  }

  Widget _buildCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}