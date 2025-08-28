import 'package:flutter/material.dart';
import './widgets/app_drawer.dart';

class ConfiguracionPage extends StatelessWidget {
  const ConfiguracionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      drawer: const AppDrawer(),
      body: const Center(child: Text('Preferencias de la aplicación')),
    );
  }
}
