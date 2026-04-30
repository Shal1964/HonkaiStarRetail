// Simple session class to store login info across pages
class Session {
  static String token = '';
  static String role = ''; // 'user' or 'admin'
  static String name = '';
  static String email = '';

  // If run in Chrome -> 'http://localhost:3000'
  // If run in Android Emulator -> 'http://10.0.2.2:3000';
  // If run in Physical Device (e.g: your phone)  -> Use your PC local IP
  static const String baseUrl = 'http://10.0.2.2:3000';
}
