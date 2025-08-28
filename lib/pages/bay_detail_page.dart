import 'package:flutter/material.dart';
import '../models/bay.dart';

class BayDetailPage extends StatelessWidget {
  final Bay bay;
  const BayDetailPage({super.key, required this.bay});

  @override
  Widget build(BuildContext context) {
    String estado(BayStatus s) => switch (s) {
      BayStatus.libre => 'Libre',
      BayStatus.ocupada => 'Ocupada',
      BayStatus.mantenimiento => 'Mantenimiento',
    };

    return Scaffold(
      appBar: AppBar(title: Text(bay.nombre)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Estado: ${estado(bay.estado)}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('Puestos: ${bay.puestos}', style: const TextStyle(fontSize: 16)),
            const Divider(height: 24),
            if (bay.estado == BayStatus.libre)
            FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.check),
              label: const Text('Ocupar bahía'),
            ),
            if (bay.estado == BayStatus.ocupada)
            FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.close),
              label: const Text('Liberar bahía'),
            ),
            if (bay.estado == BayStatus.mantenimiento)
            FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.build),
              label: const Text('Finalizar mantenimiento'),
            ),
            if (bay.estado != BayStatus.mantenimiento &&
                bay.estado != BayStatus.ocupada)
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.build),
              label: const Text('Iniciar mantenimiento'),
            ),
            // Aquí puedes agregar acciones (ocupar/liberar, ver historial, etc.)
            FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.history),
              label: const Text('Ver historial'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.edit),
              label: const Text('Editar bahía'),
            ),
          ],
        ),
      ),
    );
  }
}
