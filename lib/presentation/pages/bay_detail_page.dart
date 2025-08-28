import 'package:flutter/material.dart';

class BayDetailPage extends StatelessWidget {
  final String id; // Recibimos el id por ruta
  const BayDetailPage({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detalle $id')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bahía: $id', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.history), label: const Text('Ver historial')),
            const SizedBox(height: 8),
            OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.edit), label: const Text('Editar bahía')),
          ],
        ),
      ),
    );
  }
}
