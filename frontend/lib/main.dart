import 'package:flutter/material.dart';
import 'pages/login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Honkai Star Retail',
      debugShowCheckedModeBanner: false,

      // =============================================
      // THEME CUSTOMIZATION (4 properties changed)
      // 1. colorScheme  - purple/gold space theme
      // 2. scaffoldBackgroundColor - dark background
      // 3. fontFamily - changed to Segoe UI
      // 4. appBarTheme - custom AppBar styling
      // =============================================
      theme: ThemeData(
        // 1) Color Scheme
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF7B61FF),   // Purple
          secondary: const Color(0xFFFFB74D), // Gold
          surface: const Color(0xFF1E1E2E),
        ),

        // 2) Background Color
        scaffoldBackgroundColor: const Color(0xFF13131F),

        // 3) Font Family
        fontFamily: 'Segoe UI',

        // 4) AppBar Theme
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E2E),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),

        // Button style
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF7B61FF),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        // TextField style
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF2A2A3E),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          hintStyle: TextStyle(color: Colors.grey[500]),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),

        // Card style
        cardTheme: CardThemeData(
          color: const Color(0xFF1E1E2E),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      home: const LoginPage(),
    );
  }
}
