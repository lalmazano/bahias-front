import 'package:flutter/material.dart';

final darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF0B0F0B),
  cardColor: const Color(0xFF1E2420),
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF2ECC71),
    secondary: Color(0xFFFFC107),
    tertiary: Color(0xFF42A5F5),
  ),
);
