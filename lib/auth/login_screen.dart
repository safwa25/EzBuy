import 'package:ezbuy/pages/product_page/product_list_page.dart';
import 'package:ezbuy/pages/product_page/welcomescreen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; 
import '../widgets/auth_background.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/gradient_button.dart';
import '../utils/validators.dart';
import 'signup_screen.dart';
import 'auth_services.dart';
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

  void _continueAsGuest() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const Welcomescreen(isLoggedIn: false),
      ),
    );
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
                
                
                const SizedBox(height: 20),
                    _buildGuestLoginButton(),
                
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
        onPressed: () {},
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


  Widget _buildGuestLoginButton() {
    return OutlinedButton.icon(
      onPressed: _continueAsGuest,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        side: const BorderSide(color: Color.fromARGB(255, 225, 222, 222), width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        minimumSize: const Size(double.infinity, 56),
      ),
      icon: const Icon(
        Icons.person_outline,
        color: Colors.black87,
        size: 24,
      ),
      label: Text(
        "Continue AS a Guest",
        style: GoogleFonts.poppins(
          color: Colors.black87,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
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