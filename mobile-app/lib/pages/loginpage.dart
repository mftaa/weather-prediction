import 'dart:convert';
import 'package:flutter/material.dart';
import 'variables.dart';
import '../services/api_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController =
      TextEditingController(text: "iot25");
  final TextEditingController _passwordController =
      TextEditingController(text: "123");
  bool _isLoading = false;
  bool _isPasswordObscured = true;

  void _login() async {
    setState(() {
      _isLoading = true;
    });

    // Simpan username ke variabel global (dari variables.dart)
    myUsername = _emailController.text;

    try {
      final response = await ApiService.post(
        '/auth/login',
        body: {
          'username': _emailController.text,
          'password': _passwordController.text,
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        final errorData = json.decode(response.body);
        _showErrorDialog(errorData.containsKey('detail')
            ? errorData['detail']
            : "Invalid login attempt");
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog("Failed to connect to the server. Please try again.");
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Oops!", style: TextStyle(color: Colors.redAccent)),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text("Try Again",
                  style: TextStyle(color: Color(0xFF5B9FE3))),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF5B9FE3), // Warna Biru Utama (Atas)
              Color(0xFF7AB8F5),
              Color(0xFFB8D4F0), // Warna Biru Muda (Bawah)
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // HEADER: LOGO & WELCOME TEXT
                  const Icon(
                    Icons.cloud_circle_rounded, // Icon yang lebih modern
                    size: 100,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Weather Station",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Sign in to continue",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // CARD PUTIH UNTUK FORM
                  Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          "Login",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 30),
                        _buildTextField(
                          controller: _emailController,
                          labelText: "Username",
                          prefixIcon: Icons.person_outline,
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          controller: _passwordController,
                          labelText: "Password",
                          prefixIcon: Icons.lock_outline,
                          isPassword: true,
                        ),
                        const SizedBox(height: 30),
                        _buildLoginButton(),
                        const SizedBox(height: 20),
                        _buildRegisterLink(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData prefixIcon,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? _isPasswordObscured : false,
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.grey[600]),
        prefixIcon: Icon(prefixIcon, color: const Color(0xFF5B9FE3)),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _isPasswordObscured
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.grey[400],
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordObscured = !_isPasswordObscured;
                  });
                },
              )
            : null,
        filled: true,
        fillColor: const Color(0xFFF5F6FA), // Warna abu sangat muda
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: const BorderSide(color: Color(0xFF5B9FE3), width: 1.5),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      height: 55,
      child: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF5B9FE3)))
          : ElevatedButton(
              onPressed: _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5B9FE3), // Warna utama tema
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                shadowColor: const Color(0xFF5B9FE3).withOpacity(0.5),
              ),
              child: const Text(
                'LOGIN',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: TextStyle(color: Colors.grey[600]),
        ),
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/reg');
          },
          child: const Text(
            'Register',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF5B9FE3),
            ),
          ),
        ),
      ],
    );
  }
}
