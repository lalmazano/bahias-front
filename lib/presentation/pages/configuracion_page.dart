import 'package:flutter/material.dart';
import './widgets/app_drawer.dart';

class ConfiguracionPage extends StatefulWidget {
  const ConfiguracionPage({super.key});

  @override
  _ConfiguracionPageState createState() => _ConfiguracionPageState();
}

class _ConfiguracionPageState extends State<ConfiguracionPage> {
  // Variables para gestionar las configuraciones
  bool _darkMode = false; // Tema oscuro claro
  String _language = 'Español'; // Idioma
  bool _notifications = true; // Notificaciones

  // Método para cambiar el tema de la aplicación
  void _toggleTheme(bool value) {
    setState(() {
      _darkMode = value;
    });
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
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título de la sección
            const Text(
              'Preferencias de la aplicación',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Opción para cambiar el tema
            ListTile(
              leading: Icon(Icons.brightness_6),
              title: Text('Modo oscuro/claro'),
              trailing: Switch(
                value: _darkMode,
                onChanged: _toggleTheme,
              ),
            ),
            const Divider(),

            // Opción para seleccionar el idioma
            ListTile(
              leading: Icon(Icons.language),
              title: Text('Idioma'),
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
                  _changeLanguage(newLanguage!);
                },
              ),
            ),
            const Divider(),

            // Opción para activar/desactivar notificaciones
            ListTile(
              leading: Icon(Icons.notifications),
              title: Text('Notificaciones'),
              trailing: Switch(
                value: _notifications,
                onChanged: _toggleNotifications,
              ),
            ),
            const Divider(),

            // Botón para cerrar sesión (si es necesario)
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Cerrar sesión'),
              onTap: () {
                // Aquí va la lógica para cerrar sesión
                // Por ejemplo, puedes navegar a la pantalla de inicio de sesión
                // context.go('/login');
              },
            ),
          ],
        ),
      ),
    );
  }
}
