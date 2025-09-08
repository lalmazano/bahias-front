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

    Color color(BayStatus s) => switch (s) {
      BayStatus.libre => Colors.green,
      BayStatus.ocupada => Colors.pink,
      BayStatus.mantenimiento => Colors.orange,
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Bahías')),
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: bays.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.1),
          itemBuilder: (_, i) {
            final b = bays[i];
            return InkWell(
              onTap: () => context.go('/bays/${b.id}'),
              borderRadius: BorderRadius.circular(16),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        CircleAvatar(
                          backgroundColor: color(b.estado).withOpacity(.15),
                          child: Icon(Icons.directions_car, color: color(b.estado)),
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: Text(b.nombre, style: const TextStyle(fontWeight: FontWeight.bold))),
                      ]),
                      const Spacer(),
                      Row(children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: color(b.estado).withOpacity(.15),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: color(b.estado)),
                          ),
                          child: Text(b.estado.name),
                        ),
                        const Spacer(),
                        Text('Puestos: ${b.puestos}', style: const TextStyle(fontWeight: FontWeight.w600)),
                      ])
                    ],
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
