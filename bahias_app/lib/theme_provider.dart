import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleTheme() {
    _themeMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }
}

final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF0B0F0B),
  cardColor: const Color(0xFF1E2420),
  dialogBackgroundColor: const Color(0xFF1E2420),
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF2ECC71),   // verde
    secondary: Color(0xFFFFC107), // amarillo
    tertiary: Color(0xFF42A5F5),  // azul
  ),
);

final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  scaffoldBackgroundColor: const Color(0xFFF5F5F5), // gris muy claro
  cardColor: Colors.white.withOpacity(0.95),
  dialogBackgroundColor: Colors.white.withOpacity(0.92),
  colorScheme: const ColorScheme.light(
    primary: Color(0xFF2ECC71),
    secondary: Color(0xFFFFC107),
    tertiary: Color(0xFF42A5F5),
  ),
  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: Colors.black87),
    bodySmall: TextStyle(color: Colors.black87),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: Colors.black,
    elevation: 0.5,
  ),
);