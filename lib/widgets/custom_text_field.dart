import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final VoidCallback? onToggleVisibility;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.onToggleVisibility,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: TextStyle(color: isDark ? Colors.white : const Color.fromARGB(255, 44, 43, 43)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:  TextStyle(color: isDark ? Colors.white : const Color.fromARGB(255, 44, 43, 43)),
        prefixIcon: Icon(icon, color: Color.fromARGB(255, 44, 43, 43)),
        suffixIcon: _buildSuffixIcon(isDark),
        filled: true,
        // ignore: deprecated_member_use
        fillColor: const Color.fromARGB(255, 168, 167, 167).withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      validator: validator,
    );
  }

  Widget? _buildSuffixIcon(isDark) {
    if (onToggleVisibility == null) return null;

    return IconButton(
      icon: Icon(
        obscureText ? Icons.visibility_off : Icons.visibility,
        color: isDark ? Colors.white : Colors.black,
      ),
      onPressed: onToggleVisibility,
    );
  }
}