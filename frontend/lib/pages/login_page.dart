// import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:google_sign_in/google_sign_in.dart';
// import '../session.dart';
// import 'register_page.dart';
// import 'home_page.dart';

// class LoginPage extends StatefulWidget {
//   const LoginPage({super.key});

//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   // UI COMPONENT: TextField controllers
//   final emailController = TextEditingController();
//   final passwordController = TextEditingController();
//   String errorMessage = '';
//   bool isLoading = false;

//   // =============================================
//   // VALIDATION 1: Check if email/password is empty
//   // =============================================
//   bool validateInputs() {
//     if (emailController.text.trim().isEmpty) {
//       setState(() => errorMessage = 'Email cannot be empty');
//       return false;
//     }
//     if (passwordController.text.trim().isEmpty) {
//       setState(() => errorMessage = 'Password cannot be empty');
//       return false;
//     }
//     return true;
//   }

//   // Standard Login (uses user stored in DB)
//   Future<void> login() async {
//     if (!validateInputs()) return;

//     setState(() {
//       isLoading = true;
//       errorMessage = '';
//     });

//     try {
//       final response = await http.post(
//         Uri.parse('${Session.baseUrl}/auth/login'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'email': emailController.text.trim(),
//           'password': passwordController.text.trim(),
//         }),
//       );

//       final data = jsonDecode(response.body);

//       if (response.statusCode == 200) {
//         // Save session info
//         Session.token = data['token'];
//         Session.role = data['role'];
//         Session.name = data['name'];
//         Session.email = emailController.text.trim();

//         if (!mounted) return;
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (_) => const HomePage()),
//         );
//       } else {
//         setState(() => errorMessage = data['error'] ?? 'Login failed');
//       }
//     } catch (e) {
//       setState(() => errorMessage = 'Cannot connect to server');
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }

//   // External OAuth: Google Sign-In
//   Future<void> googleLogin() async {
//     setState(() {
//       isLoading = true;
//       errorMessage = '';
//     });

//     try {
//       final googleSignIn = GoogleSignIn();
//       final account = await googleSignIn.signIn();

//       if (account == null) {
//         setState(() {
//           isLoading = false;
//           errorMessage = 'Google sign-in cancelled';
//         });
//         return;
//       }

//       // Send Google info to backend
//       final response = await http.post(
//         Uri.parse('${Session.baseUrl}/auth/google'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'email': account.email,
//           'name': account.displayName ?? account.email,
//         }),
//       );

//       final data = jsonDecode(response.body);

//       if (response.statusCode == 200) {
//         Session.token = data['token'];
//         Session.role = data['role'];
//         Session.name = data['name'];
//         Session.email = account.email;

//         if (!mounted) return;
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (_) => const HomePage()),
//         );
//       } else {
//         setState(() => errorMessage = data['error'] ?? 'Google login failed');
//       }
//     } catch (e) {
//       setState(() => errorMessage = 'Google sign-in failed: $e');
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(32),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               // App icon
//               Icon(
//                 Icons.rocket_launch,
//                 size: 80,
//                 color: Theme.of(context).colorScheme.primary,
//               ),
//               const SizedBox(height: 16),

//               // UI COMPONENT: Text
//               Text(
//                 'Honkai Star Retail',
//                 style: TextStyle(
//                   fontSize: 28,
//                   fontWeight: FontWeight.bold,
//                   color: Theme.of(context).colorScheme.primary,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 'Login to your account',
//                 style: TextStyle(fontSize: 16, color: Colors.grey[400]),
//               ),
//               const SizedBox(height: 32),

//               // Error message
//               if (errorMessage.isNotEmpty)
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   margin: const EdgeInsets.only(bottom: 16),
//                   decoration: BoxDecoration(
//                     color: Colors.red.withAlpha(30),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Text(
//                     errorMessage,
//                     style: const TextStyle(color: Colors.redAccent),
//                   ),
//                 ),

//               // UI COMPONENT: TextField (Email)
//               TextField(
//                 controller: emailController,
//                 style: const TextStyle(color: Colors.white),
//                 decoration: const InputDecoration(
//                   hintText: 'Email',
//                   prefixIcon: Icon(Icons.email, color: Colors.grey),
//                 ),
//               ),
//               const SizedBox(height: 16),

//               // UI COMPONENT: TextField (Password)
//               TextField(
//                 controller: passwordController,
//                 obscureText: true,
//                 style: const TextStyle(color: Colors.white),
//                 decoration: const InputDecoration(
//                   hintText: 'Password',
//                   prefixIcon: Icon(Icons.lock, color: Colors.grey),
//                 ),
//               ),
//               const SizedBox(height: 24),

//               // UI COMPONENT: ElevatedButton (Login)
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: isLoading ? null : login,
//                   child:
//                       isLoading
//                           ? const SizedBox(
//                             height: 20,
//                             width: 20,
//                             child: CircularProgressIndicator(
//                               strokeWidth: 2,
//                               color: Colors.white,
//                             ),
//                           )
//                           : const Text('Login', style: TextStyle(fontSize: 16)),
//                 ),
//               ),
//               const SizedBox(height: 16),

//               // Google Sign-In Button (External OAuth)
//               SizedBox(
//                 width: double.infinity,
//                 child: OutlinedButton.icon(
//                   onPressed: isLoading ? null : googleLogin,
//                   icon: const Icon(Icons.g_mobiledata, size: 28),
//                   label: const Text('Sign in with Google'),
//                   style: OutlinedButton.styleFrom(
//                     foregroundColor: Colors.white,
//                     side: BorderSide(color: Colors.grey[600]!),
//                     padding: const EdgeInsets.symmetric(vertical: 14),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 24),

//               // Link to Register page
//               TextButton(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (_) => const RegisterPage()),
//                   );
//                 },
//                 child: Text(
//                   "Don't have an account? Register",
//                   style: TextStyle(
//                     color: Theme.of(context).colorScheme.secondary,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


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

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  // ── Controllers (dari kode lama) ───────────────────────────
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  // ── State dari kode baru ───────────────────────────────────
  String _errorMessage = '';
  bool _isLoading = false;

  // ── Animasi (dari kode lama) ───────────────────────────────
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.10),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ── Validasi (gabungan kode lama + baru) ──────────────────
  bool _validateInputs() {
    if (_emailController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Email wajib diisi');
      return false;
    }
    if (!_emailController.text.contains('@')) {
      setState(() => _errorMessage = 'Format email tidak valid');
      return false;
    }
    if (_passwordController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Password wajib diisi');
      return false;
    }
    return true;
  }

  // ── Login ke backend (dari kode baru) ─────────────────────
  Future<void> _onSignIn() async {
    if (!_validateInputs()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await http.post(
        Uri.parse('${Session.baseUrl}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text.trim(),
          'password': _passwordController.text.trim(),
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        Session.token = data['token'];
        Session.role = data['role'];
        Session.name = data['name'];
        Session.email = _emailController.text.trim();

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      } else {
        setState(() => _errorMessage = data['error'] ?? 'Login gagal');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Tidak bisa terhubung ke server');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ── Google Sign-In (dari kode baru) ───────────────────────
  Future<void> _googleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final googleSignIn = GoogleSignIn();
      final account = await googleSignIn.signIn();

      if (account == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Google sign-in dibatalkan';
        });
        return;
      }

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
        setState(() => _errorMessage = data['error'] ?? 'Google login gagal');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Google sign-in gagal: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Galaxy background (kode lama) ──────────────────
          Image.asset(
            'assets/images/galaxy_bg.png',
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),

          // ── Scrollable content ─────────────────────────────
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding:
                  const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 28),

                      // ── Logo (kode lama) ────────────────────
                      Transform.translate(
                        offset: const Offset(0, -30),
                        child: Image.asset(
                          'assets/images/honkai_logo.png',
                          height: 139,
                          width: 282,
                          fit: BoxFit.contain,
                        ),
                      ),

                      const SizedBox(height: 36),

                      // ── Form card (kode lama) ───────────────
                      Center(
                        child: SizedBox(
                          width: 358,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF6D6598).withOpacity(0.22),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.7),
                                  offset: const Offset(0, 4),
                                  blurRadius: 12,
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 22, vertical: 24),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [

                                  // ── Heading ──────────────────
                                  Center(
                                    child: Column(
                                      children: const [
                                        Text(
                                          'Welcome Back',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                        SizedBox(height: 2),
                                        Text(
                                          'Sign in to Continue Your Game Top Up Experience',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 8,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 20),

                                  // ── Error message (dari kode baru) ──
                                  if (_errorMessage.isNotEmpty)
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 8),
                                      margin:
                                          const EdgeInsets.only(bottom: 12),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.15),
                                        borderRadius:
                                            BorderRadius.circular(10),
                                        border: Border.all(
                                          color: const Color(0xFFFF6B6B),
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        _errorMessage,
                                        style: const TextStyle(
                                          color: Color(0xFFFF6B6B),
                                          fontSize: 12,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),

                                  // ── Email ────────────────────
                                  const _FieldLabel('Email'),
                                  const SizedBox(height: 6),
                                  Center(
                                    child: SizedBox(
                                      width: 314,
                                      height: 34,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withOpacity(0.25),
                                              offset: const Offset(0, 4),
                                              blurRadius: 12,
                                            ),
                                          ],
                                        ),
                                        child: _StarRailField(
                                          controller: _emailController,
                                          hint: 'Enter your email',
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          validator: (v) {
                                            if (v == null || v.isEmpty)
                                              return 'Email wajib diisi';
                                            if (!v.contains('@'))
                                              return 'Format email tidak valid';
                                            return null;
                                          },
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 40),

                                  // ── Password ──────────────────
                                  const _FieldLabel('Password'),
                                  const SizedBox(height: 6),
                                  Center(
                                    child: SizedBox(
                                      width: 314,
                                      height: 34,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withOpacity(0.25),
                                              offset: const Offset(0, 4),
                                              blurRadius: 12,
                                            ),
                                          ],
                                        ),
                                        child: _StarRailField(
                                          controller: _passwordController,
                                          hint: 'Enter your password',
                                          obscure: _obscurePassword,
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _obscurePassword
                                                  ? Icons
                                                      .visibility_off_outlined
                                                  : Icons.visibility_outlined,
                                              color: Colors.white,
                                              size: 18,
                                            ),
                                            onPressed: () => setState(() =>
                                                _obscurePassword =
                                                    !_obscurePassword),
                                          ),
                                          validator: (v) {
                                            if (v == null || v.isEmpty)
                                              return 'Password wajib diisi';
                                            return null;
                                          },
                                        ),
                                      ),
                                    ),
                                  ),

                                  // ── Create Account / Forgot Password ──
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      GestureDetector(
                                        onTap: () =>
                                            Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) => const RegisterPage()),
                                        ),
                                        child: const Text(
                                          'Create Account',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {},
                                        child: const Text(
                                          'Forgot Password?',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 20),

                                  // ── Sign In button ────────────
                                  SizedBox(
                                    width: double.infinity,
                                    height: 52,
                                    child: ElevatedButton(
                                      onPressed:
                                          _isLoading ? null : _onSignIn,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor:
                                            const Color(0xFF6D6598),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                        ),
                                        elevation: 6,
                                        shadowColor:
                                            Colors.black.withOpacity(0.6),
                                      ),
                                      // Loading spinner saat proses login
                                      child: _isLoading
                                          ? const SizedBox(
                                              height: 20,
                                              width: 20,
                                              child:
                                                  CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Color(0xFF6D6598),
                                              ),
                                            )
                                          : const Text(
                                              'Sign In',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 16,
                                              ),
                                            ),
                                    ),
                                  ),

                                  const SizedBox(height: 20),

                                  // ── Social login divider ───────
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Divider(
                                            color: Colors.white
                                                .withOpacity(0.18)),
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 12),
                                        child: Text(
                                          'or continue with',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12),
                                        ),
                                      ),
                                      Expanded(
                                        child: Divider(
                                            color: Colors.white
                                                .withOpacity(0.18)),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 16),

                                  // ── Social buttons ─────────────
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      // Google → sudah connect ke _googleLogin
                                      _SocialBtn(
                                        label: 'assets/images/google.png',
                                        color: Colors.transparent,
                                        onTap: _isLoading
                                            ? () {}
                                            : _googleLogin,
                                      ),
                                      const SizedBox(width: 30),
                                      _SocialBtn(
                                        label: 'assets/images/facebook.png',
                                        color: Colors.transparent,
                                        onTap: () {},
                                      ),
                                      const SizedBox(width: 30),
                                      _SocialBtn(
                                        label: 'assets/images/twitter.png',
                                        color: Colors.transparent,
                                        onTap: () {},
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Shared widgets (kode lama, tidak diubah)
// ─────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _StarRailField extends StatelessWidget {
  const _StarRailField({
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.obscure = false,
    this.suffixIcon,
    this.validator,
  });

  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final bool obscure;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white, fontSize: 13),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFF6D6598),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Colors.white),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide:
              const BorderSide(color: Color(0xFFFFFEFC), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide:
              const BorderSide(color: Color(0xFFFF6B6B), width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide:
              const BorderSide(color: Color(0xFFFF6B6B), width: 1.5),
        ),
      ),
    );
  }
}

class _SocialBtn extends StatelessWidget {
  const _SocialBtn({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.45),
              offset: const Offset(0, 5),
              blurRadius: 14,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Container(
          width: 52,
          height: 52,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Image.asset(
              label,
              width: label.contains('google') ? 24 : 32,
              height: label.contains('google') ? 24 : 32,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}