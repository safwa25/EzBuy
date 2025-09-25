import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  void _submit() {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Account created successfully"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // close dialog
                Navigator.pushReplacementNamed(context, '/home');
              },
              child: const Text("Close"),
            ),
          ],
        ),
      );
    }
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) return "Enter your name";
    if (value[0] != value[0].toUpperCase()) return "First letter must be uppercase";
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || !value.contains('@')) return "Enter a valid email";
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.length < 6) return "Password must be at least 6 characters";
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value != _passwordController.text) return "Passwords do not match";
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6C4E31), Color(0xFFBAC8E0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.50,
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.symmetric(horizontal: 100),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 12,
                      offset: const Offset(2, 4),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                          controller: _nameController,
                          validator: _validateName,
                          decoration: const InputDecoration(
                              labelText: "Full Name",
                              hintText: "Enter your full name",
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(20))
                              ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Color(0xFF6C4E31),
                                width: 2,
                              ),
                            ),

                          )),
                      const SizedBox(height: 16),

                      TextFormField(
                          controller: _emailController,
                          validator: _validateEmail,
                          decoration: const InputDecoration(
                            labelText: "Email",
                            hintText: "Enter your email",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(20))
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Color(0xFF6C4E31),
                                width: 2,
                              ),
                            ),
                          )
                      ),
                      const SizedBox(height: 16),
                      TextFormField(controller: _passwordController,
                          validator: _validatePassword,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: "Full Name",
                            hintText: "Enter your full name",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(20))
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Color(0xFF6C4E31),
                                width: 2,
                              ),
                            ),
                          )
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                          controller: _confirmPasswordController,
                          validator: _validateConfirmPassword,
                          obscureText: true,
                          decoration:  const InputDecoration(
                            labelText: "Full Name",
                            hintText: "Enter your full name",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(20))
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Color(0xFF6C4E31),
                                width: 2,
                              ),
                            ),
                          )
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(onPressed: _submit, style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C4E31),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all( 14),
                      ),
                          child: const Text("Sign Up"
                            , style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Colors.white))),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
    );
  }
}
