import 'package:flutter/material.dart';
import './widgets/app_drawer.dart';

class RolesPage extends StatelessWidget {
  const RolesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Roles')),
      drawer: const AppDrawer(),
      body: const Center(child: Text('Gestión de roles y permisos')),
    );
  }
}
