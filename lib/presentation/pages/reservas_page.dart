import 'package:flutter/material.dart';
import './widgets/app_drawer.dart';

class ReservasPage extends StatelessWidget {
  const ReservasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reservas')),
      drawer: const AppDrawer(),
      body: const Center(child: Text('Listado/gestión de reservas')),
    );
  }
}
