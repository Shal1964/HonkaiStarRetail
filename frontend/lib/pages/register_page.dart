import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../session.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String errorMessage = '';
  String successMessage = '';
  bool isLoading = false;

  Future<void> register() async {
    // Simple validation
    if (nameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      setState(() => errorMessage = 'All fields are required');
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = '';
      successMessage = '';
    });

    try {
      final response = await http.post(
        Uri.parse('${Session.baseUrl}/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': nameController.text.trim(),
          'email': emailController.text.trim(),
          'password': passwordController.text.trim(),
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() => successMessage = 'Registration successful! You can now login.');
      } else {
        setState(() => errorMessage = data['error'] ?? 'Registration failed');
      }
    } catch (e) {
      setState(() => errorMessage = 'Cannot connect to server');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.person_add,
                size: 60,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Create Account',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 32),

              // Error message
              if (errorMessage.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.withAlpha(30),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(errorMessage, style: const TextStyle(color: Colors.redAccent)),
                ),

              // Success message
              if (successMessage.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.green.withAlpha(30),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(successMessage, style: const TextStyle(color: Colors.greenAccent)),
                ),

              // Name field
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Name',
                  prefixIcon: Icon(Icons.person, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16),

              // Email field
              TextField(
                controller: emailController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Email',
                  prefixIcon: Icon(Icons.email, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16),

              // Password field
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

              // Register button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : register,
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Register', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 16),

              // Back to login
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Already have an account? Login',
                  style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
