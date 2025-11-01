import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../services/services.dart';

class HistorialReservas extends StatelessWidget {
  const HistorialReservas({super.key});

  @override
  Widget build(BuildContext context) {
    final service = EstadisticasService();

    return StreamBuilder<QuerySnapshot>(
      stream: service.getReservasRecientes(),
      builder: (context, snap) {
        if (snap.hasError) {
          return const Text("Error al cargar reservas recientes.",
              style: TextStyle(color: Colors.redAccent));
        }
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snap.data!.docs;
        if (docs.isEmpty) {
          return const Text("No hay reservas recientes.",
              style: TextStyle(color: Colors.white54));
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.15),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "📜 Historial de reservas recientes",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 14),
              ListView.builder(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: docs.length,
                itemBuilder: (context, i) {
                  final data = docs[i].data() as Map<String, dynamic>;
                  final inicio = (data['FechaInicio'] as Timestamp?)?.toDate();
                  final fin = (data['FechaFin'] as Timestamp?)?.toDate();
                  final estado =
                      (data['EstadoReservaRef'] as DocumentReference?)?.id ??
                          '-';
                  final bahias = (data['BahiasRefs'] as List?)
                          ?.whereType<DocumentReference>()
                          .map((b) => b.id)
                          .join(', ') ??
                      '-';
                  return ListTile(
                    leading: const Icon(Icons.history, color: Colors.cyanAccent),
                    title: Text('Bahías: $bahias',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16)),
                    subtitle: Text(
                      [
                        if (inicio != null && fin != null)
                          'Inicio: ${DateFormat('dd/MM HH:mm').format(inicio)} → Fin: ${DateFormat('HH:mm').format(fin)}',
                        'Estado: $estado',
                      ].join('\n'),
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
