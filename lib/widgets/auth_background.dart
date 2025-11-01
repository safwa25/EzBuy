import 'package:flutter/material.dart';

class AuthBackground extends StatelessWidget {
  final Widget child;

  const AuthBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [_buildGradientBackground(), _buildBackgroundCircles(), child],
    );
  }

  Widget _buildGradientBackground() {
    return Container(decoration: const BoxDecoration(color: Color(0xFFF8F9FB)));
  }

  Widget _buildBackgroundCircles() {
    return Stack(
      children: [
        Positioned(
          top: -100,
          right: -80,
          child: _buildCircle(
            250,
            const LinearGradient(
              colors: [
                Color(0x4D0033FF), // أزرق #0033FF شفاف
                Color(0x4D666666), // رمادي #666666 شفاف
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        Positioned(
          top: 80,
          right: 30,
          child: _buildCircle(
            100,
            const LinearGradient(
              colors: [
                Color(0x4D0033FF), // أزرق #0033FF شفاف
                Color(0x4D666666), // رمادي #666666 شفاف// رمادي #666666 شفاف
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        Positioned(
          top: 120,
          left: -50,
          child: _buildCircle(
            160,
            const LinearGradient(
              colors: [
                Color(0x4D0033FF), // أزرق #0033FF شفاف
                Color(0x4D666666), // رمادي #666666 شفاف// رمادي #666666 شفاف
              ],
              begin: Alignment.bottomRight,
              end: Alignment.topLeft,
            ),
          ),
        ),
        Positioned(
          bottom: -60,
          left: -60,
          child: _buildCircle(
            200,
            const LinearGradient(
              colors: [
                Color(0x4D0033FF), // أزرق #0033FF شفاف
                Color(0x4D666666), // رمادي #666666 شفافف
              ],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
          ),
        ),
        Positioned(
          bottom: 100,
          right: -40,
          child: _buildCircle(
            140,
            const LinearGradient(
              colors: [
                Color(0x4D0033FF), // أزرق #0033FF شفاف
                Color(0x4D666666), // رمادي #666666 شفاف
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
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
