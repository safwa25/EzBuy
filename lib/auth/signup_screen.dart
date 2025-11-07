import 'package:ezbuy/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; 
import '../widgets/auth_background.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/gradient_button.dart';
import '../utils/validators.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_services.dart';
import '../widgets/google_signin_button.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submitSignUp() {
    if (!_acceptTerms) {
      _showSnackBar("You must accept the terms.", Colors.red);
      return;
    }

    if (_formKey.currentState!.validate()) {
      authServiceNotifier.value
          .registerWithEmail(
            _emailController.text.trim(),
            _passwordController.text.trim(),
            fullName: _fullNameController.text.trim(),
            phone: _phoneController.text.trim(),
          )
          .then((user) {
            if (user is User) {
              _showSnackBar("Account created successfully!", Colors.green);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            }else if (user is String) {
              _showSnackBar(user, Colors.red);
            }
            else {
              _showSnackBar("Sign up failed. Please try again.", Colors.red);
            }
          });
    }
  }


  void _signUpWithGoogle() async {
    try {
      final user = await authServiceNotifier.value.signInWithGoogle();

      if (user != null) {
        if (mounted) {
          _showSnackBar('Account created successfully with Google!', Colors.green);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      } else {
        if (mounted) {
          _showSnackBar('Google Sign-Up cancelled or failed', Colors.red);
        }
      }
    } catch (e) {
      print('Error in _signUpWithGoogle: $e');
      if (mounted) {
        _showSnackBar('An error occurred. Please try again.', Colors.red);
      }
    }
  }
  

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(fontSize: 16),
        ),
        backgroundColor: color,
      ),
    );
  }

  String? _validateConfirmPassword(String? value) {
    if (value != _passwordController.text) {
      return 'Passwords don\'t match';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 50),
                _buildEmailField(),
                const SizedBox(height: 20),
                _buildPasswordField(),
                const SizedBox(height: 20),
                _buildConfirmPasswordField(),
                const SizedBox(height: 20),
                _buildFullNameField(),
                const SizedBox(height: 20),
                _buildPhoneField(),
                const SizedBox(height: 20),
                _buildTermsCheckbox(),
                const SizedBox(height: 30),
                _buildSignUpButton(),

                GoogleSignInButton(
                  onPressed: _signUpWithGoogle,
                  buttonText: 'Sign Up with Google',
                  showDivider: true,
                ),
                

                const SizedBox(height: 35),
                _buildLoginPrompt(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Center(
      child: Column(
        children: [
          Text(
            "Create Account",
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontSize: 38,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Sign up to get started",
            style: GoogleFonts.poppins(
              color: Colors.black87,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullNameField() {
    return CustomTextField(
      controller: _fullNameController,
      hint: "Full Name",
      icon: Icons.person,
      validator: Validators.validateName,
    );
  }

  Widget _buildPhoneField() {
    return CustomTextField(
      controller: _phoneController,
      hint: "Phone Number",
      icon: Icons.phone,
      keyboardType: TextInputType.phone,
      validator: Validators.validatePhone,
    );
  }

  Widget _buildEmailField() {
    return CustomTextField(
      controller: _emailController,
      hint: "Email Address",
      icon: Icons.email,
      validator: Validators.validateEmail,
    );
  }

  Widget _buildPasswordField() {
    return CustomTextField(
      controller: _passwordController,
      hint: "Password",
      icon: Icons.lock,
      obscureText: _obscurePassword,
      onToggleVisibility: () {
        setState(() => _obscurePassword = !_obscurePassword);
      },
      validator: Validators.validatePassword,
    );
  }

  Widget _buildConfirmPasswordField() {
    return CustomTextField(
      controller: _confirmPasswordController,
      hint: "Confirm Password",
      icon: Icons.lock,
      obscureText: _obscureConfirmPassword,
      onToggleVisibility: () {
        setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
      },
      validator: _validateConfirmPassword,
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: _acceptTerms,
          onChanged: (value) => setState(() => _acceptTerms = value ?? false),
          checkColor: Colors.white,
          activeColor: Colors.deepPurple,
        ),
        Expanded(
          child: Text(
            "I accept the Terms and Conditions",
            style: GoogleFonts.poppins(
              color: Colors.black87,
              fontSize: 18,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpButton() {
    return GradientButton(
      text: "Sign Up",
      onPressed: _submitSignUp,
      gradientColors: const [Color(0xFF884ED9), Color(0xFF3FA9F5)],
    );
  }

  Widget _buildLoginPrompt() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Already have an account? ",
            style: GoogleFonts.poppins(
              color: Colors.black87,
              fontSize: 18,
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            ),
            child: Text(
              "Log In",
              style: GoogleFonts.poppins(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
                decorationThickness: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}