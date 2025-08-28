import 'package:flutter/material.dart';
import './widgets/app_drawer.dart';

class UsuariosPage extends StatelessWidget {
  const UsuariosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Usuarios')),
      drawer: const AppDrawer(),
      body: const Center(child: Text('Administración de usuarios')),
    );
  }
}
