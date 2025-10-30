import 'package:flutter/material.dart';
import '../screens/roles_screen.dart';
import '../screens/asignacion_roles_screen.dart';
import '../screens/theme_screen.dart';

class ConfiguracionesScreen extends StatefulWidget {
  const ConfiguracionesScreen({super.key});

  @override
  State<ConfiguracionesScreen> createState() => _ConfiguracionesScreenState();
}

class _ConfiguracionesScreenState extends State<ConfiguracionesScreen> {
  int _selectedIndex = 0;

  final _tabs = const [
    RolesScreen(),               // gestión de roles (CRUD)
    AsignacionRolesScreen(),     // asignar roles a usuarios
    ThemeScreen(),               // cambio de tema
  ];

  final _titles = const [
    'Gestión de Roles',
    'Asignación de Roles',
    'Temas de la Aplicación',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_selectedIndex])),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (i) => setState(() => _selectedIndex = i),
            labelType: NavigationRailLabelType.all,
            backgroundColor: const Color(0xFF111511),
            selectedIconTheme: const IconThemeData(color: Colors.greenAccent),
            selectedLabelTextStyle: const TextStyle(color: Colors.greenAccent),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.security_outlined),
                label: Text('Roles'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.supervisor_account_outlined),
                label: Text('Asignar Roles'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.palette_outlined),
                label: Text('Temas'),
              ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: _tabs[_selectedIndex]),
        ],
      ),
    );
  }
}
