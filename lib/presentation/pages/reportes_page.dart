import 'package:flutter/material.dart';
import './widgets/app_drawer.dart';

class ReportesPage extends StatelessWidget {
  const ReportesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reportes')),
      drawer: const AppDrawer(),
      body: const Center(child: Text('Reportes y estadísticas')),
    );
  }
}
