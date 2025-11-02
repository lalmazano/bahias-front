import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bahias_app/theme_provider.dart'; // si estás fuera de /lib


class ThemeScreen extends StatelessWidget {
  const ThemeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Center(
      child: Card(
        color: themeProvider.isDarkMode ? const Color(0xFF111511) : Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Selecciona un tema',
                style: TextStyle(
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 20),
              SwitchListTile(
                activeColor: Colors.greenAccent,
                title: Text(
                  themeProvider.isDarkMode ? 'Modo Oscuro' : 'Modo Claro',
                  style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : Colors.black),
                ),
                value: themeProvider.isDarkMode,
                onChanged: (_) => themeProvider.toggleTheme(),
              ),
              const SizedBox(height: 10),
              Text(
                'La paleta principal se mantiene (verde, amarillo, azul)',
                style: TextStyle(
                  color: themeProvider.isDarkMode ? Colors.white70 : Colors.black87,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
