import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import './widgets/app_drawer.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inicio')),
      drawer: const AppDrawer(),
      body: Center(
        child: FilledButton.icon(
          onPressed: () => context.go('/bays'),
          icon: const Icon(Icons.view_module),
          label: const Text('Ver Bahías'),
        ),
      ),
    );
  }
}
