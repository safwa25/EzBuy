import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GoogleSignInButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String buttonText;
  final bool showDivider;
  final bool isDark; 

  const GoogleSignInButton({
    super.key,
    required this.onPressed,
    this.buttonText = 'Continue with Google',
    this.showDivider = true,
    this.isDark = false, 
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : Colors.black87; 
    final borderColor = isDark ? Colors.white.withOpacity(0.5) : const Color.fromARGB(255, 221, 221, 221);
    final buttonBgColor = isDark ? Colors.black.withOpacity(0.2) : Colors.transparent;

    return Column(
      children: [
        if (showDivider) ...[
          const SizedBox(height: 20),
          _buildDividerWithText(isDark),
          const SizedBox(height: 20),
        ],
        _buildGoogleButton(isDark, textColor, borderColor, buttonBgColor),
      ],
    );
  }

  Widget _buildDividerWithText(bool isDark) {
    final dividerColor = isDark ? Colors.white.withOpacity(0.3) : Colors.grey[400]!; 
    final orTextColor = isDark ? Colors.white70 : Colors.grey[600]!; 

    return Row(
      children: [
        Expanded(child: Divider(color: dividerColor, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "OR",
            style: GoogleFonts.poppins(
              color: orTextColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(child: Divider(color: dividerColor, thickness: 1)),
      ],
    );
  }

  Widget _buildGoogleButton(bool isDark, Color textColor, Color borderColor, Color buttonBgColor) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        side: BorderSide(color: borderColor, width: 1), 
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: buttonBgColor, 
        minimumSize: const Size(double.infinity, 56),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/google-logo.png',
            height: 30,
            width: 30,
            errorBuilder: (context, error, stackTrace) {
              return Icon(Icons.error, size: 28, color: textColor); 
            },
          ),
          const SizedBox(width: 12),
          Expanded( 
            child: Text(
              buttonText,
              style: GoogleFonts.poppins(
                color: textColor, 
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}