import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import '../session.dart';
import 'register_page.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // UI COMPONENT: TextField controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String errorMessage = '';
  bool isLoading = false;

  // =============================================
  // VALIDATION 1: Check if email/password is empty
  // =============================================
  bool validateInputs() {
    if (emailController.text.trim().isEmpty) {
      setState(() => errorMessage = 'Email cannot be empty');
      return false;
    }
    if (passwordController.text.trim().isEmpty) {
      setState(() => errorMessage = 'Password cannot be empty');
      return false;
    }
    return true;
  }

  // Standard Login (uses user stored in DB)
  Future<void> login() async {
    if (!validateInputs()) return;

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.post(
        Uri.parse('${Session.baseUrl}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': emailController.text.trim(),
          'password': passwordController.text.trim(),
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Save session info
        Session.token = data['token'];
        Session.role = data['role'];
        Session.name = data['name'];
        Session.email = emailController.text.trim();

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      } else {
        setState(() => errorMessage = data['error'] ?? 'Login failed');
      }
    } catch (e) {
      setState(() => errorMessage = 'Cannot connect to server');
    } finally {
      setState(() => isLoading = false);
    }
  }

  // External OAuth: Google Sign-In
  Future<void> googleLogin() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final googleSignIn = GoogleSignIn();
      final account = await googleSignIn.signIn();

      if (account == null) {
        setState(() {
          isLoading = false;
          errorMessage = 'Google sign-in cancelled';
        });
        return;
      }

      // Send Google info to backend
      final response = await http.post(
        Uri.parse('${Session.baseUrl}/auth/google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': account.email,
          'name': account.displayName ?? account.email,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        Session.token = data['token'];
        Session.role = data['role'];
        Session.name = data['name'];
        Session.email = account.email;

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      } else {
        setState(() => errorMessage = data['error'] ?? 'Google login failed');
      }
    } catch (e) {
      setState(() => errorMessage = 'Google sign-in failed: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App icon
              Icon(
                Icons.rocket_launch,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),

              // UI COMPONENT: Text
              Text(
                'Honkai Star Retail',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Login to your account',
                style: TextStyle(fontSize: 16, color: Colors.grey[400]),
              ),
              const SizedBox(height: 32),

              // Error message
              if (errorMessage.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.withAlpha(30),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ),

              // UI COMPONENT: TextField (Email)
              TextField(
                controller: emailController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Email',
                  prefixIcon: Icon(Icons.email, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16),

              // UI COMPONENT: TextField (Password)
              TextField(
                controller: passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Password',
                  prefixIcon: Icon(Icons.lock, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 24),

              // UI COMPONENT: ElevatedButton (Login)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : login,
                  child:
                      isLoading
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : const Text('Login', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 16),

              // Google Sign-In Button (External OAuth)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: isLoading ? null : googleLogin,
                  icon: const Icon(Icons.g_mobiledata, size: 28),
                  label: const Text('Sign in with Google'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.grey[600]!),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Link to Register page
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterPage()),
                  );
                },
                child: Text(
                  "Don't have an account? Register",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
