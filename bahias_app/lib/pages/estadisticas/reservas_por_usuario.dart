import 'package:flutter/material.dart';
import '../../services/services.dart';
import 'widgets.dart';

class ReservasPorUsuario extends StatelessWidget {
  const ReservasPorUsuario({super.key});

  @override
  Widget build(BuildContext context) {
    final service = EstadisticasService();

    return FutureBuilder<Map<String, int>>(
      future: service.getConteoReservasPorUsuario(),
      builder: (context, snapConteo) {
        if (!snapConteo.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final conteo = snapConteo.data ?? {};

        return FutureBuilder<Map<String, String>>(
          future: service.getNombresUsuarios(),
          builder: (context, snapUsuarios) {
            if (!snapUsuarios.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final nombres = snapUsuarios.data ?? {};
            final entries = conteo.entries
                .map((e) =>
                    MapEntry<String, int>(nombres[e.key] ?? e.key, e.value))
                .toList();

            entries.sort((a, b) => b.value.compareTo(a.value));

            return ListSection(
              title: "👤 Reservas por usuario / operador",
              iconColor: Colors.orangeAccent,
              entries: entries,
            );
          },
        );
      },
    );
  }
}
