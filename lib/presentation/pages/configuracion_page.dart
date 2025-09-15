import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bahias_app/presentation/state/theme_provider.dart';  // Asegúrate de que la ruta esté correcta
import 'package:bahias_app/presentation/pages/widgets/app_drawer.dart'; // Asegúrate de que esta ruta sea la correcta


class ConfiguracionPage extends ConsumerStatefulWidget {
  const ConfiguracionPage({super.key});

  @override
  _ConfiguracionPageState createState() => _ConfiguracionPageState();
}

class _ConfiguracionPageState extends ConsumerState<ConfiguracionPage> {
  // Variables para gestionar las configuraciones
  bool _darkMode = false; // Tema oscuro claro
  String _language = 'Español'; // Idioma
  bool _notifications = true; // Notificaciones

  // Método para cambiar el tema de la aplicación
  void _toggleTheme(bool value) {
    setState(() {
      _darkMode = value;
    });

    // Cambiar el tema en el provider de Riverpod
    final themeMode = _darkMode ? ThemeMode.dark : ThemeMode.light;
    ref.read(themeProvider.notifier).state = themeMode;  // Cambiar el tema usando el provider
  }

  // Método para cambiar el idioma
  void _changeLanguage(String newLanguage) {
    setState(() {
      _language = newLanguage;
    });
  }

  // Método para activar/desactivar notificaciones
  void _toggleNotifications(bool value) {
    setState(() {
      _notifications = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      drawer: AppDrawer(), // Elimina const si AppDrawer no es un widget constante
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Preferencias de la aplicación',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Opción para cambiar el tema
            ListTile(
              leading: const Icon(Icons.brightness_6),
              title: const Text('Modo oscuro/claro'),
              trailing: Switch(
                value: _darkMode,
                onChanged: _toggleTheme,
              ),
            ),
            const Divider(),

            // Opción para seleccionar el idioma
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('Idioma'),
              trailing: DropdownButton<String>(
                value: _language,
                items: <String>['Español', 'English']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newLanguage) {
                  if (newLanguage != null) {
                    _changeLanguage(newLanguage);
                  }
                },
              ),
            ),
            const Divider(),

            // Opción para activar/desactivar notificaciones
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notificaciones'),
              trailing: Switch(
                value: _notifications,
                onChanged: _toggleNotifications,
              ),
            ),
            const Divider(),
          ],
        ),
      ),
    );
  }
}
