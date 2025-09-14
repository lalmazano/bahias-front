import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/bay.dart';
import './widgets/app_drawer.dart';

class BaysMenuPage extends StatelessWidget {
  const BaysMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bays = <Bay>[
      Bay(id: 'B1', nombre: 'Bahía 1', estado: BayStatus.libre, puestos: 3),
      Bay(id: 'B2', nombre: 'Bahía 2', estado: BayStatus.ocupada, puestos: 2),
      Bay(id: 'B3', nombre: 'Bahía 3', estado: BayStatus.mantenimiento, puestos: 4),
      Bay(id: 'B4', nombre: 'Bahía 4', estado: BayStatus.libre, puestos: 1),
    ];

    Color color(BayStatus s) {
      switch (s) {
        case BayStatus.libre:
          return Colors.green;
        case BayStatus.ocupada:
          return Colors.pink;
        case BayStatus.mantenimiento:
          return Colors.orange;
        default:
          return Colors.grey;
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Bahías')),
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: bays.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2, // 4 columnas para pantallas grandes, 2 para pantallas pequeñas
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
          ),
          itemBuilder: (context, index) {
            final bay = bays[index];
            return Card(
              color: color(bay.estado),
              child: InkWell(
                onTap: () {
                  // Navegar a la página de detalles de la bahía (puedes personalizar esta navegación)
                  // Por ejemplo:
                  // GoRouter.of(context).push('/bay_detail/${bay.id}');
                },
                child: Center(
                  child: Text(
                    bay.nombre,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
