import 'package:flutter/material.dart';

final lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,

  //  Fondo general: casi blanco, con un toque gris
  scaffoldBackgroundColor: const Color(0xFFF6F7F6),

  colorScheme: const ColorScheme.light(
    primary: Color(0xFF2ECC71),   // verde institucional
    secondary: Color(0xFFFFC107), // amarillo
    tertiary: Color(0xFF42A5F5),  // azul
    surface: Color(0xFFEDEFEF),   // gris claro para tarjetas
    background: Color(0xFFF6F7F6),
  ),

  cardColor: const Color(0xFFFFFFFF), // blanco suave
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFFEDEFEF),
    foregroundColor: Colors.black87,
    elevation: 0.4,
  ),

  listTileTheme: const ListTileThemeData(
    textColor: Colors.black87,
    iconColor: Color(0xFF2ECC71),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF2ECC71),
      foregroundColor: Colors.white,
    ),
  ),
);
