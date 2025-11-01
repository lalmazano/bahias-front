import 'package:flutter/material.dart';
import 'package:bahias_app/screens/roles_screen.dart';
import 'package:bahias_app/screens/asignacion_roles_screen.dart';
import 'package:bahias_app/screens/theme_screen.dart';
import 'package:bahias_app/screens/tipo_bahia_screen.dart';
import 'package:bahias_app/screens/estado_bahia_screen.dart';
import 'package:bahias_app/screens/parametros_screen.dart'; 

class ConfiguracionScreen extends StatelessWidget {
  const ConfiguracionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuraciones')),
      backgroundColor: const Color(0xFF0B0F0B),
      body: ListView(
        children: [
          const SizedBox(height: 10),
          ListTile(
            leading: const Icon(Icons.security, color: Colors.greenAccent),
            title: const Text('Gestión de Roles',
                style: TextStyle(color: Colors.white)),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RolesScreen()),
            ),
          ),
          const Divider(color: Colors.white24, height: 1),
          ListTile(
            leading:
                const Icon(Icons.assignment_ind, color: Colors.greenAccent),
            title: const Text('Asignar Roles',
                style: TextStyle(color: Colors.white)),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AsignarRolesScreen()),
            ),
          ),
          const Divider(color: Colors.white24, height: 1),
          ListTile(
            leading: const Icon(Icons.palette, color: Colors.greenAccent),
            title:
                const Text('Temas', style: TextStyle(color: Colors.white)),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ThemeScreen()),
            ),
          ),
          const Divider(color: Colors.white24, height: 1),
          ListTile(
            leading: const Icon(Icons.category_outlined,
                color: Colors.greenAccent),
            title: const Text('Tipo de Bahía',
                style: TextStyle(color: Colors.white)),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TipoBahiaScreen()),
            ),
          ),
          const Divider(color: Colors.white24, height: 1),
          ListTile
          (
            leading: const Icon(Icons.toggle_on_outlined,
                color: Colors.greenAccent),
            title: const Text('Estado de Bahía',
                style: TextStyle(color: Colors.white)),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EstadoBahiaScreen()),
            ),
          ),
          const Divider(color: Colors.white24, height: 1),

          // 👇 NUEVA OPCIÓN
          ListTile(
            leading: const Icon(Icons.tune, color: Colors.greenAccent),
            title: const Text('Parámetros',
                style: TextStyle(color: Colors.white)),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ParametrosScreen()),
            ),
          ),
          const Divider(color: Colors.white24, height: 1),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
