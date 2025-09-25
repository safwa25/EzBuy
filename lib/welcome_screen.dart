import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login.dart';
import 'signup.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6C4E31), Color(0xFFBAC8E0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'PickUp',
                  style: GoogleFonts.suwannaphum(
                    fontSize: 60,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Your Best Shopping Partner Is Here',
                  style: GoogleFonts.suwannaphum(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildImageCard('assets/images/image2.jpg'),
                    const SizedBox(width: 40),
                    _buildImageCard(
                      "https://cdn.pixabay.com/photo/2019/10/07/12/08/online-shopping-4532460_1280.jpg",
                      isNetwork: true,
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildButton(context, 'Sign In', const Color(0xFF6C4E31), 'login'),
                      const SizedBox(width: 40),
                      _buildButton(context, 'Sign Up', const Color(0xFF6C4E31), 'signup'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

    );
  }
}

Widget _buildImageCard(String imagePath, {bool isNetwork = false}) {
  return _HoverScale(
    child: ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 310,
        height: 250,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: isNetwork
            ? Image.network(imagePath, fit: BoxFit.cover)
            : Image.asset(imagePath, fit: BoxFit.cover),
      ),
    ),
  );
}

Widget _buildButton(BuildContext context, String text, Color color, String route,
    {bool isOutlined = false}) {
  return _HoverScale(
    child: SizedBox(
      width: 150,
      height: 45,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isOutlined ? Colors.transparent : color,
          side: isOutlined ? const BorderSide(color: Colors.white, width: 2) : null,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: isOutlined ? 0 : 4,
        ),
        onPressed: (){
          if (route == 'login') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          } else if (route == 'signup') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) =>  SignUpScreen()),
            );
          }
        },
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
  );
}


class _HoverScale extends StatefulWidget {
  final Widget child;
  final double scale;

  const _HoverScale({Key? key, required this.child, this.scale = 1.05})
      : super(key: key);

  @override
  State<_HoverScale> createState() => _HoverScaleState();
}

class _HoverScaleState extends State<_HoverScale> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? widget.scale : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
