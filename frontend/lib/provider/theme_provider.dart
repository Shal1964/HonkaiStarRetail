import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  bool isDarkMode = false;

  void toggleTheme() {
    isDarkMode = !isDarkMode;
    notifyListeners();
  }

  Color get boxColor {
    return isDarkMode
        ? const Color(0xFF373C47).withOpacity(0.9) // dark mode
        : const Color(0xFF918EA1); // light mode
  }

  Color get textColor {
    return Colors.white;
  }

  List<Color> get cardGradient {
  return isDarkMode
      ? [
          const Color(0xFF2854C3).withOpacity(0.05),
          const Color(0xFF2854C3).withOpacity(0.05),
          const Color(0xFF2854C3).withOpacity(0.60),
        ]
      : [
          const Color(0xFFA13BCA).withOpacity(0.05),
          const Color(0xFFA13BCA).withOpacity(0.05),
          const Color(0xFFA13BCA).withOpacity(0.60),
        ];
}

Color get cardBottomBar {
  return isDarkMode
      ? const Color(0xFF2854C3).withOpacity(0.8)
      : const Color(0xFFA13BCA).withOpacity(0.8);
}

String get backgroundImage{
  return isDarkMode
      ? 'assets/images/galaxy_bg2.png'
      : 'assets/images/galaxy_bg.png';

}
Color get actionButtonColor {
  return isDarkMode
      ? const Color.fromARGB(255, 36, 63, 113).withValues(alpha: 0.8)
      : const Color(0xFF49369E);
}

Color get thumbnailBoxColor {
  return isDarkMode
      ? const Color(0xFF2854C3).withValues(alpha: 0.8)
      : const Color(0xFF6B4FA0);
}
}