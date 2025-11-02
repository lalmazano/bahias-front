import 'package:flutter/material.dart';
import 'OpcionesConfig/windgets.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ConfiguracionScreen extends StatelessWidget {
  const ConfiguracionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); 

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuraciones'),
        backgroundColor: theme.appBarTheme.backgroundColor, // 👈 usa color del tema
        foregroundColor: theme.appBarTheme.foregroundColor,
      ),
      backgroundColor: theme.scaffoldBackgroundColor, 
      body: ListView(
        children: [
          const SizedBox(height: 10),

          // --- GESTIÓN DE ROLES ---
          ListTile(
            leading: Icon(Icons.security, color: theme.colorScheme.primary),
            title: Text('Gestión de Roles',
                style: TextStyle(color: theme.colorScheme.onSurface)),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RolesScreen()),
            ),
          ),
          Divider(color: theme.dividerColor, height: 1),

          // --- ASIGNACIÓN DE ROLES ---
          ListTile(
            leading:
                Icon(Icons.assignment_ind, color: theme.colorScheme.primary),
            title: Text('Asignar Roles',
                style: TextStyle(color: theme.colorScheme.onSurface)),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AsignarRolesScreen()),
            ),
          ),
          Divider(color: theme.dividerColor, height: 1),

          // --- TIPO DE BAHÍA ---
          ListTile(
            leading:
                Icon(Icons.category_outlined, color: theme.colorScheme.primary),
            title: Text('Tipo de Bahía',
                style: TextStyle(color: theme.colorScheme.onSurface)),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TipoBahiaScreen()),
            ),
          ),
          Divider(color: theme.dividerColor, height: 1),

          // --- ESTADO DE BAHÍA ---
          ListTile(
            leading:
                Icon(Icons.toggle_on_outlined, color: theme.colorScheme.primary),
            title: Text('Estado de Bahía',
                style: TextStyle(color: theme.colorScheme.onSurface)),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EstadoBahiaScreen()),
            ),
          ),
          Divider(color: theme.dividerColor, height: 1),

          // --- UBICACIONES ---
          ListTile(
            leading:
                Icon(Icons.place_outlined, color: theme.colorScheme.primary),
            title: Text('Ubicaciones',
                style: TextStyle(color: theme.colorScheme.onSurface)),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const UbicacionesScreen()),
            ),
          ),
          Divider(color: theme.dividerColor, height: 1),

          // --- PARÁMETROS ---
          ListTile(
            leading: Icon(Icons.tune, color: theme.colorScheme.primary),
            title: Text('Parámetros',
                style: TextStyle(color: theme.colorScheme.onSurface)),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ParametrosScreen()),
            ),
          ),
          Divider(color: theme.dividerColor, height: 1),

          // --- TEMAS (solo si NO está en web) ---
          if (!kIsWeb) ...[
            ListTile(
              leading: Icon(Icons.palette, color: theme.colorScheme.primary),
              title: Text('Temas',
                  style: TextStyle(color: theme.colorScheme.onSurface)),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ThemeScreen()),
              ),
            ),
            Divider(color: theme.dividerColor, height: 1),
          ],

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
