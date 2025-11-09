import 'package:ezbuy/pages/product_page/product_list_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; 
import '../widgets/auth_background.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/gradient_button.dart';
import '../utils/validators.dart';
import 'signup_screen.dart';
import 'auth_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/google_signin_button.dart'; 

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      authServiceNotifier.value
          .signInWithEmail(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          )
          .then((user) {
            if (user != null) {
              _showSnackBar('Login Successful!', Colors.green);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProductListPage(isLoggedIn: true),
                ),
                    (Route<dynamic> route) => false,
              );
            } else {
              _showSnackBar('Login Failed. Please try again.', Colors.red);
            }
          });
    } else {
      _showSnackBar('Please fill in all fields correctly', Colors.red);
    }
  }


  void _signInWithGoogle() async {
    final user = await authServiceNotifier.value.signInWithGoogle();
    
    if (user != null) {
      _showSnackBar('Login Successful with Google!', Colors.green);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductListPage(isLoggedIn: true),
        ),
      );
    } else {
      _showSnackBar('Google Sign-In cancelled or failed', Colors.red);
    }
  }
 

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins(fontSize: 16)),
        backgroundColor: color,
      ),
    );
  }

  void _navigateToSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SignUpScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 40),
                _buildAvatar(),
                const SizedBox(height: 30),
                _buildHeader(),
                const SizedBox(height: 40),
                _buildEmailField(),
                const SizedBox(height: 20),
                _buildPasswordField(),
                const SizedBox(height: 10),
                _buildForgotPassword(),
                const SizedBox(height: 20),
                _buildSignInButton(),
                
               
                GoogleSignInButton(
                  onPressed: _signInWithGoogle,
                  buttonText: 'Continue with Google',
                  showDivider: true,
                ),
                
                
                const SizedBox(height: 30),
                _buildSignUpPrompt(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return CircleAvatar(
      radius: 50,
      backgroundColor: Colors.grey[200],
      child: ClipOval(
        child: Image.asset(
          'assets/images/EB_LOGO.png',
          width: 110,
          height: 110,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          "Welcome Back",
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 38,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          "Sign in to continue your journey",
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
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

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () => _showResetPasswordSheet(context),
        child: Text(
          "Forgot Password?",
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w500,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }

  Widget _buildSignInButton() {
    return GradientButton(text: "Log In", onPressed: _submitForm);
  }

  Widget _buildSignUpPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account?",
          style: GoogleFonts.poppins(color: Colors.black, fontSize: 16),
        ),
        TextButton(
          onPressed: _navigateToSignUp,
          child: Text(
            "Sign Up",
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontSize: 17,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}

void _showResetPasswordSheet(context) {
  showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
    ),
    builder: (context) {
      final emailController = TextEditingController();

      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Reset Password",
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 14),
            CustomTextField(
              controller: emailController,
              hint: "Enter your email",
              icon: Icons.email,
            ),
            SizedBox(height: 20),
            GradientButton(
              text: "Send Reset Link",
              fontSize: 20,
              onPressed: () async {
                final email = emailController.text.trim();
                await authServiceNotifier.value.sendPasswordResetEmail(email);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Reset email sent!", style: GoogleFonts.poppins(fontSize: 18)),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
            SizedBox(height: 14),
          ],
        ),
      );
    },
  );
}
