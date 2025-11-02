import 'package:flutter/material.dart';

final lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,

  // 🎨 Fondo general
  scaffoldBackgroundColor: const Color(0xFFF6F7F6),

  colorScheme: const ColorScheme.light(
    primary: Color(0xFF28B463),   // verde más profundo (antes 2ECC71)
    secondary: Color(0xFFF1C40F), // amarillo cálido
    tertiary: Color(0xFF2980B9),  // azul más oscuro
    surface: Color(0xFFEAEDED),
    background: Color(0xFFF6F7F6),
    onSurface: Color(0xFF2C3E50), // texto oscuro más legible
  ),

  cardColor: Colors.white,
  dividerColor: Colors.grey,

  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFFEDEFEF),
    foregroundColor: Colors.black87,
    elevation: 0.8,
  ),

  listTileTheme: const ListTileThemeData(
    textColor: Colors.black87,
    iconColor: Color(0xFF28B463),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(0xFF28B463),
      foregroundColor: Colors.white,
    ),
  ),

  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color(0xFF28B463),
    foregroundColor: Colors.white,
  ),

  dialogBackgroundColor: Colors.white,
);
