import 'package:flutter/material.dart';

final lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  scaffoldBackgroundColor: const Color(0xFFF1F3F2),
  colorScheme: const ColorScheme.light(
    primary: Color(0xFF2ECC71),   // verde institucional
    secondary: Color(0xFFFFC107), // amarillo
    tertiary: Color(0xFF42A5F5),  // azul
    surface: Color(0xFFECEFF1),
    background: Color(0xFFF1F3F2),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFFECEFF1),
    foregroundColor: Colors.black87,
    elevation: 0,
  ),
  cardColor: const Color(0xFFFFFFFF),
  listTileTheme: const ListTileThemeData(
    textColor: Colors.black87,
    iconColor: Color(0xFF2ECC71),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(0xFF2ECC71),
      foregroundColor: Colors.white,
    ),
  ),
);
