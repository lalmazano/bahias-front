import 'package:flutter/material.dart';

class AjustesPage extends StatelessWidget {
  const AjustesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes'), centerTitle: true),
      body: Center(
        child: Text(
          'Página de Ajustes',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
