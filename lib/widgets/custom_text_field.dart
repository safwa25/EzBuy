import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final VoidCallback? onToggleVisibility;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final bool isDark;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.onToggleVisibility,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    
    final textColor = isDark ? Colors.white : const Color.fromARGB(255, 44, 43, 43);
    final hintColor = isDark ? Colors.white70 : const Color.fromARGB(255, 44, 43, 43);
    final iconColor = isDark ? Colors.white70 : const Color.fromARGB(255, 44, 43, 43);
    final fillColor = isDark ? Colors.white.withOpacity(0.1) : const Color.fromARGB(255, 168, 167, 167).withOpacity(0.1); 

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: TextStyle(color: textColor, fontSize: 16), 
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: hintColor, fontSize: 16), 
        prefixIcon: Icon(icon, color: iconColor, size: 24), 
        suffixIcon: _buildSuffixIcon(isDark),
        filled: true,
        fillColor: fillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
      validator: validator,
    );
  }

  Widget? _buildSuffixIcon(bool isDark) {
    if (onToggleVisibility == null) return null;

    final suffixIconColor = isDark ? Colors.white : Colors.black;

    return IconButton(
      icon: Icon(
        obscureText ? Icons.visibility_off : Icons.visibility,
        color: suffixIconColor,
        size: 24,
      ),
      onPressed: onToggleVisibility,
    );
  }
}